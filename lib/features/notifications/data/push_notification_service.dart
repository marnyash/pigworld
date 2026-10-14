import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../app/routes/app_router.dart';
import '../../../app/routes/app_routes.dart';

class PushNotificationService {
  PushNotificationService(this._dio);

  final Dio _dio;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _started = false;
  bool _authenticated = false;
  String? _registeredToken;

  Future<void> registerDevice() async {
    _authenticated = true;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Push notifications are disabled by the user.');
      return;
    }
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _handleLocalNotificationOpened,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'farm_push_notifications',
            'Farm notifications',
            description: 'Updates and reminders for your farm.',
            importance: Importance.high,
            playSound: true,
          ),
        );

    if (!_started) {
      _started = true;
      messaging.onTokenRefresh.listen(
        (token) {
          if (_authenticated) {
            unawaited(
              _registerToken(token).catchError((Object error) {
                debugPrint('Push-token registration failed: $error');
              }),
            );
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Push-token refresh failed: $error');
        },
      );
      FirebaseMessaging.onMessage.listen((message) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          unawaited(
            _showForegroundMessage(message).catchError((Object error) {
              debugPrint('Foreground push display failed: $error');
            }),
          );
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) _handleOpenedMessage(initialMessage);
    }

    final token = await messaging.getToken();
    if (token != null) await _registerToken(token);
  }

  Future<void> unregisterDevice() async {
    _authenticated = false;
    final token = _registeredToken;
    if (token == null) return;
    await _dio.delete<void>('/auth/push-token', data: {'token': token});
    _registeredToken = null;
  }

  Future<void> _registerToken(String token) async {
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    await _dio.post<void>(
      '/auth/push-token',
      data: {'token': token, 'platform': platform},
    );
    _registeredToken = token;
  }

  Future<void> _showForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      id:
          (message.messageId?.hashCode ??
              DateTime.now().millisecondsSinceEpoch) &
          0x7fffffff,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'farm_push_notifications',
          'Farm notifications',
          channelDescription: 'Updates and reminders for your farm.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      payload: message.data['action_route'] as String?,
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    _openRoute(message.data['action_route']);
  }

  void _handleLocalNotificationOpened(NotificationResponse response) {
    _openRoute(response.payload);
  }

  void _openRoute(Object? route) {
    AppRouter.router.go(switch (route) {
      AppRoutes.support => AppRoutes.support,
      AppRoutes.feed => AppRoutes.feed,
      _ => AppRoutes.notifications,
    });
  }
}
