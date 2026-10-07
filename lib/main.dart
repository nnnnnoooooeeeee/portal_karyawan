import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n.dart';
import 'screens/auth.dart';
import 'screens/shell.dart';
import 'state.dart';
import 'theme.dart';
import 'updater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.load();
  runApp(const PortalApp());
  // Sekali tiap aplikasi dibuka: beri tahu kalau ada versi baru.
  WidgetsBinding.instance.addPostFrameCallback((_) => checkForUpdate());
}

/// Skala tampilan di layar lebar (tablet dan PC). Di bawah 1 = lebih kecil.
const double kDesktopScale = 0.9;

/// Mengecilkan seluruh tampilan di layar lebar, sama seperti zoom out di
/// browser. Aplikasi digambar di kanvas yang lebih besar lalu diperkecil,
/// jadi dialog dan menu ikut mengecil. Di HP tidak diubah.
class _DesktopScale extends StatelessWidget {
  final Widget child;
  const _DesktopScale({required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (mq.size.width < 700) return child;
    return FittedBox(
      child: SizedBox(
        width: mq.size.width / kDesktopScale,
        height: mq.size.height / kDesktopScale,
        child: MediaQuery(
          data: mq.copyWith(
            size: mq.size / kDesktopScale,
            devicePixelRatio: mq.devicePixelRatio * kDesktopScale,
            padding: mq.padding / kDesktopScale,
            viewPadding: mq.viewPadding / kDesktopScale,
            viewInsets: mq.viewInsets / kDesktopScale,
          ),
          child: child,
        ),
      ),
    );
  }
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
          builder: (context, child) => _DesktopScale(child: child!),
          home: appState.user == null ? const AuthScreen() : const Shell(),
        );
      },
    );
  }
}
