import 'package:flutter/material.dart';

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
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: appState.themeMode,
          home: appState.user == null ? const AuthScreen() : const Shell(),
        );
      },
    );
  }
}
