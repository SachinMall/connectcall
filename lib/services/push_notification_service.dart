import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (_) {
    return;
  }

  if (message.data['type'] != 'incoming_call') return;

  await LocalNotificationService.instance.initialize(onNotificationTap: (_) {});
  await LocalNotificationService.instance.showIncomingCall(
    callerName: message.data['callerName'] ?? 'Unknown',
    isVideoCall: message.data['mediaType'] == 'video',
    payload: message.data['callId'] ?? '',
  );
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await LocalNotificationService.instance.initialize(onNotificationTap: (_) {});

    FirebaseMessaging.onMessage.listen((message) {
      if (message.data['type'] != 'incoming_call') return;
    });
  }
}
