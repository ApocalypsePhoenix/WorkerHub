import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade800,
                leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset("assets/images/workerhub.png", scale: 2.5),
              ),
              const SizedBox(height: 20),
              const Text(
                "About WorkerHub",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "WorkerHub is a simple mobile system designed to help workers track "
                "their assigned tasks, submit their work, and manage their profile conveniently. "
                "It supports image attachments, submission history, and user profile management.\n\n"
                "This app was developed as part of a student project to demonstrate mobile-backend integration "
                "using Flutter and PHP/MySQL.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Text(
                "Developed by:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 5),
              const Text("Isac Russell Paulbert (297454)", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 40),
              const Text(
                "Version 1.0.0",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
