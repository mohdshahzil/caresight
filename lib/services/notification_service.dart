import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/medicine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> scheduleMedicineReminders(Medicine medicine) async {
    // Cancel existing notifications for this medicine
    await cancelMedicineReminders(medicine.id);

    for (final medicineTime in medicine.times) {
      if (medicineTime.isEnabled) {
        await _scheduleNotification(medicine, medicineTime);
      }
    }
  }

  Future<void> _scheduleNotification(
    Medicine medicine,
    MedicineTime medicineTime,
  ) async {
    final notificationId = _generateNotificationId(
      medicine.id,
      medicineTime.id,
    );

    final scheduledDate = medicineTime.nextOccurrence;
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Notifications for medicine reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      // sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      playSound: true,
      autoCancel: false,
      ongoing: false,
      styleInformation: BigTextStyleInformation(
        'Take ${medicine.dosage} as prescribed. ${medicine.instructions}',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      '💊 Medicine Reminder',
      '${medicine.name} - ${medicine.dosage}',
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${medicine.id}|${medicineTime.id}',
    );
  }

  Future<void> cancelMedicineReminders(String medicineId) async {
    // Get all pending notifications
    final pendingNotifications =
        await _notifications.pendingNotificationRequests();

    // Cancel notifications for this medicine
    for (final notification in pendingNotifications) {
      if (notification.payload?.startsWith(medicineId) == true) {
        await _notifications.cancel(notification.id);
      }
    }
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  Future<void> showImmediateReminder(
    Medicine medicine,
    MedicineTime time,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      'medicine_immediate',
      'Immediate Medicine Reminders',
      channelDescription: 'Immediate medicine reminder notifications',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation('Take your medicine now!'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '💊 Take Your Medicine Now!',
      '${medicine.name} - ${medicine.dosage}',
      notificationDetails,
      payload: '${medicine.id}|${time.id}|immediate',
    );
  }

  int _generateNotificationId(String medicineId, String timeId) {
    return '${medicineId}_$timeId'.hashCode;
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
