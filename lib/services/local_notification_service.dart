import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  static const String incomingCallChannelId = 'connectcall_incoming_calls';
  static const int incomingCallNotificationId = 7801;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize({
    required void Function(NotificationResponse response) onNotificationTap,
  }) async {
    if (_isInitialized) return;
    _isInitialized = true;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        incomingCallChannelId,
        'Incoming Calls',
        description: 'Notifications for incoming ConnectCall audio and video calls.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showIncomingCall({
    required String callerName,
    required bool isVideoCall,
    required String payload,
  }) {
    final androidDetails = AndroidNotificationDetails(
      incomingCallChannelId,
      'Incoming Calls',
      channelDescription: 'Notifications for incoming ConnectCall audio and video calls.',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      actions: const [
        AndroidNotificationAction('decline', 'Decline', showsUserInterface: true, cancelNotification: true),
        AndroidNotificationAction('accept', 'Accept', showsUserInterface: true, cancelNotification: true),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return _plugin.show(
      incomingCallNotificationId,
      isVideoCall ? 'Incoming video call' : 'Incoming audio call',
      callerName,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  Future<void> dismissIncomingCall() {
    return _plugin.cancel(incomingCallNotificationId);
  }
}
