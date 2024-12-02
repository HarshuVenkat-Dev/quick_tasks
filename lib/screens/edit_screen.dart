import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:quick_task/screens/home_screen.dart';

class EditTaskScreen extends StatelessWidget {
  final Task task;
  final TextEditingController titleController;
  final TextEditingController dueDateController;

  EditTaskScreen({required this.task})
      : titleController = TextEditingController(text: task.title),
        dueDateController =
            TextEditingController(text: task.dueDate.toIso8601String());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: task.dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      dueDateController.text = pickedDate.toIso8601String();
    }
  }

  Future<bool> updateTask(
      String objectId, String title, DateTime dueDate) async {
    final parseObject = ParseObject('Task')
      ..objectId = objectId
      ..set('title', title)
      ..set('dueDate', dueDate);

    final response = await parseObject.save();
    return response.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Edit Task Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            TextFormField(
              controller: dueDateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                labelText: 'Due Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            //SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final updatedTitle = titleController.text.trim();
                final updatedDueDate =
                    DateTime.parse(dueDateController.text.trim());

                final success = await updateTask(
                    task.objectId, updatedTitle, updatedDueDate);

                if (success) {
                  Navigator.pop(
                      context, true); // Go back after successful update
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update task.')),
                  );
                }
              },
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
