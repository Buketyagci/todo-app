import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todoapp/list.dart';
import 'package:todoapp/main.dart';
import 'package:todoapp/screens/addtask/add_new_task.dart';
import 'package:todoapp/services/auth.dart';
import 'package:todoapp/services/task_service.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DatabaseReference ref;
  String username = "";
  final Auth auth = Auth();
  final TaskService taskService = TaskService();
  List<Map<dynamic, dynamic>> tasks = [];
  bool isLoading = true;
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _getUserId();
  }

  void _loadUsername() async {
    String? user = await Auth().getUserName();
    setState(() {
      username = user ?? "User";
    });
  }

  void _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      _loadTasks(userId);
    }
  }

  void _loadTasks(String userId) async {
    List<Map<dynamic, dynamic>> taskData = await taskService.loadTasks(userId);
    print("Firebase data: $taskData");
    setState(() {
      tasks = taskData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal,
        title: Text(
          username.isNotEmpty ? "$username's Tasks" : "Tasks",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.teal.shade100,
              size: 40,
            ),
          ),
        ],
      ),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator()
                : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(width: 16),
                            Container(child: myTextRich()),
                            SizedBox(width: 10),
                            addIconButton(context),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:
                            tasks.isEmpty
                                ? [
                                  Text(
                                    "No task found",
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ]
                                : tasks.map((task) {
                                  return myContainer(task);
                                }).toList(),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget myTextRich() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "Today ",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextSpan(
            text:
                "${weekDays[DateTime.now().weekday - 1]} - ${months[DateTime.now().month - 1]} ${DateTime.now().day}${DateTime.now().day == 1 || DateTime.now().day == 21 || DateTime.now().day == 31
                    ? "st"
                    : DateTime.now().day == 2 || DateTime.now().day == 22
                    ? "nd"
                    : DateTime.now().day == 3 || DateTime.now().day == 23
                    ? "rd"
                    : "th"}",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget addIconButton(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddNewTask()),
        );

        if (result == true && userId.isNotEmpty) {
          _loadTasks(userId);
        }
      },
      icon: Icon(Icons.add),
      color: Colors.teal.shade100,
      iconSize: 40,
    );
  }

  Widget myContainer(Map<dynamic, dynamic> task) {
    bool isCompleted = task['completed'] == true;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Title(
                      color: Colors.black,
                      child: Text(
                        task['title'] ?? "No title",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat(
                            'yyyy-MM-dd',
                          ).format(DateTime.parse(task['date'])) +
                          "   " +
                          task['time'],
                    ),
                  ],
                ),
                SizedBox(width: 55),
                IconButton(
                  onPressed: () {
                    _toggleTaskCompletion(task);
                  },
                  icon: Icon(isCompleted ? Icons.close : Icons.check, size: 30),
                ),
                IconButton(
                  onPressed: () {
                    print("Task: $task");
                    _deleteTask(task['id']);
                  },
                  icon: Icon(Icons.delete, size: 30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteTask(String taskId) async {
    try {
      await FirebaseDatabase.instance
          .ref('users/$userId/tasks/$taskId')
          .remove();
      setState(() {
        tasks.removeWhere((task) => task['id'] == taskId);
      });
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  void _toggleTaskCompletion(Map task) async {
    String taskId = task['id'];
    bool currentStatus = task['completed'] == true;
    try {
      await FirebaseDatabase.instance.ref('users/$userId/tasks/$taskId').update(
        {'completed': !currentStatus},
      );
      setState(() {
        task['completed'] = !currentStatus;
      });
    } catch (e) {
      print("Error toggling task: $e");
    }
  }
}
