import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../repositories/user_repository.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is initialized in main before foreground use. A future server
  // sender can use this hook for background data messages if needed.
}

class MessagingService {
  MessagingService._();

  static final MessagingService instance = MessagingService._();

  final _messaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  String? _registeredUserId;

  Future<void> registerUser({
    required String userId,
    required UserRepository userRepository,
  }) async {
    if (_registeredUserId == userId) return;
    _registeredUserId = userId;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _messaging.setAutoInitEnabled(true);

    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await userRepository.saveMessagingToken(userId: userId, token: token);
    }

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) {
      if (newToken.isEmpty) return;
      userRepository.saveMessagingToken(userId: userId, token: newToken);
    });

    await _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription =
        FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'تنبيه جديد';
      final body = message.notification?.body ??
          message.data['message']?.toString() ??
          'يوجد تحديث يحتاج انتباهك.';
      NotificationService.instance.showInstantNotification(
        title: title,
        body: body,
        payload: message.data['payload']?.toString(),
      );
    });
  }

  Future<void> dispose() async {
    _registeredUserId = null;
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _foregroundMessageSubscription = null;
  }
}
