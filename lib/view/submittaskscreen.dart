import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:workerhub/model/user.dart';
import 'package:workerhub/model/work.dart';
import 'package:workerhub/myconfig.dart';

class SubmitTaskScreen extends StatefulWidget {
  final User user;
  final Work work;

  const SubmitTaskScreen({super.key, required this.user, required this.work});

  @override
  State<SubmitTaskScreen> createState() => _SubmitTaskScreenState();
}

class _SubmitTaskScreenState extends State<SubmitTaskScreen> {
  final TextEditingController _submissionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitWork() async {
    setState(() => _isSubmitting = true);

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/workerhub/php/submit_work.php"),
      body: {
        'work_id': widget.work.workId,
        'worker_id': widget.user.userId,
        'submission_text': _submissionController.text.trim(),
      },
    );

    final res = json.decode(response.body);
    if (res['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task submitted successfully"),
          backgroundColor: Colors.green,
          ),
      );
      Navigator.pop(context, true); // return to refresh task list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${res['message']}"),
          backgroundColor: Colors.red,
          ),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.work;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Task",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title ?? "No Title",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(task.description ?? "No Description",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Assigned: ${task.dateAssigned ?? "-"}"),
            Text("Due: ${task.dueDate ?? "-"}"),
            Text("Status: ${task.status ?? "-"}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: task.status == "success"
                        ? Colors.green
                        : Colors.orange)),
            const SizedBox(height: 30),
            const Text("Your Submission:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _submissionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter your submission details here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.green.shade50,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitWork,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
