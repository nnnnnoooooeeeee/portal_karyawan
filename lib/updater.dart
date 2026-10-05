import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'l10n.dart';
import 'widgets.dart';

/// Repo GitHub tempat APK dirilis. Update diambil dari rilis terbarunya.
const String kUpdateRepo = 'nnnnnoooooeeeee/portal_karyawan';

/// Dipasang di MaterialApp supaya dialog update bisa muncul dari mana saja.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool get updateSupported =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

Future<String>? _version;

Future<String> appVersion() =>
    _version ??= PackageInfo.fromPlatform().then((p) => p.version);

class UpdateInfo {
  final String version, current, apkUrl;
  const UpdateInfo(this.version, this.current, this.apkUrl);
}

/// Mengubah 'v1.2.3' atau '1.2.3' menjadi [1, 2, 3]. Tag yang bukan nomor
/// versi (misalnya 'build-7') menghasilkan null.
List<int>? _parseVersion(String v) {
  final m = RegExp(r'^v?(\d+(?:\.\d+)*)').firstMatch(v.trim());
  if (m == null) return null;
  return m.group(1)!.split('.').map(int.parse).toList();
}

bool _isNewer(List<int> a, List<int> b) {
  for (var i = 0; i < a.length || i < b.length; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

/// Mengembalikan info update, atau null kalau aplikasi sudah versi terbaru.
/// Melempar error kalau pemeriksaan gagal (misalnya tidak ada internet).
Future<UpdateInfo?> fetchUpdate() async {
  final res = await http.get(
    Uri.parse('https://api.github.com/repos/$kUpdateRepo/releases/latest'),
    headers: {'Accept': 'application/vnd.github+json'},
  ).timeout(const Duration(seconds: 15));
  if (res.statusCode == 404) return null; // Belum ada rilis.
  if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');

  final release = jsonDecode(res.body) as Map<String, dynamic>;
  final tag = (release['tag_name'] ?? '').toString();
  final current = await appVersion();
  final latest = _parseVersion(tag);
  final installed = _parseVersion(current);
  if (latest == null || installed == null) return null;
  if (!_isNewer(latest, installed)) return null;

  for (final a in (release['assets'] as List? ?? const [])) {
    final asset = a as Map<String, dynamic>;
    if ((asset['name'] ?? '').toString().endsWith('.apk')) {
      return UpdateInfo(
        latest.join('.'),
        current,
        asset['browser_download_url'].toString(),
      );
    }
  }
  return null;
}

/// Memeriksa update dan menampilkan dialog kalau ada versi baru.
/// Dengan [manual] (tombol "Cek update"), hasil lain juga diberitahukan.
Future<void> checkForUpdate({bool manual = false}) async {
  void say(String key) {
    final context = navigatorKey.currentContext;
    if (manual && context != null) toast(context, tr(key));
  }

  if (!updateSupported) return say('update_unsupported');

  UpdateInfo? info;
  try {
    info = await fetchUpdate();
  } catch (_) {
    return say('update_check_failed');
  }
  if (info == null) return say('up_to_date');

  final context = navigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  final found = info;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UpdateDialog(found),
  );
}

enum _Stage { ask, downloading, installing, failed }

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo info;
  const _UpdateDialog(this.info);

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  _Stage _stage = _Stage.ask;
  int _percent = 0;
  String _errorKey = 'update_failed';
  StreamSubscription<OtaEvent>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _fail([String key = 'update_failed']) {
    _sub?.cancel();
    if (!mounted) return;
    setState(() {
      _stage = _Stage.failed;
      _errorKey = key;
    });
  }

  void _start() {
    setState(() {
      _stage = _Stage.downloading;
      _percent = 0;
    });
    try {
      _sub = OtaUpdate()
          .execute(widget.info.apkUrl,
              destinationFilename: 'portal-karyawan.apk')
          .listen(
        (e) {
          if (!mounted) return;
          switch (e.status) {
            case OtaStatus.DOWNLOADING:
              setState(
                  () => _percent = int.tryParse(e.value ?? '') ?? _percent);
            case OtaStatus.INSTALLING:
            case OtaStatus.INSTALLATION_DONE:
              setState(() => _stage = _Stage.installing);
            case OtaStatus.ALREADY_RUNNING_ERROR:
              break;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              _fail('update_permission');
            default:
              _fail();
          }
        },
        onError: (_) => _fail(),
      );
    } catch (_) {
      _fail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final close = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(tr(_stage == _Stage.ask ? 'later' : 'close')),
    );
    final update = FilledButton(
      onPressed: _start,
      child: Text(tr('update_now')),
    );

    Widget content;
    List<Widget> actions;
    switch (_stage) {
      case _Stage.ask:
        content = Text(tr('update_body',
            {'new': info.version, 'current': info.current}));
        actions = [close, update];
      case _Stage.downloading:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(tr('update_downloading', {'p': _percent})),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: _percent / 100,
                minHeight: 8,
              ),
            ),
          ],
        );
        actions = const [];
      case _Stage.installing:
        content = Text(tr('update_installing'));
        actions = [close];
      case _Stage.failed:
        content = Text(tr(_errorKey));
        actions = [close, update];
    }

    return PopScope(
      canPop: _stage != _Stage.downloading,
      child: AlertDialog(
        title: Text(tr('update_title')),
        content: content,
        actions: actions,
      ),
    );
  }
}
