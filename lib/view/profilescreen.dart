import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workerhub/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:workerhub/myconfig.dart';
import 'package:workerhub/view/mainscreen.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  File? _image;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text: widget.user.userId);
    nameController = TextEditingController(text: widget.user.userName);
    emailController = TextEditingController(text: widget.user.userEmail);
    phoneController = TextEditingController(text: widget.user.userPhone);
    addressController = TextEditingController(text: widget.user.userAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Profile Page",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _selectImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : const AssetImage("assets/images/profile.png") as ImageProvider,
                    backgroundColor: Colors.green.shade100,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField("Worker ID", idController, enabled: false),
                _buildTextField("Name", nameController),
                _buildTextField("Email", emailController),
                _buildTextField("Phone", phoneController),
                _buildTextField("Address", addressController, maxLines: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _saveProfile,
                    child: const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.shade700),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    String fullName = nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String address = addressController.text;

    http.post(
      Uri.parse("${MyConfig.myurl}/workerhub/php/update_profile.php"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "id": widget.user.userId ?? "",
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "address": address,
      },
    ).then((response) {
      print("Raw response: ${response.body}");

      if (response.statusCode == 200 && response.body.contains('status')) {
        Map<String, dynamic> jsondata = jsonDecode(response.body);

        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );

          setState(() {
            widget.user.userName = fullName;
            widget.user.userEmail = email;
            widget.user.userPhone = phone;
            widget.user.userAddress = address;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(user: widget.user)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(jsondata['message'] ?? "Update failed"),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid response from server")),
        );
      }
    }).catchError((error) {
      print("HTTP error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection failed")),
      );
    });
  }
}
