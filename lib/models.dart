import 'l10n.dart';

class AppUser {
  String name, nik, fingerNo, password, department, position;

  AppUser({
    required this.name,
    required this.fingerNo,
    required this.password,
    this.nik = '',
    this.department = '',
    this.position = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'nik': nik,
        'fingerNo': fingerNo,
        'password': password,
        'department': department,
        'position': position,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        name: (j['name'] ?? '').toString(),
        // 'employeeNo' adalah nama lama untuk NIK di data yang tersimpan.
        nik: (j['nik'] ?? j['employeeNo'] ?? '').toString(),
        fingerNo: (j['fingerNo'] ?? '').toString(),
        password: (j['password'] ?? '').toString(),
        department: (j['department'] ?? '').toString(),
        position: (j['position'] ?? '').toString(),
      );

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? tr('you') : parts.first;
  }

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final a = parts.first[0];
    final b = parts.length > 1 ? parts.last[0] : '';
    return (a + b).toUpperCase();
  }
}

class Comment {
  final String author, text;
  final DateTime time;
  Comment(this.author, this.text, this.time);
}

class Post {
  final String id, title, body, category, author;
  final DateTime time;
  final bool pinned;
  final Set<String> likes = {};
  final List<Comment> comments = [];

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.author,
    required this.time,
    this.pinned = false,
  });
}

class EventItem {
  final String id, title, description, location;
  final DateTime start;
  final Set<String> going = {};

  EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.start,
  });
}

class SurveyQuestion {
  final String text;

  /// 'choice', 'rating', atau 'text'
  final String type;
  final List<String> options;
  const SurveyQuestion(this.text, this.type, [this.options = const []]);
}

class Survey {
  final String id, title, description;
  final int minutes;
  final List<SurveyQuestion> questions;
  final Set<String> answeredBy = {};

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.minutes,
    required this.questions,
  });
}

/// Satu baris di daftar notifikasi dalam aplikasi. Teksnya disimpan sebagai
/// kunci terjemahan supaya ikut berubah saat bahasa diganti.
class AppNote {
  final String key;
  final Map<String, Object> args;
  const AppNote(this.key, [this.args = const {}]);

  String get text => tr(key, args);
}

class PayItem {
  final String label;
  final int amount;
  final bool deduction;
  const PayItem(this.label, this.amount, {this.deduction = false});
}

class Payslip {
  final int year, month;
  final List<PayItem> items;
  const Payslip(this.year, this.month, this.items);

  int get gross {
    var total = 0;
    for (final i in items) {
      if (!i.deduction) total += i.amount;
    }
    return total;
  }

  int get deductions {
    var total = 0;
    for (final i in items) {
      if (i.deduction) total += i.amount;
    }
    return total;
  }

  int get net => gross - deductions;
}

List<String> get monthNames => tr('months').split(',');
List<String> get monthNamesShort => tr('months_short').split(',');
List<String> get dayNames => tr('days').split(',');

String fmtDate(DateTime d) => '${d.day} ${monthNames[d.month - 1]} ${d.year}';

String fmtTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

String fmtRupiah(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp $b';
}

String timeAgo(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return tr('just_now');
  if (diff.inMinutes < 60) return tr('minutes_ago', {'n': diff.inMinutes});
  if (diff.inHours < 24) return tr('hours_ago', {'n': diff.inHours});
  if (diff.inDays == 1) return tr('yesterday');
  if (diff.inDays < 30) return tr('days_ago', {'n': diff.inDays});
  return fmtDate(t);
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
