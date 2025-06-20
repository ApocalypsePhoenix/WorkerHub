import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workerhub/model/user.dart';
import 'package:workerhub/myconfig.dart';
import 'package:workerhub/view/registerscreen.dart';
import 'package:workerhub/view/mainscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset("assets/images/workerhub.png", scale: 3.5),
            const SizedBox(height: 16),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField("Email", emailController, TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField("Password", passwordController, TextInputType.visiblePassword, obscure: true),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          activeColor: Colors.green,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value!;
                            });
                            if (isChecked &&
                                (emailController.text.isEmpty || passwordController.text.isEmpty)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill all fields"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              setState(() {
                                isChecked = false;
                              });
                            } else {
                              storeCredentials(emailController.text, passwordController.text, isChecked);
                            }
                          },
                        ),
                        const Text("Remember Me"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: loginUser,
                        child: const Text("Login", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text("Register an account?", style: TextStyle(color: Colors.green, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType inputType,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green.shade700),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void loginUser() {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill all fields"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    http.post(Uri.parse("${MyConfig.myurl}/workerhub/php/login_worker.php"), body: {
      "email": email,
      "password": password,
    }).then((response) {
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'success') {
          var userdata = jsondata['data'];
          User user = User.fromJson(userdata[0]);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => MainScreen(user: user)),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }

  Future<void> storeCredentials(String email, String password, bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      await prefs.setString('email', email);
      await prefs.setString('pass', password);
      await prefs.setBool('remember', isChecked);
    } else {
      await prefs.remove('email');
      await prefs.remove('pass');
      await prefs.remove('remember');
    }
  }

  Future<void> loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('pass');
    bool? remember = prefs.getBool('remember');
    if (email != null && password != null && remember == true) {
      emailController.text = email;
      passwordController.text = password;
      setState(() {
        isChecked = true;
      });
    }
  }
}
