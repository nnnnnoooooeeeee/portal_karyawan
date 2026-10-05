import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

const String _icon = 'icons/Icon-192.png';

/// Menampilkan notifikasi lewat browser (PWA maupun browser desktop).
/// Mengembalikan kunci terjemahan untuk pesan hasilnya.
Future<String> showWebNotification(String title, String body) async {
  // Browser hanya mengizinkan notifikasi di HTTPS atau localhost.
  if (!web.window.isSecureContext) return 'notif_insecure';
  // Misalnya Safari di iPhone sebelum aplikasi dipasang ke layar utama.
  if (!globalContext.has('Notification')) return 'notif_unsupported';

  var permission = web.Notification.permission;
  if (permission == 'default') {
    permission = (await web.Notification.requestPermission().toDart).toDart;
  }
  if (permission != 'granted') return 'notif_denied';

  final options = web.NotificationOptions(body: body, icon: _icon);

  // Chrome di Android menolak `new Notification()`, jadi service worker
  // dicoba lebih dulu. Browser desktop bisa memakai keduanya.
  final registration = await _registration();
  if (registration != null) {
    await registration.showNotification(title, options).toDart;
  } else {
    web.Notification(title, options);
  }
  return 'notif_sent';
}

/// Service worker notifikasi yang sudah aktif, atau null kalau tidak tersedia.
/// Scope-nya dibuat terpisah supaya tidak menimpa service worker Flutter.
Future<web.ServiceWorkerRegistration?> _registration() async {
  if (!web.window.navigator.has('serviceWorker')) return null;
  try {
    final registration = await web.window.navigator.serviceWorker
        .register(
          'notify_sw.js'.toJS,
          web.RegistrationOptions(scope: 'notify/'),
        )
        .toDart;
    for (var i = 0; i < 50 && registration.active == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return registration.active == null ? null : registration;
  } catch (_) {
    return null;
  }
}
