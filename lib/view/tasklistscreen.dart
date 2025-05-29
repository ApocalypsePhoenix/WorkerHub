import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workerhub/myconfig.dart';
import 'package:workerhub/model/user.dart';
import 'package:workerhub/model/work.dart';
import 'package:workerhub/view/submittaskscreen.dart';

class TaskListScreen extends StatefulWidget {
  final User user;
  const TaskListScreen({super.key, required this.user});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Work> taskList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final workerId = widget.user.userId;
    if (workerId == null || workerId == "0") {
      setState(() {
        taskList = [];
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/workerhub/php/get_works.php"),
        body: {"worker_id": workerId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            taskList = data.map((item) => Work.fromJson(item)).toList();
            isLoading = false;
          });
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed to load tasks: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTaskCard(Work work) {
    final isCompleted = work.status == "success";

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green : Colors.orange,
          child: const Icon(Icons.assignment, color: Colors.white),
        ),
        title: Text(
          work.title ?? "No Title",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(work.description ?? "No Description"),
            const SizedBox(height: 4),
            Text("Due: ${work.dueDate ?? "-"}"),
            const SizedBox(height: 4),
            Text(
              "Status: ${work.status ?? "Unknown"}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        trailing: isCompleted ? null : const Icon(Icons.arrow_forward_ios),
        onTap: isCompleted
            ? null
            : () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubmitTaskScreen(
                      user: widget.user,
                      work: work,
                    ),
                  ),
                );
                if (result == true) {
                  loadTasks(); // Refresh the list after submission
                }
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Tasks",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade800,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskList.isEmpty
              ? const Center(child: Text("No tasks assigned."))
              : RefreshIndicator(
                  onRefresh: loadTasks,
                  child: ListView.builder(
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(taskList[index]);
                    },
                  ),
                ),
    );
  }
}
