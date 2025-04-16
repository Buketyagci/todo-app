import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';

class AddNewTask extends StatefulWidget {
  const AddNewTask({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddNewTaskScreen();
  }
}

class _AddNewTaskScreen extends State<AddNewTask> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now(); 
  final TextEditingController titleController = TextEditingController();
  final FirebaseDatabase database = FirebaseDatabase.instance;

  void addTaskToDatabase() async {
    String title = titleController.text;

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lütfen giriş yapın")));
      return;
    }

    String userId = currentUser.uid;
    print(userId);
    print("Veri gönderilmeye çalışılıyor...");

    database
        .ref()
        .child("users")
        .child(userId)
        .child("tasks")
        .push()
        .set({
          "title": title,
          "completed": false,
          "date":
              selectedDate
                  .toIso8601String(), 
          "time":
              "${selectedTime.hour}:${selectedTime.minute}",
        })
        .then((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Task added successfully!")));
          titleController.clear(); 
          Navigator.pop(context, true);
        })
        .catchError((error) {
          print("Hata: $error");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $error")));
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "To-Do App",
      theme: ThemeData(
        primaryColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.teal.shade100,
            iconSize: 40,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Add New Task",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Title(
                          color: Colors.white,
                          child: Text(
                            "Input task title",
                            style: GoogleFonts.poppins(
                              color: Colors.amber,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      textFormFieldTitle(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 8,
                        ),
                        child: Title(
                          color: Colors.white,
                          child: Text(
                            "Choose to-do time",
                            style: GoogleFonts.poppins(
                              color: Colors.amber,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final DateTime? dateTime = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(3000),
                            );
                            if (dateTime != null) {
                              setState(() {
                                selectedDate = dateTime;
                              });
                            }
                          },
                          child: Icon(
                            Icons.calendar_today,
                            color: Colors.teal,
                            size: 24,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "${selectedDate.year} - ${selectedDate.month} - ${selectedDate.day}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                              initialEntryMode: TimePickerEntryMode.dial,
                            );
                            if (timeOfDay != null) {
                              setState(() {
                                selectedTime = timeOfDay;
                              });
                            }
                          },
                          child: Icon(
                            Icons.alarm,
                            color: Colors.teal,
                            size: 30,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "${selectedTime.hour} : ${selectedTime.minute < 10 ? '0${selectedTime.minute}' : selectedTime.minute}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: addTaskButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton addTaskButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
          side: BorderSide(color: Colors.teal, width: 4),
        ),
      ),
      onPressed: () {
        addTaskToDatabase();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 30),
              Text(
                "Confirm",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.amberAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 15),
              Icon(Icons.check, color: Colors.teal, size: 40),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField textFormFieldTitle() {
    return TextFormField(
      controller: titleController,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Input task title",
        hintStyle: GoogleFonts.poppins(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal.shade100, width: 3),
        ),
      ),
      minLines: 3,
      maxLines: null,
    );
  }
}
