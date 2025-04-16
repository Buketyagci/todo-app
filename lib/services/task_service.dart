import 'package:firebase_database/firebase_database.dart';

class TaskService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<List<Map<dynamic, dynamic>>> loadTasks(String userId) async {
    List<Map<dynamic, dynamic>> taskList = [];
    try {
      DatabaseEvent event = await _database.child('users/$userId/tasks').once();
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          taskList.add({
            'id': key,
            ...value, 
          });
        });
      }
    } catch (e) {
      print("Error fetching tasks: $e");
    }
    return taskList; 
  }
}
