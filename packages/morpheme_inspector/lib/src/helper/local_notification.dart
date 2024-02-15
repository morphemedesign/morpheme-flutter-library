import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Instance class for local notification functionality.
final class LocalNotification {
  /// Wrap the package [FlutterLocalNotificationsPlugin].
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  /// Specifies the icon for notifications.
  final String notificationIcon;

  /// Function for handle if notification selected.
  final void Function(NotificationResponse) onSelectedNotification;

  LocalNotification({
    required this.notificationIcon,
    required this.onSelectedNotification,
  }) {
    _initializeNotificationsPlugin();
  }

  /// Initialize provides cross-platform functionality for displaying local notifications.
  void _initializeNotificationsPlugin() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await _requestPermissions();

    final initializationSettingsAndroid =
        AndroidInitializationSettings(notificationIcon);
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectedNotification,
    );
  }

  /// It requests permission from the user to display notifications
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: false,
          );
    } else if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Function for show local notification with given [message]
  Future<void> showLocalNotification(String message) async {
    const channelId = 'Morpheme Inspector';
    const channelName = 'Morpheme Inspector';
    const channelDescription = 'Morpheme Inspector';
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      enableVibration: false,
      playSound: false,
      styleInformation: BigTextStyleInformation(message),
    );
    const darwinPlatformChannelSpecifics = DarwinNotificationDetails(
      presentSound: false,
      presentAlert: false,
      presentBadge: false,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      'morpheme_inspector'.hashCode,
      'Morpheme Inspector',
      message,
      platformChannelSpecifics,
      payload: 'morpheme_inspector',
    );
  }
}
