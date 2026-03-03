import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
}
