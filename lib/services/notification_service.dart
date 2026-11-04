import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static StreamSubscription<String>? _registrationSubscription;

  static Future<void> initialize() async {
    // Request notification permission.
    final messaging = FirebaseMessaging.instance;
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // On iOS, wait until the APNs token is available
    // before making FCM token-related requests.
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final apnsToken = await messaging.getAPNSToken();
      if (apnsToken == null) {
        debugPrint('APNs token is not available yet. Retry later.');
        return;
      }
    }

    _registrationSubscription = messaging.onRegistered.listen(
      (String installationId) {},
      onError: (Object error) {},
    );

    await messaging.register(
      vapidKey: 'BCnxATMbe7J7TzSKy40tNdnVzpEaueg78X4zcVwARDPjN71GKmgaPd7KpMCDUcLPPsSr_lMC8Y9S8khTZVLFN6M',
      serviceWorkerScriptPath: kIsWeb ? '/firebase-messaging-sw.js' : null,
    );
  }

  static Future<void> dispose() async {
    await _registrationSubscription?.cancel();
  }
}
