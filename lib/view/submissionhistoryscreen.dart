import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workerhub/model/user.dart';
import 'package:workerhub/model/submission.dart';
import 'package:workerhub/myconfig.dart';
import 'package:workerhub/view/editsubmissionscreen.dart';

class SubmissionHistoryScreen extends StatefulWidget {
  final User user;
  const SubmissionHistoryScreen({super.key, required this.user});

  @override
  State<SubmissionHistoryScreen> createState() => _SubmissionHistoryScreenState();
}

class _SubmissionHistoryScreenState extends State<SubmissionHistoryScreen> {
  List<Submission> submissionList = [];
  bool isLoading = true;
  Set<int> expandedItems = {}; // Tracks expanded tiles

  @override
  void initState() {
    super.initState();
    loadSubmissions();
  }

  Future<void> loadSubmissions() async {
    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/workerhub/php/get_submissions.php"),
      body: {"worker_id": widget.user.userId},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        submissionList = (data as List)
            .map((item) => Submission.fromJson(item))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load submissions")),
      );
    }
  }

  Widget _buildSubmissionCard(Submission submission, int index) {
    bool isExpanded = expandedItems.contains(index);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ExpansionTile(
        title: Text(
          submission.title ?? "No Title",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Submitted on: ${submission.submittedAt ?? "-"}",
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              expandedItems.add(index);
            } else {
              expandedItems.remove(index);
            }
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submission.submissionText ?? "No submission provided.",
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditSubmissionScreen(submission: submission),
                        ),
                      );
                      if (result == true) {
                        loadSubmissions(); // Refresh on successful edit
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Edit", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submission History",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade800,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissionList.isEmpty
              ? const Center(child: Text("No submissions found."))
              : RefreshIndicator(
                  onRefresh: loadSubmissions,
                  child: ListView.builder(
                    itemCount: submissionList.length,
                    itemBuilder: (context, index) {
                      return _buildSubmissionCard(submissionList[index], index);
                    },
                  ),
                ),
    );
  }
}
