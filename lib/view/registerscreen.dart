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
  Uint8List? webImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Register", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade800,
                leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                        image: _buildImageProvider(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(nameController, "Full Name"),
                _buildTextField(emailController, "Email", keyboardType: TextInputType.emailAddress),
                _buildTextField(passwordController, "Password", obscure: true),
                _buildTextField(confirmPasswordController, "Confirm Password", obscure: true),
                _buildTextField(phoneController, "Phone", keyboardType: TextInputType.phone),
                _buildTextField(addressController, "Address", maxLines: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Register", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, bool obscure = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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

  ImageProvider _buildImageProvider() {
    if (_image != null) {
      return FileImage(_image!);
    } else if (webImage != null) {
      return MemoryImage(webImage!);
    } else {
      return const AssetImage("assets/images/camera.png");
    }
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
                _selectImage(ImageSource.camera);
              },
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _selectImage(ImageSource.gallery);
              },
              child: const Text("Gallery"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : source,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      if (kIsWeb) {
        webImage = await picked.readAsBytes();
      } else {
        _image = File(picked.path);
      }
      setState(() {});
    }
  }

  void registerUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();

    if ([name, email, password, confirmPassword, phone, address].contains("")) {
      _showSnack("Please fill all fields");
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showSnack("Enter a valid email");
      return;
    }
    if (password != confirmPassword) {
      _showSnack("Passwords do not match");
      return;
    }

    String base64Image = "";
    String filename = "";

    if (_image != null || webImage != null) {
      base64Image = base64Encode(kIsWeb ? webImage! : await _image!.readAsBytes());
      filename = "$email.png";
    }

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/workerhub/php/register_worker.php"),
      body: {
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        "address": address,
        "image": base64Image,
        "filename": filename,
      },
    );

    final res = jsonDecode(response.body);
    if (res['status'] == 'success') {
      _showSnack("Registered successfully!");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      _showSnack(res['message'] ?? "Failed to register");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
