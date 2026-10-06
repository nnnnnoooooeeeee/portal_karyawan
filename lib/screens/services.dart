import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'forms.dart';

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
        PageHeader(tr('nav_services'), subtitle: tr('services_subtitle')),
        ...spaced([
          tile(tr('nav_leave'), tr('leave_left', {'n': appState.leaveRemaining}),
              Icons.beach_access_rounded, c.hero, Colors.white, 'leave'),
          tile(tr('nav_payslip'), tr('payslip_sub'),
              Icons.account_balance_wallet_rounded, c.sky, kInkOnSky, 'payslip'),
          tile(
              tr('nav_survey'),
              pending > 0
                  ? tr('surveys_waiting', {'n': pending})
                  : tr('all_filled'),
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

/// Kartu navy berisi sisa cuti tahunan. Dengan [link], kartu bisa diketuk
/// untuk membuka halaman cuti.
class LeaveHero extends StatelessWidget {
  final bool compact;
  final bool link;
  const LeaveHero({super.key, this.compact = false, this.link = true});

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
        Text(
          tr('leave_of', {'n': AppState.leaveQuota}),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );

    final label = Text(
      tr('leave_remaining'),
      style: TextStyle(
          color: c.heroSub, fontSize: 14, fontWeight: FontWeight.w700),
    );

    return AppCard(
      color: c.hero,
      onTap: link ? () => appState.go('leave') : null,
      child: compact
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [label, const SizedBox(height: 4), number],
                  ),
                ),
                if (link)
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
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
              ],
            ),
    );
  }
}

/// Halaman cuti: hanya menampilkan sisa cuti, tanpa pengajuan.
class LeavePage extends StatelessWidget {
  const LeavePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    Widget line(String label, int days, {bool bold = false}) {
      final weight = bold ? FontWeight.w800 : FontWeight.w600;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(fontWeight: weight))),
            Text(tr('n_days', {'n': days}),
                style: TextStyle(fontWeight: weight)),
          ],
        ),
      );
    }

    return PageBody(
      children: [
        PageHeader(tr('nav_leave'), backTo: 'services'),
        const LeaveHero(link: false),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              line(tr('leave_quota'), AppState.leaveQuota),
              line(tr('leave_used'), AppState.leaveUsed),
              Divider(height: 28, color: c.line),
              line(tr('leave_rest'), appState.leaveRemaining, bold: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          color: c.tint,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: c.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(tr('leave_info'), style: TextStyle(color: c.ink)),
              ),
            ],
          ),
        ),
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
        PageHeader(tr('nav_payslip'),
            subtitle: tr('payslip_subtitle'), backTo: 'services'),
        AppCard(
          color: c.tint,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Icon(_show ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: c.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(tr('show_amounts'),
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
                              '${monthNames[slips[i].month - 1]} ${slips[i].year}',
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                            Text(tr('received', {'v': _money(slips[i].net)}),
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
                    Text(tr('earnings'),
                        style: TextStyle(
                            color: c.muted,
                            fontSize: 12,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800)),
                    for (final it in slips[i].items)
                      if (!it.deduction) line(it.label, _money(it.amount)),
                    const SizedBox(height: 10),
                    Text(tr('deductions'),
                        style: TextStyle(
                            color: c.muted,
                            fontSize: 12,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800)),
                    for (final it in slips[i].items)
                      if (it.deduction) line(it.label, _money(it.amount)),
                    Divider(height: 28, color: c.line),
                    line(tr('total_earnings'), _money(slips[i].gross)),
                    line(tr('total_deductions'), _money(slips[i].deductions)),
                    line(tr('net_pay'), _money(slips[i].net), bold: true),
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
    final uid = appState.uid;

    return PageBody(
      children: [
        PageHeader(
          tr('nav_survey'),
          subtitle: tr('survey_subtitle'),
          backTo: 'services',
          action: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SurveyForm()),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(tr('add')),
          ),
        ),
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
                    tr('survey_meta', {'n': s.questions.length, 'm': s.minutes}),
                    style: TextStyle(color: c.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  if (s.answeredBy.contains(uid))
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Tag(tr('survey_done')),
                    )
                  else
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => SurveyFill(s)),
                      ),
                      child: Text(tr('fill_survey')),
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
        setState(() => _error = tr('question_missing', {'n': i + 1}));
        return;
      }
    }
    appState.submitSurvey(widget.survey);
    toast(context, tr('answers_saved'));
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
              tooltip: tr('rating_of', {'n': star}),
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
        decoration: fieldDeco(context, tr('your_answer')),
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
        title: Text(tr('nav_survey')),
      ),
      body: WebSelectable(
          child: SafeArea(
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
            FilledButton(onPressed: _submit, child: Text(tr('send_answers'))),
          ],
        ),
      )),
    );
  }
}
