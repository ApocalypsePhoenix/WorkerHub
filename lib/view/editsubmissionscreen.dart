import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workerhub/myconfig.dart';

class EditSubmissionScreen extends StatefulWidget {
  final String submissionId;
  final String submissionText;
  final String workerId;
  final String workId;
  final String title;

  const EditSubmissionScreen({
    super.key,
    required this.submissionId,
    required this.submissionText,
    required this.workerId,
    required this.workId,
    required this.title,
  });

  @override
  State<EditSubmissionScreen> createState() => _EditSubmissionScreenState();
}

class _EditSubmissionScreenState extends State<EditSubmissionScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.submissionText;
  }

  Future<void> _saveChanges() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text("Are you sure you want to update this submission?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/workerhub/php/edit_submissions.php"),
      body: {
        "submission_id": widget.submissionId,
        "submission_text": _controller.text.trim(),
      },
    );

    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Submission updated successfully"),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message'] ?? "Update failed"),
        backgroundColor: Colors.red,
      ));
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        "${MyConfig.myurl}/workerhub/assets/images/submissions/${widget.workerId}_${widget.workId}.png";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Submission", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                )),
            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              maxLines: 6,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: "Submission Text",
                labelStyle: TextStyle(color: Colors.green.shade800),
                filled: true,
                fillColor: Colors.green.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text("Attached Image",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Center(child: Text("No image found.")),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveChanges,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
