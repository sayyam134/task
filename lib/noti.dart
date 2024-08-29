import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings("@mipmap/ic_launcher");

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  Future showNotification({
    int id = 0,
    String title = "Task Reminder",
    String? body,
    String? payload,
  }) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  Future schdeuleNotification(
      {required int id,
      String title = "Task Reminder",
      String? body,
      String? payload,
      required DateTime? scheduleDateTime}) async {
    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      //tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      tz.TZDateTime.from(scheduleDateTime!, tz.local),
      await notificationDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel_id',
        'Reminder Notifications',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      ),
    );
  }

  Future<void> cancelNotifications(int id) async {
    await notificationsPlugin.cancel(id);
  }
}
