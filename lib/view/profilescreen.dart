
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workerhub/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:workerhub/myconfig.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  final Function(User)? onProfileUpdated;

  const ProfilePage({super.key, required this.user, this.onProfileUpdated});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  File? _image;
  bool _isEditing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/workerhub/php/get_profile.php"),
        body: {"worker_id": widget.user.userId ?? ""},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final u = data['data'];
          setState(() {
            nameController.text = u['full_name'] ?? "";
            emailController.text = u['email'] ?? "";
            phoneController.text = u['phone'] ?? "";
            addressController.text = u['address'] ?? "";
            widget.user.userImage = u['image'] ?? "";
          });
        } else {
          _showError(data['message'] ?? "Failed to load profile");
        }
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Network error");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _updateProfile() async {
    String base64Image = "";
    String filename = "";

    if (_image != null) {
      final bytes = await _image!.readAsBytes();
      base64Image = base64Encode(bytes);
      filename = "${widget.user.userId}.png";
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/workerhub/php/update_profile.php"),
        body: {
          "worker_id": widget.user.userId ?? "",
          "full_name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "phone": phoneController.text.trim(),
          "address": addressController.text.trim(),
          "image": base64Image,
          "filename": filename,
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        setState(() => _isEditing = false);
        if (widget.onProfileUpdated != null) {
          widget.onProfileUpdated!(widget.user);
        }
      } else {
        _showError(data['message'] ?? "Update failed");
      }
    } catch (e) {
      _showError("Network error");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image From"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Camera"),
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text("Gallery"),
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, maxWidth: 800, maxHeight: 800);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Widget _profileImageWidget() {
    final imageWidget = CircleAvatar(
      radius: 60,
      backgroundImage: _image != null
          ? FileImage(_image!)
          : (widget.user.userImage?.isNotEmpty ?? false)
              ? NetworkImage("${MyConfig.myurl}/${widget.user.userImage}")
              : const AssetImage("assets/images/profile.png") as ImageProvider,
    );

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        imageWidget,
        if (_isEditing)
          GestureDetector(
            onTap: _showImagePickerDialog,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.add, size: 20, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController c, {int max = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        enabled: _isEditing,
        maxLines: max,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.shade700),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_loading)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
              onPressed: _isEditing ? _updateProfile : () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _profileImageWidget(),
                  const SizedBox(height: 20),
                  _buildField("Full Name", nameController),
                  _buildField("Email", emailController),
                  _buildField("Phone", phoneController),
                  _buildField("Address", addressController, max: 3),
                ],
              ),
            ),
    );
  }
}
