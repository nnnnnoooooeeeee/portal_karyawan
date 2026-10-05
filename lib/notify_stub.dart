/// Pengganti notify_web.dart di platform selain web. Tidak pernah dipanggil.
Future<String> showWebNotification(String title, String body) async =>
    'notif_unsupported';
