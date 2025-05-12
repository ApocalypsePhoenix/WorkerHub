import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:workerhub/myconfig.dart';
import 'package:workerhub/view/loginscreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  File? _image;
  Uint8List? webImageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Register",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Colors.green.shade800,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: showSelectionDialog,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                          image: DecorationImage(
                            image: _image == null
                                ? const AssetImage("assets/images/camera.png")
                                : _buildProfileImage(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(controller: nameController, label: "Your Name"),
                    _buildTextField(controller: emailController, label: "Email", keyboard: TextInputType.emailAddress),
                    _buildTextField(controller: passwordController, label: "Password", obscure: true),
                    _buildTextField(controller: confirmPasswordController, label: "Confirm Password", obscure: true),
                    _buildTextField(controller: phoneController, label: "Phone", keyboard: TextInputType.phone),
                    _buildTextField(controller: addressController, label: "Address", maxLines: 3),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: registerUserDialog,
                        child: const Text("Register", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green.shade700),
              borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void registerUserDialog() {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text;
    String address = addressController.text;

    if ([name, email, password, confirmPassword, phone, address].any((e) => e.isEmpty)) {
      _showSnackbar("Please fill all fields");
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+").hasMatch(email)) {
      _showSnackbar("Please enter a valid email");
      return;
    }

    if (password.length < 6) {
      _showSnackbar("Password must be at least 6 characters");
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar("Passwords do not match");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Registration"),
        content: const Text("Are you sure you want to register this account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              registerUser();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void registerUser() {
    http.post(Uri.parse("${MyConfig.myurl}/workerhub/php/register_worker.php"), body: {
      "name": nameController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "phone": phoneController.text,
      "address": addressController.text,
    }).then((response) {
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'success') {
          _showSnackbar("Success!");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        } else {
          _showSnackbar("Failed to register");
        }
      }
    });
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void showSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select from"),
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
      if (kIsWeb) webImageBytes = await pickedFile.readAsBytes();
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
      setState(() {});
    }
  }

  ImageProvider _buildProfileImage() {
    if (_image != null) {
      return kIsWeb ? MemoryImage(webImageBytes!) : FileImage(_image!);
    }
    return const AssetImage('assets/images/profile.png');
  }
}
