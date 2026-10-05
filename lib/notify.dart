import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'l10n.dart';

final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();
bool _ready = false;

/// Menampilkan notifikasi percobaan di HP.
/// Mengembalikan kunci terjemahan untuk pesan hasilnya.
Future<String> showTestNotification() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return 'notif_unsupported';
  }
  try {
    if (!_ready) {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      _ready = true;
    }
    // Android 13 ke atas butuh izin dari pengguna sebelum notifikasi tampil.
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    if (granted == false) return 'notif_denied';

    await _plugin.show(
      id: 1,
      title: tr('notif_test_title'),
      body: tr('notif_test_body'),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          tr('notif_test_title'),
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    return 'notif_sent';
  } catch (_) {
    return 'notif_failed';
  }
}
