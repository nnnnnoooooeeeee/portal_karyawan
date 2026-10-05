import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'events.dart';
import 'news.dart';
import 'services.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final s = appState;
    final pinned = s.posts.where((p) => p.pinned).toList();
    final feed = s.posts.where((p) => !p.pinned).take(3).toList();
    final upcoming = s.upcomingEvents.take(2).toList();
    final pending = s.pendingSurveys;
    final latestSlip = s.payslips.first;

    final greeting = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${s.greeting}, ${s.user!.firstName}.\n'),
          TextSpan(
            text: tr('home_question'),
            style: TextStyle(color: c.headline),
          ),
        ],
      ),
      style: const TextStyle(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );

    final slipCard = AppCard(
      onTap: () => s.go('payslip'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.tint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.account_balance_wallet_rounded, color: c.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('latest_payslip'),
                    style: TextStyle(
                        color: c.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(
                  '${monthNames[latestSlip.month - 1]} ${latestSlip.year}',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => s.go('payslip'),
            child: Text(tr('view')),
          ),
        ],
      ),
    );

    final eventsCard = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr('next_events'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: () => s.go('events'),
                child: Text(tr('all')),
              ),
            ],
          ),
          if (upcoming.isEmpty)
            Text(tr('no_events_scheduled'), style: TextStyle(color: c.muted)),
          for (final e in upcoming)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: EventRow(e),
            ),
        ],
      ),
    );

    final surveyCard = AppCard(
      color: c.tint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(tr('voice_matters'),
              style: TextStyle(
                  color: c.ink, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            pending.isEmpty
                ? tr('all_surveys_done')
                : pending.first.title,
            style: TextStyle(color: c.ink, fontWeight: FontWeight.w600),
          ),
          if (pending.isNotEmpty) ...[
            Text(tr('only_minutes', {'n': pending.first.minutes}),
                style: TextStyle(color: c.muted, fontSize: 14)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => s.go('survey'),
              child: Text(tr('fill_survey')),
            ),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 900;

        final main = <Widget>[
          greeting,
          if (!wide) LeaveHero(compact: true),
          if (!wide) QuickTiles(),
          for (final p in pinned) PinnedCard(p),
          for (final p in feed) PostCard(p),
          OutlinedButton(
            onPressed: () => s.go('news'),
            child: Text(tr('see_all_news')),
          ),
        ];
        final side = <Widget>[slipCard, eventsCard, surveyCard];

        if (wide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: spaced(main, 18),
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 340,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: spaced([LeaveHero(), ...side], 18),
                  ),
                ),
              ],
            ),
          );
        }

        return PageBody(children: spaced([...main, ...side]));
      },
    );
  }
}

/// Tombol pintasan berwarna untuk layar HP dan tablet.
class QuickTiles extends StatelessWidget {
  const QuickTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final pending = appState.pendingSurveys.length;

    Widget tile(String label, IconData icon, Color bg, Color fg, String page) {
      return Expanded(
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => appState.go(page),
            child: SizedBox(
              height: 84,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: fg),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                        color: fg, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tile(tr('nav_payslip'), Icons.account_balance_wallet_rounded, c.tint, c.ink,
            'payslip'),
        const SizedBox(width: 10),
        tile(tr('nav_events'), Icons.event_rounded, c.sky, kInkOnSky, 'events'),
        const SizedBox(width: 10),
        tile(pending > 0 ? '${tr('nav_survey')} ($pending)' : tr('nav_survey'),
            Icons.fact_check_rounded, c.pop, c.onPop, 'survey'),
      ],
    );
  }
}

class PinnedCard extends StatelessWidget {
  final Post post;
  const PinnedCard(this.post, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AppCard(
      color: c.pop,
      onTap: () => openPost(context, post),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('dont_miss'),
                  style: TextStyle(
                    color: c.onPop,
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  post.title,
                  style: TextStyle(
                    color: c.onPop,
                    fontSize: 17,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: c.onPop, shape: BoxShape.circle),
            child: Icon(Icons.arrow_forward_rounded, color: c.pop),
          ),
        ],
      ),
    );
  }
}
