import 'package:flutter/material.dart';

import '../l10n.dart';
import '../notify.dart';
import '../state.dart';
import '../theme.dart';
import '../updater.dart';
import '../widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _testNotification(BuildContext context) async {
    final result = await showTestNotification();
    if (context.mounted) toast(context, tr(result));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr('logout_title')),
          content: Text(tr('logout_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(tr('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(tr('logout')),
            ),
          ],
        );
      },
    );
    if (yes == true) appState.logout();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final user = appState.user!;

    Widget info(IconData icon, String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: c.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: c.muted, fontSize: 13)),
                  Text(value.isEmpty ? tr('not_set') : value,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget section(String title, List<Widget> children) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );
    }

    return PageBody(
      maxWidth: 600,
      children: [
        PageHeader(tr('nav_profile')),
        AppCard(
          color: c.hero,
          child: Row(
            children: [
              Avatar(user.initials, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (user.position.isNotEmpty)
                      Text(user.position, style: TextStyle(color: c.heroSub)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              info(Icons.badge_rounded, tr('nik'), user.nik),
              info(Icons.fingerprint_rounded, tr('finger_no'), user.fingerNo),
              info(Icons.apartment_rounded, tr('department'), user.department),
              info(Icons.work_rounded, tr('position'), user.position),
            ],
          ),
        ),
        const SizedBox(height: 16),
        section(tr('appearance'), [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(tr('theme_system')),
                selected: appState.themeMode == ThemeMode.system,
                onSelected: (_) => appState.setTheme(ThemeMode.system),
              ),
              ChoiceChip(
                label: Text(tr('theme_light')),
                selected: appState.themeMode == ThemeMode.light,
                onSelected: (_) => appState.setTheme(ThemeMode.light),
              ),
              ChoiceChip(
                label: Text(tr('theme_dark')),
                selected: appState.themeMode == ThemeMode.dark,
                onSelected: (_) => appState.setTheme(ThemeMode.dark),
              ),
            ],
          ),
        ]),
        const SizedBox(height: 16),
        section(tr('language'), [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final l in kLanguages)
                ChoiceChip(
                  label: Text(l.name),
                  selected: currentLanguage.code == l.code,
                  onSelected: (_) => appState.setLanguage(l.code),
                ),
            ],
          ),
        ]),
        const SizedBox(height: 16),
        section(tr('notifications'), [
          Text(tr('notif_test_desc'), style: TextStyle(color: c.muted)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _testNotification(context),
            icon: const Icon(Icons.notifications_active_rounded),
            label: Text(tr('notif_test_button')),
          ),
        ]),
        const SizedBox(height: 16),
        section(tr('about_app'), [
          FutureBuilder<String>(
            future: appVersion(),
            builder: (context, snap) => Text(
              tr('app_version', {'v': snap.data ?? '…'}),
              style: TextStyle(color: c.muted),
            ),
          ),
          if (updateSupported) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => checkForUpdate(manual: true),
              icon: const Icon(Icons.system_update_rounded),
              label: Text(tr('check_update')),
            ),
          ],
        ]),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout_rounded),
          label: Text(tr('logout')),
        ),
      ],
    );
  }
}
