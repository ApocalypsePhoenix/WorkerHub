import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workerhub/model/user.dart';
import 'package:workerhub/myconfig.dart';
import 'package:workerhub/view/mainscreen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      loadUserCredentials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade700,
              Colors.green.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/workerhub.png", scale: 3.5),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    String password = prefs.getString('pass') ?? '';
    bool rem = prefs.getBool('remember') ?? false;

    if (rem == true) {
      http.post(Uri.parse("${MyConfig.myurl}/workerhub/php/login_worker.php"), body: {
        "email": email,
        "password": password,
      }).then((response) {
        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          if (jsondata['status'] == 'success') {
            var userdata = jsondata['data'];
            User user = User.fromJson(userdata[0]);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
            );
            return;
          }
        }
        navigateAsGuest();
      });
    } else {
      navigateAsGuest();
    }
  }

  void navigateAsGuest() {
    User user = User(
      userId: "0",
      userName: "Guest",
      userEmail: "",
      userPhone: "",
      userAddress: "",
      userPassword: "",
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(user: user)),
    );
  }
}
