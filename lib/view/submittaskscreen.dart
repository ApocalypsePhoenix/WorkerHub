import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
  File? _image;
  Uint8List? webImage;
  bool _isSubmitting = false;

  Future<void> _submitWork() async {
    if (_submissionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your submission text")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String? imageName;
    if (_image != null) {
      String base64Image = base64Encode(kIsWeb
          ? webImage!
          : await _image!.readAsBytes());
      imageName = "${widget.user.userId}_${widget.work.workId}.png";

      await http.post(
        Uri.parse("${MyConfig.myurl}/workerhub/php/upload_submission_image.php"),
        body: {
          "image": base64Image,
          "filename": imageName,
        },
      );
    }

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/workerhub/php/submit_work.php"),
      body: {
        'work_id': widget.work.workId,
        'worker_id': widget.user.userId,
        'submission_text': _submissionController.text.trim(),
        'image': imageName ?? "",
      },
    );

    final res = json.decode(response.body);
    if (res['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task submitted successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${res['message']}")),
      );
    }

    setState(() => _isSubmitting = false);
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) {
        webImage = await pickedFile.readAsBytes();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.work;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Task", style: TextStyle(color: Colors.white)),
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
            Text(task.description ?? "No Description"),
            const SizedBox(height: 20),
            const Text("Your Submission:"),
            const SizedBox(height: 10),
            TextField(
              controller: _submissionController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.green.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "Enter submission details...",
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(10),
                  image: _image != null
                      ? DecorationImage(
                          image: kIsWeb ? MemoryImage(webImage!) : FileImage(_image!) as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage("assets/images/camera.png"),
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitWork,
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text("Submit", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
