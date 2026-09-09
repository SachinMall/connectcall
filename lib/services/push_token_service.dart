import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushTokenService {
  PushTokenService._();
  static final PushTokenService instance = PushTokenService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> registerTokenForUser(String userId) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(userId, token);
    }

    _messaging.onTokenRefresh.listen((refreshedToken) {
      _saveToken(userId, refreshedToken);
    });
  }

  Future<void> _saveToken(String userId, String token) {
    return _firestore.collection('users').doc(userId).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }

  Future<void> clearTokenForUser(String userId) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _firestore.collection('users').doc(userId).set(
      {'fcmToken': FieldValue.delete()},
      SetOptions(merge: true),
    );
  }
}
