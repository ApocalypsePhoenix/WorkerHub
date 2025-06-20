import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workerhub/myconfig.dart';
import 'package:workerhub/model/user.dart';
import 'package:workerhub/view/editsubmissionscreen.dart';

class SubmissionHistoryScreen extends StatefulWidget {
  final User user;

  const SubmissionHistoryScreen({super.key, required this.user});

  @override
  State<SubmissionHistoryScreen> createState() => _SubmissionHistoryScreenState();
}

class _SubmissionHistoryScreenState extends State<SubmissionHistoryScreen> {
  List submissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/workerhub/php/get_submissions.php"),
      body: {"worker_id": widget.user.userId},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        submissions = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submission History",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade800,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions yet."))
              : ListView.builder(
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final submission = submissions[index];
                    final submissionText = submission['submission_text'] ?? "";
                    final submissionDate = submission['submitted_at'] ?? "";
                    final title = submission['title'] ?? "Untitled Task";
                    final submissionId = submission['submission_id'].toString(); // FIXED
                    final workId = submission['work_id'].toString(); // FIXED

                    String imageUrl =
                        "${MyConfig.myurl}/workerhub/assets/images/submissions/"
                        "${widget.user.userId}_${workId}.png";

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Submitted: $submissionDate"),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    submissionText.length > 200
                                        ? "${submissionText.substring(0, 200)}..."
                                        : submissionText,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Text("No image available"),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditSubmissionScreen(
                                              submissionId: submissionId,
                                              submissionText: submissionText,
                                              workerId: widget.user.userId ?? "",
                                              workId: workId,
                                              title: title,
                                            ),
                                          ),
                                        );
                                        if (result == true) fetchSubmissions();
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.green),
                                      label: const Text("Edit", style: TextStyle(color: Colors.green)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
