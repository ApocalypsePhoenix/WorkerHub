import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workerhub/model/submission.dart';
import 'package:workerhub/myconfig.dart';

class EditSubmissionScreen extends StatefulWidget {
  final Submission submission;
  const EditSubmissionScreen({super.key, required this.submission});

  @override
  State<EditSubmissionScreen> createState() => _EditSubmissionScreenState();
}

class _EditSubmissionScreenState extends State<EditSubmissionScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.submission.submissionText ?? "";
  }

  void _saveEdit() async {
    final updatedText = _controller.text.trim();

    if (updatedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission cannot be empty"), backgroundColor: Colors.red),
      );
      return;
    }

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text("Are you sure you want to update your submission?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Update")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/workerhub/php/edit_submissions.php"),
      body: {
        "submission_id": widget.submission.submissionId ?? "",
        "submission_text": updatedText,
      },
    );

    setState(() => _isSaving = false);

    final res = json.decode(response.body);
    if (res['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission updated successfully"), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Return with success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Failed to update"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Submission", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.submission.title ?? "Task Title",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "Update your submission...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.green.shade50,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isSaving ? null : _saveEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
