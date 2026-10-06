import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n.dart';
import 'models.dart';

const String kDemoFingerNo = '1001';
const String kDemoPassword = 'demo123';

/// State aplikasi untuk proof of concept.
/// Semua data ada di memori. Hanya akun, sesi login, pilihan tema, dan
/// pilihan bahasa yang disimpan di perangkat lewat shared_preferences.
class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  List<AppUser> users = [];
  AppUser? user;
  ThemeMode themeMode = ThemeMode.system;

  String page = 'home';
  String newsQuery = '';

  static const int leaveQuota = 12;
  static const int leaveUsed = 4;

  late final List<Post> posts = _seedPosts();
  late final List<EventItem> events = _seedEvents();
  late final List<Survey> surveys = _seedSurveys();
  late final List<Payslip> payslips = _seedPayslips();
  final List<AppNote> notifications = [
    const AppNote('note_payslip_ready'),
    const AppNote('note_new_survey'),
  ];

  // ---------- Penyimpanan ----------

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString('users');
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        users = list
            .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e as Map)))
            // Akun lama yang dibuat dengan email tidak punya no. finger,
            // jadi tidak bisa dipakai login lagi.
            .where((u) => u.fingerNo.isNotEmpty)
            .toList();
      }
      final theme = _prefs!.getString('theme');
      if (theme == 'light') themeMode = ThemeMode.light;
      if (theme == 'dark') themeMode = ThemeMode.dark;
      final lang = _prefs!.getString('lang');
      if (lang != null) setCurrentLanguage(lang);
    } catch (_) {
      // Penyimpanan tidak tersedia: lanjut dengan data di memori saja.
    }
    if (!users.any((u) => u.fingerNo == kDemoFingerNo)) {
      users.add(AppUser(
        name: 'Karyawan Demo',
        nik: '12341001',
        fingerNo: kDemoFingerNo,
        password: kDemoPassword,
        department: 'IT',
        position: 'Staf',
      ));
    }
    try {
      final session = _prefs?.getString('session');
      if (session != null) {
        for (final u in users) {
          if (u.fingerNo == session) user = u;
        }
      }
    } catch (_) {}
  }

  void _saveUsers() {
    try {
      _prefs?.setString(
          'users', jsonEncode(users.map((u) => u.toJson()).toList()));
    } catch (_) {}
  }

  // ---------- Akun ----------

  /// No. finger karyawan yang sedang login, dipakai sebagai penanda
  /// siapa yang menyukai berita, ikut event, atau mengisi survey.
  String get uid => user!.fingerNo;

  /// Mengembalikan pesan error, atau null kalau berhasil.
  String? login(String fingerNo, String password) {
    final f = fingerNo.trim();
    for (final u in users) {
      if (u.fingerNo == f) {
        if (u.password != password) return tr('err_wrong_password');
        user = u;
        page = 'home';
        try {
          _prefs?.setString('session', u.fingerNo);
        } catch (_) {}
        notifyListeners();
        return null;
      }
    }
    return tr('err_finger_unknown');
  }

  String? register({
    required String name,
    required String nik,
    required String fingerNo,
    required String department,
    required String position,
    required String password,
  }) {
    final f = fingerNo.trim();
    if (name.trim().isEmpty) return tr('err_name_required');
    if (f.isEmpty) return tr('err_finger_required');
    if (password.length < 6) return tr('err_password_short');
    if (users.any((u) => u.fingerNo == f)) return tr('err_finger_taken');
    users.add(AppUser(
      name: name.trim(),
      nik: nik.trim(),
      fingerNo: f,
      password: password,
      department: department.trim(),
      position: position.trim(),
    ));
    _saveUsers();
    return login(f, password);
  }

  void logout() {
    user = null;
    page = 'home';
    try {
      _prefs?.remove('session');
    } catch (_) {}
    notifyListeners();
  }

  // ---------- Navigasi, tema, dan bahasa ----------

  void go(String id) {
    page = id;
    notifyListeners();
  }

  void search(String q) {
    newsQuery = q.trim();
    page = 'news';
    notifyListeners();
  }

  void setNewsQuery(String q) {
    newsQuery = q.trim();
    notifyListeners();
  }

  void setTheme(ThemeMode m) {
    themeMode = m;
    final name = m == ThemeMode.light
        ? 'light'
        : (m == ThemeMode.dark ? 'dark' : 'system');
    try {
      _prefs?.setString('theme', name);
    } catch (_) {}
    notifyListeners();
  }

  void toggleTheme(Brightness current) {
    setTheme(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setLanguage(String code) {
    setCurrentLanguage(code);
    try {
      _prefs?.setString('lang', currentLanguage.code);
    } catch (_) {}
    notifyListeners();
  }

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 11) return tr('greet_morning');
    if (h < 15) return tr('greet_midday');
    if (h < 19) return tr('greet_afternoon');
    return tr('greet_night');
  }

  // ---------- Berita ----------

  void toggleLike(Post p) {
    if (p.likes.contains(uid)) {
      p.likes.remove(uid);
    } else {
      p.likes.add(uid);
    }
    notifyListeners();
  }

  void addComment(Post p, String text) {
    if (text.trim().isEmpty) return;
    p.comments.add(Comment(user!.name, text.trim(), DateTime.now()));
    notifyListeners();
  }

  void addPost({
    required String title,
    required String body,
    required String category,
    bool pinned = false,
  }) {
    // Ditaruh paling depan supaya langsung muncul di beranda.
    posts.insert(
      0,
      Post(
        id: 'p${posts.length + 1}',
        title: title.trim(),
        body: body.trim(),
        category: category,
        author: user!.name,
        time: DateTime.now(),
        pinned: pinned,
      ),
    );
    notifyListeners();
  }

  // ---------- Event ----------

  List<EventItem> get upcomingEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final list = events.where((e) => !e.start.isBefore(today)).toList();
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  void toggleGoing(EventItem ev) {
    if (ev.going.contains(uid)) {
      ev.going.remove(uid);
      notifications.insert(0, AppNote('note_event_cancel', {'title': ev.title}));
    } else {
      ev.going.add(uid);
      notifications.insert(0, AppNote('note_event_join', {'title': ev.title}));
    }
    notifyListeners();
  }

  EventItem addEvent({
    required String title,
    required String description,
    required String location,
    required DateTime start,
  }) {
    final ev = EventItem(
      id: 'e${events.length + 1}',
      title: title.trim(),
      description: description.trim(),
      location: location.trim(),
      start: start,
    );
    events.add(ev);
    notifyListeners();
    return ev;
  }

  // ---------- Survey ----------

  List<Survey> get pendingSurveys =>
      surveys.where((s) => !s.answeredBy.contains(uid)).toList();

  void addSurvey({
    required String title,
    required String description,
    required int minutes,
    required List<SurveyQuestion> questions,
  }) {
    surveys.insert(
      0,
      Survey(
        id: 's${surveys.length + 1}',
        title: title.trim(),
        description: description.trim(),
        minutes: minutes,
        questions: questions,
      ),
    );
    notifyListeners();
  }

  void submitSurvey(Survey s) {
    s.answeredBy.add(uid);
    notifications.insert(0, AppNote('note_survey_thanks', {'title': s.title}));
    notifyListeners();
  }

  // ---------- Cuti ----------

  /// Karyawan hanya bisa melihat sisa cuti, tidak mengajukan dari aplikasi.
  int get leaveRemaining => leaveQuota - leaveUsed;

  // ---------- Data contoh ----------

  List<Post> _seedPosts() {
    final now = DateTime.now();
    return [
      Post(
        id: 'p1',
        title: 'Jadwal libur nasional dan cuti bersama',
        body:
            'Ini contoh pengumuman yang disematkan. Isi lengkap pengumuman dari HR tampil di sini, termasuk daftar tanggal dan ketentuannya.',
        category: 'Pengumuman',
        author: 'Tim HR',
        time: now.subtract(const Duration(days: 2)),
        pinned: true,
      ),
      Post(
        id: 'p2',
        title: 'Selamat datang untuk karyawan baru bulan ini',
        body:
            'Ini contoh berita perusahaan. Paragraf pembuka menjelaskan inti berita, lalu diikuti detailnya. Karyawan bisa menyukai dan mengomentari berita ini.',
        category: 'Berita',
        author: 'Tim HR',
        time: now.subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 'p3',
        title: 'Perubahan jam operasional kantin',
        body:
            'Ini contoh postingan umum. Informasi singkat seperti perubahan jadwal atau fasilitas cocok ditaruh di kategori ini.',
        category: 'Umum',
        author: 'General Affair',
        time: now.subtract(const Duration(days: 1)),
      ),
      Post(
        id: 'p4',
        title: 'Tips menjaga keamanan akun kerja',
        body:
            'Ini contoh berita dari tim IT. Gunakan kata sandi yang berbeda untuk tiap layanan dan jangan bagikan kode verifikasi ke siapa pun.',
        category: 'Berita',
        author: 'Tim IT',
        time: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  List<EventItem> _seedEvents() {
    final now = DateTime.now();
    DateTime at(int addDays, int hour) =>
        DateTime(now.year, now.month, now.day + addDays, hour);
    return [
      EventItem(
        id: 'e1',
        title: 'Town hall kuartal',
        description: 'Paparan pencapaian kuartal dan sesi tanya jawab.',
        location: 'Aula utama',
        start: at(3, 9),
      ),
      EventItem(
        id: 'e2',
        title: 'Pelatihan keselamatan kerja',
        description: 'Pelatihan wajib untuk seluruh karyawan produksi.',
        location: 'Ruang pelatihan',
        start: at(9, 13),
      ),
      EventItem(
        id: 'e3',
        title: 'Olahraga bersama',
        description: 'Senam pagi dan futsal antar departemen.',
        location: 'Lapangan',
        start: at(9, 7),
      ),
      EventItem(
        id: 'e4',
        title: 'Kelas berbagi: dasar Excel',
        description: 'Sesi belajar santai dari rekan kerja untuk rekan kerja.',
        location: 'Ruang rapat 2',
        start: at(16, 15),
      ),
      EventItem(
        id: 'e5',
        title: 'Gathering akhir bulan',
        description: 'Makan bersama dan pengumuman karyawan teladan.',
        location: 'Kantin',
        start: at(27, 17),
      ),
    ];
  }

  List<Survey> _seedSurveys() {
    return [
      Survey(
        id: 's1',
        title: 'Kepuasan fasilitas kantor',
        description:
            'Bantu kami memperbaiki fasilitas yang kamu pakai tiap hari.',
        minutes: 3,
        questions: const [
          SurveyQuestion(
              'Seberapa puas kamu dengan fasilitas kantor?', 'rating'),
          SurveyQuestion(
              'Fasilitas mana yang paling perlu diperbaiki?',
              'choice',
              ['Kantin', 'Toilet', 'Area parkir', 'Ruang istirahat']),
          SurveyQuestion('Ada saran lain?', 'text'),
        ],
      ),
      Survey(
        id: 's2',
        title: 'Pilihan kegiatan gathering',
        description: 'Pilih kegiatan yang paling kamu inginkan.',
        minutes: 1,
        questions: const [
          SurveyQuestion('Kegiatan apa yang kamu pilih?', 'choice',
              ['Outbound', 'Wisata kuliner', 'Turnamen olahraga']),
        ],
      ),
    ];
  }

  List<Payslip> _seedPayslips() {
    final now = DateTime.now();
    const items = [
      PayItem('Gaji pokok', 6000000),
      PayItem('Tunjangan transport', 500000),
      PayItem('Tunjangan makan', 400000),
      PayItem('BPJS Kesehatan', 60000, deduction: true),
      PayItem('BPJS Ketenagakerjaan', 120000, deduction: true),
      PayItem('PPh 21', 150000, deduction: true),
    ];
    final list = <Payslip>[];
    for (var i = 1; i <= 3; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      list.add(Payslip(d.year, d.month, items));
    }
    return list;
  }
}

final AppState appState = AppState();
