import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portal_karyawan/l10n.dart';
import 'package:portal_karyawan/main.dart';
import 'package:portal_karyawan/state.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    setCurrentLanguage('id');
    await appState.load();
    if (appState.user != null) appState.logout();
  });

  test('semua bahasa punya kunci yang sama dengan bahasa bawaan', () {
    final base = kLanguages.first.text.keys.toSet();
    for (final l in kLanguages) {
      expect(l.text.keys.toSet(), base, reason: 'bahasa ${l.code}');
    }
  });

  test('login memakai no. finger', () {
    expect(appState.login('9999', kDemoPassword), tr('err_finger_unknown'));
    expect(appState.login(kDemoFingerNo, 'salah'), tr('err_wrong_password'));
    expect(appState.login(kDemoFingerNo, kDemoPassword), isNull);
    expect(appState.user!.fingerNo, kDemoFingerNo);
  });

  testWidgets('keluar meminta konfirmasi dan bahasa bisa diganti',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    appState.login(kDemoFingerNo, kDemoPassword);
    appState.go('profile');
    await tester.pumpWidget(const PortalApp());
    await tester.pump();

    // Profil menampilkan data karyawan, tanpa email dan tanpa tombol ubah.
    expect(find.text('No. finger'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(find.text('Ubah profil'), findsNothing);

    await tester.tap(find.text('English'));
    await tester.pump();
    expect(find.text('Fingerprint no.'), findsOneWidget);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out of your account?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(appState.user, isNotNull);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();
    expect(appState.user, isNull);
  });
}
