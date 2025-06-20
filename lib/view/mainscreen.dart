import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workerhub/model/user.dart';
import 'package:workerhub/myconfig.dart';
import 'package:workerhub/view/aboutscreen.dart';
import 'package:workerhub/view/loginscreen.dart';
import 'package:workerhub/view/profilescreen.dart';
import 'package:workerhub/view/submissionhistoryscreen.dart';
import 'package:workerhub/view/tasklistscreen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int completedTasks = 0;
  int totalTasks = 0;
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _fetchTaskProgress();
  }

  void _loadProfileImage() {
    if (widget.user.userId != "0") {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        profileImageUrl =
            "${MyConfig.myurl}/workerhub/assets/images/profiles/${widget.user.userId}.png?v=$timestamp";
      });
    }
  }

  Future<void> _fetchTaskProgress() async {
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/workerhub/php/task_progress.php"),
        body: {"worker_id": widget.user.userId ?? "0"},
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          completedTasks = data['completed'];
          totalTasks = data['total'];
        });
      }
    } catch (e) {
      // Ignore fetch error for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = widget.user.userId == "0";

    final List<Widget> _screens = [
      _buildHomeScreen(),
      TaskListScreen(user: widget.user),
      SubmissionHistoryScreen(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green.shade800),
              accountName: Text(widget.user.userName ?? "Guest"),
              accountEmail: Text(widget.user.userEmail ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundImage: isGuest
                    ? const AssetImage("assets/images/profile.png")
                        as ImageProvider
                    : NetworkImage(profileImageUrl),
              ),
            ),
            if (!isGuest)
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(user: widget.user)),
                  );
                  _loadProfileImage();
                },
              ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
            const Spacer(),
            if (!isGuest)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("WorkerHub",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade800,
        actions: [
          if (!isGuest)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _loadProfileImage();
                _fetchTaskProgress();
              },
            )
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: isGuest
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: Colors.green.shade800,
              unselectedItemColor: Colors.grey,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.history), label: "History"),
              ],
            ),
    );
  }

  Widget _buildHomeScreen() {
    final isGuest = widget.user.userId == "0";
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: isGuest
                  ? const AssetImage("assets/images/profile.png")
                      as ImageProvider
                  : NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome, ${widget.user.userName ?? 'Guest'}!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isGuest
                  ? "Please Login/Register to access our features"
                  : "We're glad to have you here at WorkerHub.",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (isGuest)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text("Login / Register",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              )
            else ...[
              if (totalTasks > 0)
                Column(
                  children: [
                    Text(
                      "You have completed $completedTasks / $totalTasks tasks",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.green.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green.shade800),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
