import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _notifications.initialize(settings);
  }

  static Future<void> sendPrescriptionNotification(String patientName) async {
    const androidDetails = AndroidNotificationDetails(
      'prescription_channel',
      'Prescriptions',
      channelDescription: 'Notifications for new prescriptions',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_notification', // 🔥 your custom logo
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      0,
      "New Prescription",
      "Doctor has added a prescription for $patientName",
      notificationDetails,
    );
  }

  static Future<void> scheduleMedicationReminder(int id, String medName, String timeStr) async {
    // Basic scheduling example
    // In a real app, you'd parse timeStr (e.g., 'Morning (8 AM)') into a specific time of day
    // For demonstration, we'll schedule it 5 seconds from now to show it works
    
    const androidDetails = AndroidNotificationDetails(
      'med_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders to take your medication',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_notification', 
    );

    await _notifications.zonedSchedule(
      id,
      "Medication Reminder",
      "Time to take your $medName",
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)), // 10 seconds for demo
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
