import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

// ---------------------------------------------------------------- Layanan

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final pending = appState.pendingSurveys.length;

    Widget tile(String title, String sub, IconData icon, Color bg, Color fg,
        String page) {
      return AppCard(
        color: bg,
        onTap: () => appState.go(page),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: fg,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  Text(sub, style: TextStyle(color: fg)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: fg),
          ],
        ),
      );
    }

    return PageBody(
      children: [
        const PageHeader('Layanan', subtitle: 'Semua urusanmu di satu tempat'),
        ...spaced([
          tile('Cuti', 'Sisa ${appState.leaveRemaining} hari',
              Icons.beach_access_rounded, c.hero, Colors.white, 'leave'),
          tile('Slip Gaji', 'Lihat rincian gaji bulanan',
              Icons.account_balance_wallet_rounded, c.sky, kInkOnSky, 'payslip'),
          tile(
              'Survey',
              pending > 0 ? '$pending survey menunggu' : 'Semua sudah diisi',
              Icons.fact_check_rounded,
              c.pop,
              c.onPop,
              'survey'),
        ], 12),
      ],
    );
  }
}

// ------------------------------------------------------------------- Cuti

/// Kartu navy berisi sisa cuti tahunan.
class LeaveHero extends StatelessWidget {
  final bool compact;
  final bool showButton;
  const LeaveHero({super.key, this.compact = false, this.showButton = true});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final remaining = appState.leaveRemaining;
    final progress = (remaining / AppState.leaveQuota).clamp(0.0, 1.0);

    final number = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$remaining',
          style: TextStyle(
            color: c.sky,
            fontSize: compact ? 40 : 56,
            height: 1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'dari ${AppState.leaveQuota} hari',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );

    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: kNavy,
      ),
      onPressed: () => appState.go('leave'),
      child: Text(compact ? 'Ajukan' : 'Ajukan cuti'),
    );

    final label = Text(
      'Sisa cuti tahunan',
      style: TextStyle(
          color: c.heroSub, fontSize: 14, fontWeight: FontWeight.w700),
    );

    return AppCard(
      color: c.hero,
      child: compact
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [label, const SizedBox(height: 4), number],
                  ),
                ),
                if (showButton) button,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                label,
                const SizedBox(height: 10),
                number,
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0x2EFFFFFF),
                    valueColor: AlwaysStoppedAnimation<Color>(c.sky),
                  ),
                ),
                if (showButton) ...[const SizedBox(height: 16), button],
              ],
            ),
    );
  }
}

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  static const _types = ['Cuti Tahunan', 'Sakit', 'Izin'];
  String _type = _types.first;
  DateTime? _start;
  DateTime? _end;
  final _reason = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isStart) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = (isStart ? _start : _end) ?? _start ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today.subtract(const Duration(days: 30)),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end == null || _end!.isBefore(picked)) _end = picked;
      } else {
        _end = picked;
      }
    });
  }

  void _submit() {
    final start = _start;
    final end = _end;
    if (start == null || end == null) {
      setState(() => _error = 'Pilih tanggal mulai dan selesai.');
      return;
    }
    final err = appState.requestLeave(
      type: _type,
      start: start,
      end: end,
      reason: _reason.text,
    );
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _error = null;
      _start = null;
      _end = null;
      _reason.clear();
    });
    toast(context, 'Pengajuan terkirim.');
  }

  Widget _dateButton(String label, DateTime? value, bool isStart) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _pick(isStart),
        icon: const Icon(Icons.calendar_today_rounded, size: 18),
        label: Text(
          value == null ? label : fmtDate(value),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final requests = appState.myLeave;

    return PageBody(
      children: [
        const PageHeader('Cuti', backTo: 'services'),
        LeaveHero(showButton: false),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Ajukan cuti',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _types)
                    ChoiceChip(
                      label: Text(t),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _dateButton('Tanggal mulai', _start, true),
                  const SizedBox(width: 10),
                  _dateButton('Tanggal selesai', _end, false),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reason,
                maxLines: 2,
                decoration: fieldDeco(context, 'Alasan (opsional)'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton(
                  onPressed: _submit, child: const Text('Kirim pengajuan')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Riwayat pengajuan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (requests.isEmpty)
          Text('Belum ada pengajuan.', style: TextStyle(color: c.muted)),
        ...spaced([
          for (final r in requests)
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.type}, ${r.days} hari',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          sameDay(r.start, r.end)
                              ? fmtDate(r.start)
                              : '${fmtDate(r.start)} sampai ${fmtDate(r.end)}',
                          style: TextStyle(color: c.muted, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Tag(r.status),
                      ],
                    ),
                  ),
                  if (r.status == 'Menunggu persetujuan')
                    TextButton(
                      onPressed: () => appState.cancelLeave(r),
                      child: const Text('Batalkan'),
                    ),
                ],
              ),
            ),
        ], 12),
      ],
    );
  }
}

// -------------------------------------------------------------- Slip gaji

class PayslipPage extends StatefulWidget {
  const PayslipPage({super.key});

  @override
  State<PayslipPage> createState() => _PayslipPageState();
}

class _PayslipPageState extends State<PayslipPage> {
  int _open = 0;
  bool _show = false;

  String _money(int v) => _show ? fmtRupiah(v) : 'Rp ••••••';

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final slips = appState.payslips;

    Widget line(String label, String value, {bool bold = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
            ),
            Text(value,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ],
        ),
      );
    }

    return PageBody(
      children: [
        const PageHeader('Slip Gaji',
            subtitle: 'Angka di bawah hanya data contoh', backTo: 'services'),
        AppCard(
          color: c.tint,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Icon(_show ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: c.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Tampilkan nominal',
                    style:
                        TextStyle(color: c.ink, fontWeight: FontWeight.w700)),
              ),
              Switch(
                value: _show,
                onChanged: (v) => setState(() => _show = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...spaced([
          for (var i = 0; i < slips.length; i++)
            AppCard(
              onTap: () => setState(() => _open = _open == i ? -1 : i),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${kBulan[slips[i].month - 1]} ${slips[i].year}',
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                            Text('Diterima: ${_money(slips[i].net)}',
                                style: TextStyle(color: c.muted)),
                          ],
                        ),
                      ),
                      Icon(_open == i
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded),
                    ],
                  ),
                  if (_open == i) ...[
                    Divider(height: 28, color: c.line),
                    Text('PENDAPATAN',
                        style: TextStyle(
                            color: c.muted,
                            fontSize: 12,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800)),
                    for (final it in slips[i].items)
                      if (!it.deduction) line(it.label, _money(it.amount)),
                    const SizedBox(height: 10),
                    Text('POTONGAN',
                        style: TextStyle(
                            color: c.muted,
                            fontSize: 12,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800)),
                    for (final it in slips[i].items)
                      if (it.deduction) line(it.label, _money(it.amount)),
                    Divider(height: 28, color: c.line),
                    line('Total pendapatan', _money(slips[i].gross)),
                    line('Total potongan', _money(slips[i].deductions)),
                    line('Gaji diterima', _money(slips[i].net), bold: true),
                  ],
                ],
              ),
            ),
        ], 12),
      ],
    );
  }
}

// ----------------------------------------------------------------- Survey

class SurveyPage extends StatelessWidget {
  const SurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final email = appState.user!.email;

    return PageBody(
      children: [
        const PageHeader('Survey',
            subtitle: 'Suaramu membantu perusahaan jadi lebih baik',
            backTo: 'services'),
        ...spaced([
          for (final s in appState.surveys)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(s.description, style: TextStyle(color: c.muted)),
                  const SizedBox(height: 4),
                  Text(
                    '${s.questions.length} pertanyaan, sekitar ${s.minutes} menit',
                    style: TextStyle(color: c.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  if (s.answeredBy.contains(email))
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Tag('Sudah diisi'),
                    )
                  else
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => SurveyFill(s)),
                      ),
                      child: const Text('Isi survey'),
                    ),
                ],
              ),
            ),
        ], 12),
      ],
    );
  }
}

class SurveyFill extends StatefulWidget {
  final Survey survey;
  const SurveyFill(this.survey, {super.key});

  @override
  State<SurveyFill> createState() => _SurveyFillState();
}

class _SurveyFillState extends State<SurveyFill> {
  final Map<int, String> _choice = {};
  final Map<int, int> _rating = {};
  final Map<int, TextEditingController> _text = {};
  String? _error;

  @override
  void dispose() {
    for (final t in _text.values) {
      t.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final qs = widget.survey.questions;
    for (var i = 0; i < qs.length; i++) {
      final missing = (qs[i].type == 'choice' && !_choice.containsKey(i)) ||
          (qs[i].type == 'rating' && !_rating.containsKey(i));
      if (missing) {
        setState(() => _error = 'Pertanyaan ${i + 1} belum dijawab.');
        return;
      }
    }
    appState.submitSurvey(widget.survey);
    toast(context, 'Jawabanmu tersimpan. Terima kasih!');
    Navigator.of(context).pop();
  }

  Widget _question(BuildContext context, int i, SurveyQuestion q) {
    final c = AppColors.of(context);
    Widget input;
    if (q.type == 'choice') {
      input = Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final o in q.options)
            ChoiceChip(
              label: Text(o),
              selected: _choice[i] == o,
              onSelected: (_) => setState(() => _choice[i] = o),
            ),
        ],
      );
    } else if (q.type == 'rating') {
      final value = _rating[i] ?? 0;
      input = Row(
        children: [
          for (var star = 1; star <= 5; star++)
            IconButton(
              tooltip: '$star dari 5',
              onPressed: () => setState(() => _rating[i] = star),
              iconSize: 34,
              icon: Icon(
                star <= value ? Icons.star_rounded : Icons.star_border_rounded,
                color: star <= value ? c.pop : c.muted,
              ),
            ),
        ],
      );
    } else {
      final controller = _text.putIfAbsent(i, () => TextEditingController());
      input = TextField(
        controller: controller,
        maxLines: 3,
        decoration: fieldDeco(context, 'Jawabanmu (opsional)'),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${i + 1}. ${q.text}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          input,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final qs = widget.survey.questions;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        title: const Text('Survey'),
      ),
      body: SafeArea(
        child: PageBody(
          children: [
            Text(
              widget.survey.title,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, height: 1.2),
            ),
            const SizedBox(height: 4),
            Text(widget.survey.description, style: TextStyle(color: c.muted)),
            const SizedBox(height: 16),
            ...spaced([
              for (var i = 0; i < qs.length; i++) _question(context, i, qs[i]),
            ], 12),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: _submit, child: const Text('Kirim jawaban')),
          ],
        ),
      ),
    );
  }
}
