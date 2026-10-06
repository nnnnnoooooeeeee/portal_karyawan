import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n.dart';
import 'screens/auth.dart';
import 'screens/shell.dart';
import 'state.dart';
import 'theme.dart';
import 'updater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Di web, menu klik kanan bawaan browser tidak punya "Salin" untuk teks
  // yang diblok di dalam aplikasi, jadi pakai menu milik Flutter.
  if (kIsWeb) await BrowserContextMenu.disableContextMenu();
  await appState.load();
  runApp(const PortalApp());
  // Sekali tiap aplikasi dibuka: beri tahu kalau ada versi baru.
  WidgetsBinding.instance.addPostFrameCallback((_) => checkForUpdate());
}

class PortalApp extends StatelessWidget {
  const PortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return MaterialApp(
          title: tr('app_name'),
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          // Teks bawaan Flutter (pemilih tanggal dan jam, tombol dialog,
          // menu salin) ikut bahasa yang dipilih di aplikasi.
          locale: Locale(currentLanguage.code),
          supportedLocales: [for (final l in kLanguages) Locale(l.code)],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: appState.themeMode,
          home: appState.user == null ? const AuthScreen() : const Shell(),
        );
      },
    );
  }
}
