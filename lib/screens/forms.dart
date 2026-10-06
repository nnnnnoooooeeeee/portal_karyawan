import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'news.dart' show catLabel;

const List<String> kPostCategories = ['Berita', 'Pengumuman', 'Umum'];

/// Kerangka halaman form: judul di app bar, isi form, pesan error, lalu
/// tombol simpan.
class _FormScaffold extends StatelessWidget {
  final String title, submitLabel;
  final String? error;
  final VoidCallback onSubmit;
  final List<Widget> children;

  const _FormScaffold({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    required this.children,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(title),
      ),
      body: SafeArea(
        child: PageBody(
          children: [
            ...children,
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(
                error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: onSubmit, child: Text(submitLabel)),
          ],
        ),
      ),
    );
  }
}

String _optional(String key) => tr('optional', {'label': tr(key)});

// ----------------------------------------------------------------- Berita

class PostForm extends StatefulWidget {
  const PostForm({super.key});

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _category = kPostCategories.first;
  bool _pinned = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _submit() {
    String? err;
    if (_title.text.trim().isEmpty) {
      err = tr('err_title_required');
    } else if (_body.text.trim().isEmpty) {
      err = tr('err_body_required');
    }
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    appState.addPost(
      title: _title.text,
      body: _body.text,
      category: _category,
      pinned: _pinned,
    );
    toast(context, tr('post_saved'));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return _FormScaffold(
      title: tr('new_post'),
      submitLabel: tr('publish'),
      error: _error,
      onSubmit: _submit,
      children: [
        TextField(
          controller: _title,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDeco(context, tr('title')),
        ),
        const SizedBox(height: 12),
        Text(tr('category'),
            style: TextStyle(color: c.muted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final cat in kPostCategories)
              ChoiceChip(
                label: Text(catLabel(cat)),
                selected: _category == cat,
                onSelected: (_) => setState(() => _category = cat),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _body,
          minLines: 6,
          maxLines: 14,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDeco(context, tr('post_body'))
              .copyWith(alignLabelWithHint: true),
        ),
        const SizedBox(height: 12),
        AppCard(
          color: c.tint,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Icon(Icons.push_pin_rounded, color: c.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(tr('pin_post'),
                    style:
                        TextStyle(color: c.ink, fontWeight: FontWeight.w700)),
              ),
              Switch(
                value: _pinned,
                onChanged: (v) => setState(() => _pinned = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ Event

/// Form event baru. Saat disimpan, halaman ditutup dengan mengembalikan
/// event yang baru dibuat.
class EventForm extends StatefulWidget {
  final DateTime? initialDate;
  const EventForm({super.key, this.initialDate});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = widget.initialDate ?? DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && mounted) setState(() => _time = picked);
  }

  void _submit() {
    String? err;
    if (_title.text.trim().isEmpty) {
      err = tr('err_title_required');
    } else if (_location.text.trim().isEmpty) {
      err = tr('err_location_required');
    }
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final created = appState.addEvent(
      title: _title.text,
      description: _description.text,
      location: _location.text,
      start: DateTime(
          _date.year, _date.month, _date.day, _time.hour, _time.minute),
    );
    toast(context, tr('event_saved'));
    Navigator.of(context).pop(created);
  }

  Widget _picker(String label, IconData icon, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: fieldDeco(context, label, icon: icon),
        child: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: tr('new_event'),
      submitLabel: tr('save'),
      error: _error,
      onSubmit: _submit,
      children: [
        TextField(
          controller: _title,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDeco(context, tr('title')),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _picker(tr('date'), Icons.event_rounded, fmtDate(_date),
                  _pickDate),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _picker(
                  tr('time'),
                  Icons.schedule_rounded,
                  fmtTime(DateTime(2000, 1, 1, _time.hour, _time.minute)),
                  _pickTime),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _location,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          decoration:
              fieldDeco(context, tr('location'), icon: Icons.place_rounded),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          minLines: 3,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDeco(context, _optional('description'))
              .copyWith(alignLabelWithHint: true),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- Survey

class _QuestionDraft {
  final text = TextEditingController();
  final options = TextEditingController();
  String type = 'choice';

  List<String> get optionList => options.text
      .split(',')
      .map((o) => o.trim())
      .where((o) => o.isNotEmpty)
      .toList();

  void dispose() {
    text.dispose();
    options.dispose();
  }
}

class SurveyForm extends StatefulWidget {
  const SurveyForm({super.key});

  @override
  State<SurveyForm> createState() => _SurveyFormState();
}

class _SurveyFormState extends State<SurveyForm> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _minutes = TextEditingController(text: '2');
  final List<_QuestionDraft> _questions = [_QuestionDraft()];
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _minutes.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _removeQuestion(_QuestionDraft q) {
    setState(() => _questions.remove(q));
    // Field-nya masih tampil sampai frame ini selesai dibangun ulang.
    WidgetsBinding.instance.addPostFrameCallback((_) => q.dispose());
  }

  String? _validate() {
    if (_title.text.trim().isEmpty) return tr('err_title_required');
    if (_questions.isEmpty) return tr('err_no_questions');
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.text.text.trim().isEmpty) {
        return tr('err_question_empty', {'n': i + 1});
      }
      if (q.type == 'choice' && q.optionList.length < 2) {
        return tr('err_options_min', {'n': i + 1});
      }
    }
    return null;
  }

  void _submit() {
    final err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final minutes = int.tryParse(_minutes.text) ?? 1;
    appState.addSurvey(
      title: _title.text,
      description: _description.text,
      minutes: minutes < 1 ? 1 : minutes,
      questions: [
        for (final q in _questions)
          SurveyQuestion(q.text.text.trim(), q.type,
              q.type == 'choice' ? q.optionList : const []),
      ],
    );
    toast(context, tr('survey_saved'));
    Navigator.of(context).pop();
  }

  Widget _questionCard(BuildContext context, int i, _QuestionDraft q) {
    return AppCard(
      key: ObjectKey(q),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr('question_n', {'n': i + 1}),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: tr('remove_question'),
                onPressed: () => _removeQuestion(q),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: q.text,
            textCapitalization: TextCapitalization.sentences,
            decoration: fieldDeco(context, tr('question_text')),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in const ['choice', 'rating', 'text'])
                ChoiceChip(
                  label: Text(tr('qtype_$type')),
                  selected: q.type == type,
                  onSelected: (_) => setState(() => q.type = type),
                ),
            ],
          ),
          if (q.type == 'choice') ...[
            const SizedBox(height: 12),
            TextField(
              controller: q.options,
              textCapitalization: TextCapitalization.sentences,
              decoration: fieldDeco(context, tr('question_options')),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: tr('new_survey'),
      submitLabel: tr('save'),
      error: _error,
      onSubmit: _submit,
      children: [
        TextField(
          controller: _title,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDeco(context, tr('title')),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDeco(context, _optional('description'))
              .copyWith(alignLabelWithHint: true),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _minutes,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: fieldDeco(context, tr('survey_minutes'),
              icon: Icons.schedule_rounded),
        ),
        const SizedBox(height: 16),
        ...spaced([
          for (var i = 0; i < _questions.length; i++)
            _questionCard(context, i, _questions[i]),
        ], 12),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => _questions.add(_QuestionDraft())),
          icon: const Icon(Icons.add_rounded),
          label: Text(tr('add_question')),
        ),
      ],
    );
  }
}
