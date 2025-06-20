import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workerhub/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:workerhub/myconfig.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

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
    if (_image != null) {
      final bytes = await _image!.readAsBytes();
      base64Image = base64Encode(bytes);
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
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        setState(() => _isEditing = false);
      } else {
        _showError(data['message'] ?? "Update failed");
      }
    } catch (e) {
      _showError("Network error");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _selectImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x != null) {
      setState(() => _image = File(x.path));
    }
  }

  Widget _profileImageWidget() {
    if (_image != null) {
      return CircleAvatar(radius: 60, backgroundImage: FileImage(_image!));
    } else if ((widget.user.userImage ?? "").isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage("${MyConfig.myurl}/${widget.user.userImage}"),
      );
    } else {
      return const CircleAvatar(radius: 60, backgroundImage: AssetImage("assets/images/profile.png"));
    }
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
        title: const Text("Profile"),
        backgroundColor: Colors.green.shade800,
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
                  GestureDetector(
                    onTap: _isEditing ? _selectImage : null,
                    child: _profileImageWidget(),
                  ),
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
