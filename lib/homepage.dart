import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'noti.dart';

final List<String> activities = [
  'Wake up',
  'Go to gym',
  'Breakfast',
  'Meetings',
  'Lunch',
  'Quick nap',
  'Go to library',
  'Dinner',
  'Go to sleep',
];
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class TaskController extends GetxController {
  var reminders = <TaskReminder>[].obs;
}

class TaskReminder {
  final int taskID;
  final String day;
  final TimeOfDay time;
  final String activity;

  TaskReminder({
    required this.taskID,
    required this.day,
    required this.time,
    required this.activity,
  });
}

class HomePage extends StatelessWidget {
  final TaskController controller = Get.put(TaskController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Reminder'),
      ),
      body: Obx(() {
        if (controller.reminders.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: () => _showAddReminderDialog(context),
              child: Text('Add Reminder'),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.reminders.length,
          itemBuilder: (context, index) {
            final reminder = controller.reminders[index];
            return ListTile(
              title: Text(
                  '${reminder.day} ${reminder.time.format(context)} - ${reminder.activity}'),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddReminderDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return _AddReminderDialog();
      },
    );
  }
}

class _AddReminderDialog extends StatefulWidget {
  @override
  __AddReminderDialogState createState() => __AddReminderDialogState();
}

class __AddReminderDialogState extends State<_AddReminderDialog> {
  final dayController = TextEditingController();
  TimeOfDay? selectedTime;
  final activityController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Permission.notification.request();
    NotificationService().initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Reminder'),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInputField(
              label: 'Day of the Week',
              child: DropdownButtonFormField<String>(
                items: [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday'
                ]
                    .map(
                        (day) => DropdownMenuItem(value: day, child: Text(day)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    dayController.text = value ?? '';
                  });
                },
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            _buildInputField(
              label: 'Choose Time',
              child: ListTile(
                title: Text(selectedTime != null
                    ? selectedTime!.format(context)
                    : 'Choose Time'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
              ),
            ),
            _buildInputField(
              label: 'Choose Activity',
              child: DropdownButtonFormField<String>(
                items: activities
                    .map((activity) => DropdownMenuItem(
                        value: activity, child: Text(activity)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    activityController.text = value ?? '';
                  });
                },
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (selectedTime != null) {
              final newReminder = TaskReminder(
                taskID: DateTime.now().year+DateTime.now().month+DateTime.now().day+Random().nextInt(1440),
                day: dayController.text,
                time: selectedTime!,
                activity: activityController.text,
              );
              final TaskController controller = Get.find();
              controller.reminders.add(newReminder);
              PermissionStatus notificationStatus =
                  await Permission.notification.request();
              if (notificationStatus == PermissionStatus.granted) {
                NotificationService().showNotification(
                    title: "New Reminder: ${newReminder.activity} is added.!");
                NotificationService().schdeuleNotification(
                    id: newReminder.taskID,
                    body: "Reminder of ${newReminder.activity}",
                    scheduleDateTime: DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        newReminder.time.hour,
                        newReminder.time.minute));
                print("working");
              }
              if (notificationStatus == PermissionStatus.denied) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ther permission is denied")));
                print("Not working");
              }
              if (notificationStatus == PermissionStatus.permanentlyDenied) {
                openAppSettings();
              }
              Get.back();
            } else {
              // Handle case where no time is selected
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select a time')),
              );
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Widget _buildInputField({required String label, required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
