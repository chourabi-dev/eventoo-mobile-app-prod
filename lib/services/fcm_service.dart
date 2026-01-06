import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Request permissions (iOS only)
  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  /// Get current device token
  Future<String?> getDeviceToken() async {
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
    return token;
  }
}
