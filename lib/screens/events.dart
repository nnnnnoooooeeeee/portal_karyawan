import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'forms.dart';

/// Baris ringkas event: kotak tanggal, judul, jam, dan lokasi.
class EventRow extends StatelessWidget {
  final EventItem event;
  const EventRow(this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        DateTile(event.start),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                '${fmtTime(event.start)}, ${event.location}',
                style: TextStyle(color: c.muted, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late DateTime _month;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  void _shift(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta, 1);
      _selected = null;
    });
  }

  /// Buka form event baru, lalu pindahkan kalender ke tanggal event itu.
  Future<void> _add() async {
    final created = await Navigator.of(context).push(
      MaterialPageRoute<EventItem>(
          builder: (_) => EventForm(initialDate: _selected)),
    );
    if (created == null || !mounted) return;
    final d = created.start;
    setState(() {
      _month = DateTime(d.year, d.month, 1);
      _selected = DateTime(d.year, d.month, d.day);
    });
  }

  List<EventItem> _eventsOn(DateTime day) =>
      appState.events.where((e) => sameDay(e.start, day)).toList();

  Widget _calendar(BuildContext context) {
    final c = AppColors.of(context);
    final today = DateTime.now();
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = _month.weekday - 1; // Senin = kolom pertama

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final day = DateTime(_month.year, _month.month, d);
      final hasEvent = _eventsOn(day).isNotEmpty;
      final selected = _selected != null && sameDay(_selected!, day);
      final isToday = sameDay(today, day);
      final fg = selected ? c.onActive : c.ink;

      cells.add(
        Material(
          color: selected ? c.active : Colors.transparent,
          shape: CircleBorder(
            side: isToday && !selected
                ? BorderSide(color: c.primary, width: 2)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => setState(() => _selected = selected ? null : day),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$d',
                  style: TextStyle(
                    color: fg,
                    fontWeight: hasEvent ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: hasEvent ? c.pop : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: tr('prev_month'),
                onPressed: () => _shift(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${monthNames[_month.month - 1]} ${_month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: tr('next_month'),
                onPressed: () => _shift(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final h in dayNames)
                Expanded(
                  child: Text(
                    h,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: c.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: cells,
          ),
        ],
      ),
    );
  }

  Widget _eventCard(BuildContext context, EventItem e) {
    final c = AppColors.of(context);
    final going = e.going.contains(appState.uid);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EventRow(e),
          const SizedBox(height: 10),
          Text(e.description, style: TextStyle(color: c.muted)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  e.going.isEmpty
                      ? tr('no_one_registered')
                      : tr('people_going', {'n': e.going.length}),
                  style: TextStyle(color: c.muted, fontSize: 14),
                ),
              ),
              if (going)
                OutlinedButton.icon(
                  onPressed: () => appState.toggleGoing(e),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(tr('registered')),
                )
              else
                FilledButton(
                  onPressed: () => appState.toggleGoing(e),
                  child: Text(tr('join')),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final selected = _selected;

    final list = selected != null
        ? _eventsOn(selected)
        : appState.events
            .where((e) =>
                e.start.year == _month.year && e.start.month == _month.month)
            .toList();
    list.sort((a, b) => a.start.compareTo(b.start));

    final listTitle = selected != null
        ? tr('events_on', {'date': fmtDate(selected)})
        : tr('events_in', {'month': monthNames[_month.month - 1]});

    final listColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(listTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Text(
            selected != null
                ? tr('no_events_date')
                : tr('no_events_month'),
            style: TextStyle(color: c.muted),
          ),
        ...spaced([for (final e in list) _eventCard(context, e)], 12),
      ],
    );

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 860;
        return PageBody(
          children: [
            PageHeader(
              tr('nav_events'),
              subtitle: tr('events_subtitle'),
              action: FilledButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add_rounded),
                label: Text(tr('add')),
              ),
            ),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 380, child: _calendar(context)),
                  const SizedBox(width: 24),
                  Expanded(child: listColumn),
                ],
              )
            else ...[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _calendar(context),
                ),
              ),
              const SizedBox(height: 20),
              listColumn,
            ],
          ],
        );
      },
    );
  }
}
