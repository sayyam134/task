import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'homepage.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //_initializeNotifications();
  tz.initializeTimeZones();
  runApp(MyApp());
}

// void _initializeNotifications() async {
//   final InitializationSettings initializationSettings = InitializationSettings(
//     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,  // Remove the debug banner
    );
  }
}
