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

    String base64Image = "";
    String imageName = "";

    if (_image != null || webImage != null) {
      base64Image = base64Encode(
        kIsWeb ? webImage! : await _image!.readAsBytes(),
      );
      imageName = "${widget.user.userId}_${widget.work.workId}.png";
    }

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/workerhub/php/submit_work.php"),
      body: {
        'work_id': widget.work.workId,
        'worker_id': widget.user.userId,
        'submission_text': _submissionController.text.trim(),
        'image': base64Image,
        'filename': imageName,
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

  void showSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image From"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _selectFromCamera();
              },
              child: const Text("From Camera"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _selectFromGallery();
              },
              child: const Text("From Gallery"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) webImage = await pickedFile.readAsBytes();
      setState(() {});
    }
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) webImage = await pickedFile.readAsBytes();
      setState(() {});
    }
  }

  ImageProvider _buildSubmissionImage() {
    if (_image != null) {
      return kIsWeb ? MemoryImage(webImage!) : FileImage(_image!);
    }
    return const AssetImage("assets/images/camera.png");
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.work;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Task", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade800,
                leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title ?? "No Title",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(task.description ?? "No Description"),
                const SizedBox(height: 20),
                const Text("Your Submission:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _submissionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Enter your submission here...",
                    filled: true,
                    fillColor: Colors.green.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Attach Image (optional):",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: showSelectionDialog,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: _buildSubmissionImage(),
                        fit: BoxFit.cover,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
