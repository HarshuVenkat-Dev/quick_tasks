import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';


class TaskService {
  // Method to create a new task
  Future<ParseObject?> createTask(String title, DateTime dueDate) async {
    final task = ParseObject('Task')
      ..set('title', title)
      ..set('dueDate', dueDate)
      ..set('isCompleted', false);

    final response = await task.save();
    if (response.success) {
      print('Task created: ${response.result}');
      return response.result;
    } else {
      print('Error creating task: ${response.error?.message}');
      return null;
    }
  }

    // Method to fetch all tasks
  

  // Method to toggle task completion status
  Future<bool> toggleTaskStatus(String objectId, bool currentStatus) async {
    final task = ParseObject('Task')..objectId = objectId;
    task.set('isCompleted', !currentStatus);

    final response = await task.save();
    if (response.success) {
      print('Task updated successfully');
      return true;
    } else {
      print('Error updating task: ${response.error?.message}');
      return false;
    }
  }

  // Method to delete a task
  Future<bool> deleteTask(String objectId) async {
    final task = ParseObject('Task')..objectId = objectId;

    final response = await task.delete();
    if (response.success) {
      print('Task deleted successfully');
      return true;
    } else {
      print('Error deleting task: ${response.error?.message}');
      return false;
    }
  }
}



