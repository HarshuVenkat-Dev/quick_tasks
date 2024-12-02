import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:quick_task/screens/edit_screen.dart';

class Task {
  final String objectId;
  final String title;
  final DateTime dueDate;
  bool status;

  Task({
    required this.objectId,
    required this.title,
    required this.dueDate,
    required this.status,
  });

  factory Task.fromParse(ParseObject parseObject) {
    print('Fetched ParseObject: ${parseObject.toJson()}');
    return Task(
      objectId: parseObject.objectId!,
      title: parseObject.get<String>('title') ?? '',
      dueDate: parseObject.get<DateTime>('dueDate') ?? DateTime.now(),
      status: parseObject.get<bool>('isCompleted') ?? false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  // final List<Map<String, dynamic>> tasks = [
  //   {'title': 'Buy groceries', 'dueDate': '2024-12-01', 'isCompleted': false},
  //   {'title': 'Study Flutter', 'dueDate': '2024-12-02', 'isCompleted': true},
  // ];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks when the screen initializes
  }

  Future<void> _loadTasks() async {
    final fetchedTasks = await fetchTasks();
    setState(() {
      tasks = fetchedTasks;
    });
  }

  Future<List<Task>> fetchTasks() async {
    try {
      final currentUser = await ParseUser.currentUser();
      print('Current User: $currentUser');
      if (currentUser == null) {
        print('No current user found.');
        return [];
      }

      final query = QueryBuilder(ParseObject('Task'))
        //..whereEqualTo('user', currentUser)
        ..orderByDescending('dueDate');

      final response = await query.query();

      if (response.success && response.results != null) {
        print('Query successful. Results: ${response.results}');
        return (response.results as List<ParseObject>)
            .map((e) => Task.fromParse(e))
            .toList();
      } else {
        print('Error fetching tasks: ${response.error?.message}');
        return [];
      }
    } catch (e) {
      print('Exception fetching tasks: $e');
      return [];
    }
  }

  // Method to delete a task
  Future<bool> deleteTask(String objectId) async {
    print('Object ID from deleteTask: $objectId');

    final task = ParseObject('Task')..objectId = objectId;

    final response = await task.delete();
    print('Delete Response: ${response.error?.message}');

    if (response.success) {
      print('Task deleted successfully');
      return true;
    } else {
      print('Error deleting task: ${response.error?.message}');
      return false;
    }
  }

  // Method to toggle task completion status
  Future<bool> toggleTaskStatus(String objectId, bool currentStatus) async {
    print('Object ID from toggleTaskStatus: $objectId');

    final task = ParseObject('Task')..objectId = objectId;
    task.set('isCompleted', !currentStatus);

    final response = await task.save();
    print('Response: ${response.results}');
    if (response.success) {
      print('Task updated successfully');
      return true;
    } else {
      print('Error updating task: ${response.error?.message}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tasks')),
      body: FutureBuilder<List<Task>>(
        future: fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading tasks'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks available'));
          } else {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  elevation: task.status ? 6 : 2,  //2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: task.status ? Colors.green : Colors.black,
                      ),
                    ),
                    subtitle: Text('Due: ${task.dueDate.toLocal()}',
                        style: TextStyle(color: Colors.grey[700])),
                    leading: CircleAvatar(
                      backgroundColor: task.status ? Colors.green : Colors.red,
                      child: Icon(
                        task.status ? Icons.check : Icons.pending,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task.status,
                          onChanged: (value) async {
                            final success = await toggleTaskStatus(
                                task.objectId, task.status);
                            if (success) {
                              setState(() {
                                task.status = !task.status;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditTaskScreen(task: task),
                              ),
                            ).then((result) {
                              // Check if a task was edited
                              if (result == true) {
                                _loadTasks(); // Reload the tasks to reflect changes
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final success = await deleteTask(task.objectId);
                            if (success) {
                              setState(() {
                                tasks.remove(
                                    task); // Remove the task from the list
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    // /onLongPress: () => deleteTask(task.objectId),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTask');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
