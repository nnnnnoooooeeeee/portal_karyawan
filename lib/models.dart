class AppUser {
  String name, email, password, employeeNo, department, position;

  AppUser({
    required this.name,
    required this.email,
    required this.password,
    this.employeeNo = '',
    this.department = '',
    this.position = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'employeeNo': employeeNo,
        'department': department,
        'position': position,
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        password: (j['password'] ?? '').toString(),
        employeeNo: (j['employeeNo'] ?? '').toString(),
        department: (j['department'] ?? '').toString(),
        position: (j['position'] ?? '').toString(),
      );

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'Kamu' : parts.first;
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

class LeaveRequest {
  final String id, email, type, reason;
  final DateTime start, end;
  String status;

  LeaveRequest({
    required this.id,
    required this.email,
    required this.type,
    required this.reason,
    required this.start,
    required this.end,
    this.status = 'Menunggu persetujuan',
  });

  int get days => end.difference(start).inDays + 1;
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

const List<String> kBulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];
const List<String> kBulanPendek = [
  'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN',
  'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES',
];
const List<String> kHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

String fmtDate(DateTime d) => '${d.day} ${kBulan[d.month - 1]} ${d.year}';

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
  if (diff.inMinutes < 1) return 'baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays == 1) return 'kemarin';
  if (diff.inDays < 30) return '${diff.inDays} hari lalu';
  return fmtDate(t);
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
