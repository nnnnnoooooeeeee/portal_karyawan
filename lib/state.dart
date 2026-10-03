import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// State aplikasi untuk proof of concept.
/// Semua data ada di memori. Hanya akun, sesi login, dan pilihan tema
/// yang disimpan di perangkat lewat shared_preferences.
class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  List<AppUser> users = [];
  AppUser? user;
  ThemeMode themeMode = ThemeMode.system;

  String page = 'home';
  String newsQuery = '';

  static const int leaveQuota = 12;
  static const int leaveUsedBefore = 4;

  late final List<Post> posts = _seedPosts();
  late final List<EventItem> events = _seedEvents();
  late final List<Survey> surveys = _seedSurveys();
  late final List<Payslip> payslips = _seedPayslips();
  final List<LeaveRequest> leaveRequests = [];
  final List<String> notifications = [
    'Slip gaji bulan lalu sudah tersedia.',
    'Ada survey baru yang menunggu jawabanmu.',
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
            .toList();
      }
      final theme = _prefs!.getString('theme');
      if (theme == 'light') themeMode = ThemeMode.light;
      if (theme == 'dark') themeMode = ThemeMode.dark;
    } catch (_) {
      // Penyimpanan tidak tersedia: lanjut dengan data di memori saja.
    }
    if (!users.any((u) => u.email == 'demo@perusahaan.com')) {
      users.add(AppUser(
        name: 'Karyawan Demo',
        email: 'demo@perusahaan.com',
        password: 'demo123',
        employeeNo: 'EMP-0001',
        department: 'Umum',
        position: 'Staf',
      ));
    }
    try {
      final session = _prefs?.getString('session');
      if (session != null) {
        for (final u in users) {
          if (u.email == session) user = u;
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

  /// Mengembalikan pesan error, atau null kalau berhasil.
  String? login(String email, String password) {
    final e = email.trim().toLowerCase();
    for (final u in users) {
      if (u.email == e) {
        if (u.password != password) return 'Kata sandi salah.';
        user = u;
        page = 'home';
        try {
          _prefs?.setString('session', u.email);
        } catch (_) {}
        notifyListeners();
        return null;
      }
    }
    return 'Email belum terdaftar.';
  }

  String? register({
    required String name,
    required String email,
    required String password,
    required String employeeNo,
  }) {
    final e = email.trim().toLowerCase();
    if (name.trim().isEmpty) return 'Nama wajib diisi.';
    if (!e.contains('@') || !e.contains('.')) {
      return 'Format email tidak valid.';
    }
    if (password.length < 6) return 'Kata sandi minimal 6 karakter.';
    if (users.any((u) => u.email == e)) return 'Email sudah terdaftar.';
    users.add(AppUser(
      name: name.trim(),
      email: e,
      password: password,
      employeeNo: employeeNo.trim(),
    ));
    _saveUsers();
    return login(e, password);
  }

  void logout() {
    user = null;
    page = 'home';
    try {
      _prefs?.remove('session');
    } catch (_) {}
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String department,
    required String position,
  }) {
    final u = user;
    if (u == null) return;
    if (name.trim().isNotEmpty) u.name = name.trim();
    u.department = department.trim();
    u.position = position.trim();
    _saveUsers();
    notifyListeners();
  }

  // ---------- Navigasi dan tema ----------

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

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Pagi';
    if (h < 15) return 'Siang';
    if (h < 19) return 'Sore';
    return 'Malam';
  }

  // ---------- Berita ----------

  void toggleLike(Post p) {
    final e = user!.email;
    if (p.likes.contains(e)) {
      p.likes.remove(e);
    } else {
      p.likes.add(e);
    }
    notifyListeners();
  }

  void addComment(Post p, String text) {
    if (text.trim().isEmpty) return;
    p.comments.add(Comment(user!.name, text.trim(), DateTime.now()));
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
    final e = user!.email;
    if (ev.going.contains(e)) {
      ev.going.remove(e);
      notifications.insert(0, 'Kamu batal ikut "${ev.title}".');
    } else {
      ev.going.add(e);
      notifications.insert(0, 'Kamu terdaftar di "${ev.title}".');
    }
    notifyListeners();
  }

  // ---------- Survey ----------

  List<Survey> get pendingSurveys =>
      surveys.where((s) => !s.answeredBy.contains(user!.email)).toList();

  void submitSurvey(Survey s) {
    s.answeredBy.add(user!.email);
    notifications.insert(0, 'Terima kasih sudah mengisi "${s.title}".');
    notifyListeners();
  }

  // ---------- Cuti ----------

  List<LeaveRequest> get myLeave =>
      leaveRequests.where((r) => r.email == user!.email).toList();

  int get leaveRemaining {
    var used = leaveUsedBefore;
    for (final r in myLeave) {
      if (r.type == 'Cuti Tahunan' && r.status != 'Dibatalkan') used += r.days;
    }
    return leaveQuota - used;
  }

  String? requestLeave({
    required String type,
    required DateTime start,
    required DateTime end,
    required String reason,
  }) {
    if (end.isBefore(start)) {
      return 'Tanggal selesai harus setelah tanggal mulai.';
    }
    final days = end.difference(start).inDays + 1;
    if (type == 'Cuti Tahunan' && days > leaveRemaining) {
      return 'Sisa cuti tahunan tidak cukup.';
    }
    leaveRequests.insert(
      0,
      LeaveRequest(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        email: user!.email,
        type: type,
        reason: reason.trim(),
        start: start,
        end: end,
      ),
    );
    notifications.insert(0, 'Pengajuan $type ($days hari) terkirim.');
    notifyListeners();
    return null;
  }

  void cancelLeave(LeaveRequest r) {
    r.status = 'Dibatalkan';
    notifyListeners();
  }

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
