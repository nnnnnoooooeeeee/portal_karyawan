import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'events.dart';
import 'home.dart';
import 'news.dart';
import 'profile.dart';
import 'services.dart';

class NavItem {
  final String id, label;
  final IconData icon;
  const NavItem(this.id, this.label, this.icon);
}

const List<NavItem> kWideItems = [
  NavItem('home', 'Beranda', Icons.home_rounded),
  NavItem('news', 'Berita', Icons.article_rounded),
  NavItem('events', 'Event', Icons.event_rounded),
  NavItem('survey', 'Survey', Icons.fact_check_rounded),
  NavItem('leave', 'Cuti', Icons.beach_access_rounded),
  NavItem('payslip', 'Slip Gaji', Icons.account_balance_wallet_rounded),
  NavItem('profile', 'Profil', Icons.person_rounded),
];

const List<NavItem> kPhoneItems = [
  NavItem('home', 'Beranda', Icons.home_rounded),
  NavItem('news', 'Berita', Icons.article_rounded),
  NavItem('events', 'Event', Icons.event_rounded),
  NavItem('services', 'Layanan', Icons.grid_view_rounded),
  NavItem('profile', 'Profil', Icons.person_rounded),
];

const List<String> kServicePages = ['services', 'leave', 'payslip', 'survey'];

/// Kerangka utama: sidebar di PC, rail ikon di tablet, menu bawah di HP.
class Shell extends StatelessWidget {
  const Shell({super.key});

  Widget _page(String id) {
    switch (id) {
      case 'news':
        return NewsPage();
      case 'events':
        return EventsPage();
      case 'services':
        return ServicesPage();
      case 'leave':
        return LeavePage();
      case 'payslip':
        return PayslipPage();
      case 'survey':
        return SurveyPage();
      case 'profile':
        return ProfilePage();
      default:
        return HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        if (appState.user == null) return const SizedBox.shrink();
        return LayoutBuilder(
          builder: (context, box) {
            final width = box.maxWidth;
            final content = KeyedSubtree(
              key: ValueKey(appState.page),
              child: _page(appState.page),
            );

            if (width < 700) {
              return Scaffold(
                body: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      TopBar(compact: true),
                      Expanded(child: content),
                    ],
                  ),
                ),
                bottomNavigationBar: BottomNav(),
              );
            }

            return Scaffold(
              body: SafeArea(
                child: Row(
                  children: [
                    SideNav(extended: width >= 1100),
                    Expanded(
                      child: Column(
                        children: [
                          TopBar(compact: width < 1100),
                          Expanded(child: content),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.hero,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: size * 0.36,
        height: size * 0.36,
        decoration: BoxDecoration(color: c.sky, shape: BoxShape.circle),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final bool compact;
  const TopBar({super.key, required this.compact});

  void _showNotifications(BuildContext context) {
    final c = AppColors.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      showDragHandle: true,
      builder: (context) {
        final items = appState.notifications;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              const Text(
                'Notifikasi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (items.isEmpty) const Text('Belum ada notifikasi.'),
              for (final n in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.notifications_rounded, color: c.primary),
                  title: Text(n),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _roundButton(BuildContext context,
      {required IconData icon,
      required String tooltip,
      required VoidCallback onTap}) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: c.tint,
          foregroundColor: c.ink,
          minimumSize: const Size(46, 46),
        ),
        icon: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 24, 12, compact ? 16 : 24, 8),
      child: Row(
        children: [
          if (compact) ...[
            if (MediaQuery.of(context).size.width < 700) ...[
              const Logo(size: 36),
              const SizedBox(width: 10),
            ],
            const Expanded(
              child: Text(
                'Portal Karyawan',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            _roundButton(
              context,
              icon: Icons.search_rounded,
              tooltip: 'Cari berita',
              onTap: () => appState.go('news'),
            ),
          ] else ...[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: TextField(
                    onSubmitted: appState.search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari berita, lalu tekan Enter',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: c.surface,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(color: c.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(color: c.line),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          _roundButton(
            context,
            icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: 'Ganti mode terang atau gelap',
            onTap: () => appState.toggleTheme(Theme.of(context).brightness),
          ),
          _roundButton(
            context,
            icon: Icons.notifications_rounded,
            tooltip: 'Notifikasi',
            onTap: () => _showNotifications(context),
          ),
        ],
      ),
    );
  }
}

class SideNav extends StatelessWidget {
  final bool extended;
  const SideNav({super.key, required this.extended});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final user = appState.user!;
    final pending = appState.pendingSurveys.length;

    Widget item(NavItem n) {
      final active = appState.page == n.id;
      final fg = active ? c.onActive : c.ink;
      final badge = n.id == 'survey' && pending > 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Tooltip(
          message: extended ? '' : n.label,
          child: Material(
            color: active ? c.active : Colors.transparent,
            borderRadius: BorderRadius.circular(extended ? 999 : 18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => appState.go(n.id),
              child: SizedBox(
                height: extended ? 48 : 52,
                width: extended ? null : 52,
                child: extended
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(n.icon, color: fg, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                n.label,
                                style: TextStyle(
                                  color: fg,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (badge)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 2),
                                decoration: BoxDecoration(
                                  color: c.pop,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '$pending',
                                  style: TextStyle(
                                    color: c.onPop,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : Icon(n.icon, color: fg, size: 24),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: extended ? 256 : 84,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(right: BorderSide(color: c.line)),
      ),
      padding: EdgeInsets.symmetric(horizontal: extended ? 16 : 0, vertical: 20),
      child: Column(
        crossAxisAlignment:
            extended ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
        children: [
          if (extended)
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 22),
              child: Row(
                children: [
                  Logo(),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Portal Karyawan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Logo(size: 44),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: extended
                    ? CrossAxisAlignment.stretch
                    : CrossAxisAlignment.center,
                children: [for (final n in kWideItems) item(n)],
              ),
            ),
          ),
          if (extended)
            Material(
              color: c.tint,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => appState.go('profile'),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Avatar(user.initials),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: c.ink, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              user.position.isEmpty
                                  ? user.email
                                  : user.position,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: c.muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              for (final n in kPhoneItems)
                Expanded(child: _tab(context, n, c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, NavItem n, AppColors c) {
    final page = appState.page;
    final active = page == n.id ||
        (n.id == 'services' && kServicePages.contains(page));
    final fg = active ? c.onActive : c.muted;
    return Material(
      color: active ? c.active : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => appState.go(n.id),
        child: SizedBox(
          height: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(n.icon, size: 20, color: fg),
              Text(
                n.label,
                style: TextStyle(
                  fontSize: 11,
                  color: fg,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
