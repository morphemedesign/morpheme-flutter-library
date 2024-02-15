import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:morpheme_inspector/morpheme_inspector.dart';
import 'package:morpheme_inspector/src/extensions/date_time_extensions.dart';
import 'package:morpheme_inspector/src/helper/local_notification.dart';
import 'package:morpheme_inspector/src/helper/shake_detector.dart';
import 'package:morpheme_inspector/src/pages/morpheme_inspector_page.dart';

class MorphemeInspector {
  /// Should inspector be opened on device shake (works only with physical
  /// with sensors).
  final bool showInspectorOnShake;

  /// Should user be notified with notification if there's new request catched.
  final bool showNotification;

  /// Should save new request to local storage. if this false MorphemeInspector
  /// cannot show notification and cannot open with shake device.
  final bool saveInspectorToLocal;

  /// Icon url for notification
  final String notificationIcon;

  ///Flag used to check inspector is opened/dispose
  bool _inspectorOpened = false;

  ShakeDetector? _shakeDetector;
  LocalNotification? _localNotification;
  NavigatorState? _navigatorState;

  /// Creates MorphemeInspector instance.
  MorphemeInspector({
    this.showInspectorOnShake = true,
    this.showNotification = true,
    this.saveInspectorToLocal = true,
    this.notificationIcon = '@mipmap/ic_launcher',
  }) {
    if (showNotification && saveInspectorToLocal) {
      _localNotification = LocalNotification(
        notificationIcon: notificationIcon,
        onSelectedNotification: (notificationResponse) =>
            onSelectedNotification(notificationResponse),
      );
    }
    if (showInspectorOnShake && saveInspectorToLocal) {
      _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: navigateToInspectorPage,
      );
    }
  }

  /// Set custom navigation state. This will help if there's route library.
  void setNavigatorState(NavigatorState navigatorState) =>
      _navigatorState = navigatorState;

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void navigateToInspectorPage() async {
    if (_inspectorOpened) return;
    if (_navigatorState == null) {
      if (kDebugMode) {
        print(
            'Cant start Morpheme Inspector. Please add context with parent NavigatorState to your application');
      }
      return;
    }

    _inspectorOpened = true;
    await _navigatorState?.push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const MorphemeInspectorPage(),
      ),
    );
    _inspectorOpened = false;
  }

  /// Insert [Inspector] to local then show local notification for request http
  Future<void> inspectorRequest(Inspector inspector) async {
    if (!saveInspectorToLocal) return;
    await InspectorService.insert(inspector);
    await showLocalNotification();
  }

  /// Insert [Inspector] to local then show local notification for response http
  Future<void> inspectorResponse(
    String uuid,
    ResponseInspector response,
  ) async {
    if (!saveInspectorToLocal) return;
    await InspectorService.updateResponse(uuid, response);
    await showLocalNotification();
  }

  /// Insert [Inspector] to local then show local notification for timeout http
  Future<void> inspectorResponseTimeout(String uuid) async {
    if (!saveInspectorToLocal) return;
    await InspectorService.updateResponse(
        uuid, ResponseInspector(isTimeout: true));
    await showLocalNotification();
  }

  /// Show local notification
  Future<void> showLocalNotification() async {
    if (!showNotification || !saveInspectorToLocal) return;
    final inspectors = await InspectorService.getAll(limit: 7);
    String message = '';
    for (var element in inspectors) {
      final statusIfTimeout =
          element.response?.isTimeout ?? false ? '! ! !' : '. . .';
      final statusCode = element.response?.status ?? statusIfTimeout;
      final time = element.createdAt.toHHMMSS();
      message += '$time - $statusCode ${element.request.url.path}\n';
    }
    message += '. . .';
    _localNotification?.showLocalNotification(message);
  }

  /// If the notification payload is 'morpheme_inspector', navigate to the inspector page, otherwise, call
  /// the otherSelectedNotification function
  ///
  /// Args:
  ///   notificationResponse (NotificationResponse): The notification response object.
  ///   otherSelectedNotification (void Function(NotificationResponse notificationResponse)?): This is a
  /// callback function that you can use to handle other notifications.
  void onSelectedNotification(
    NotificationResponse notificationResponse, {
    void Function(NotificationResponse notificationResponse)?
        otherSelectedNotification,
  }) {
    if (notificationResponse.payload == 'morpheme_inspector') {
      navigateToInspectorPage();
    } else {
      otherSelectedNotification?.call(notificationResponse);
    }
  }

  /// Close instance, after call onClose shake detector cannot be open MorphemeInspectorPage.
  void onClose() {
    _shakeDetector?.stopListening();
  }
}
