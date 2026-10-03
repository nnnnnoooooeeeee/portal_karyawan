import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

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
                tooltip: 'Bulan sebelumnya',
                onPressed: () => _shift(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${kBulan[_month.month - 1]} ${_month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Bulan berikutnya',
                onPressed: () => _shift(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final h in kHari)
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
    final going = e.going.contains(appState.user!.email);
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
                      ? 'Belum ada yang mendaftar'
                      : '${e.going.length} orang ikut',
                  style: TextStyle(color: c.muted, fontSize: 14),
                ),
              ),
              if (going)
                OutlinedButton.icon(
                  onPressed: () => appState.toggleGoing(e),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Terdaftar'),
                )
              else
                FilledButton(
                  onPressed: () => appState.toggleGoing(e),
                  child: const Text('Ikut'),
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
        ? 'Event tanggal ${fmtDate(selected)}'
        : 'Semua event ${kBulan[_month.month - 1]}';

    final listColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(listTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Text(
            selected != null
                ? 'Tidak ada event di tanggal ini.'
                : 'Tidak ada event di bulan ini.',
            style: TextStyle(color: c.muted),
          ),
        ...spaced([for (final e in list) _eventCard(context, e)], 12),
      ],
    );

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 860;
        return PageBody(
          maxWidth: wide ? 1040 : 560,
          children: [
            const PageHeader('Event',
                subtitle: 'Ketuk tanggal untuk melihat event hari itu'),
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
              _calendar(context),
              const SizedBox(height: 20),
              listColumn,
            ],
          ],
        );
      },
    );
  }
}
