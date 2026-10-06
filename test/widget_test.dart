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

  testWidgets('form berita menambah berita baru', (tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    appState.login(kDemoFingerNo, kDemoPassword);
    appState.go('news');
    await tester.pumpWidget(const PortalApp());
    await tester.pump();

    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    expect(find.text('Berita baru'), findsOneWidget);

    // Judul kosong ditolak.
    await tester.tap(find.text('Terbitkan'));
    await tester.pump();
    expect(find.text('Judul wajib diisi.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Judul tes');
    await tester.enterText(find.byType(TextField).at(1), 'Isi tes');
    await tester.tap(find.text('Terbitkan'));
    await tester.pumpAndSettle();

    expect(appState.posts.first.title, 'Judul tes');
    expect(find.text('Judul tes'), findsOneWidget);

    // Di luar web, hanya isi berita yang bisa diblok.
    expect(find.byType(SelectionArea), findsNothing);
    await tester.tap(find.text('Judul tes'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectionArea), findsOneWidget);
  });

  testWidgets('form event dan survey menambah data baru', (tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    appState.login(kDemoFingerNo, kDemoPassword);
    appState.go('events');
    await tester.pumpWidget(const PortalApp());
    await tester.pump();

    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    // Pemilih tanggal ikut bahasa aplikasi.
    await tester.tap(find.byIcon(Icons.event_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Event tes');
    await tester.enterText(find.byType(TextField).at(1), 'Aula');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(appState.events.last.title, 'Event tes');
    expect(find.text('Event tes'), findsOneWidget);

    appState.go('survey');
    await tester.pump();
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Survey tes');
    await tester.enterText(find.byType(TextField).at(3), 'Pilih satu?');
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Pertanyaan 1 butuh minimal 2 pilihan jawaban.'),
        findsOneWidget);

    await tester.enterText(find.byType(TextField).at(4), 'Ya, Tidak');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    final survey = appState.surveys.first;
    expect(survey.title, 'Survey tes');
    expect(survey.questions.single.options, ['Ya', 'Tidak']);
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
