import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background notification: ${message.messageId}');
}

class PushNotificationsService {
  PushNotificationsService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'ecommerce_notifications',
    'Ecommerce notifications',
    description: 'Notifications for purchases and Firebase campaigns.',
    importance: Importance.high,
  );

  static bool _isInitialized = false;

  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _localNotifications;

  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_isInitialized) {
      debugPrint('Push notifications already initialized. Refreshing token.');
      await saveCurrentUserToken();
      return;
    }

    debugPrint('Initializing push notifications.');
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');

    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');
    await _saveToken(token);

    _messaging.onTokenRefresh.listen(_saveToken);

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
        'Foreground notification: '
        '${message.notification?.title} - ${message.notification?.body}',
      );
      showLocalNotificationFromRemoteMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Notification opened: ${message.data}');
    });

    _isInitialized = true;
  }

  Future<void> saveCurrentUserToken() async {
    if (kIsWeb) return;

    final token = await _messaging.getToken();
    debugPrint('Saving current FCM token: $token');
    await _saveToken(token);
  }

  Future<void> showLocalNotificationFromRemoteMessage(
    RemoteMessage message,
  ) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) return;

    await showLocalNotification(
      title: title ?? 'Ecommerce',
      body: body ?? '',
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    return _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> _saveToken(String? token) async {
    final user = _auth.currentUser;
    if (user == null || token == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    debugPrint('FCM token saved for user: ${user.uid}');
  }
}
