import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _edit(BuildContext context) async {
    final user = appState.user!;
    final name = TextEditingController(text: user.name);
    final department = TextEditingController(text: user.department);
    final position = TextEditingController(text: user.position);

    final save = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: name,
                    decoration: fieldDeco(context, 'Nama lengkap')),
                const SizedBox(height: 12),
                TextField(
                    controller: department,
                    decoration: fieldDeco(context, 'Departemen')),
                const SizedBox(height: 12),
                TextField(
                    controller: position,
                    decoration: fieldDeco(context, 'Jabatan')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (save == true) {
      appState.updateProfile(
        name: name.text,
        department: department.text,
        position: position.text,
      );
    }
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
                  Text(value.isEmpty ? 'Belum diisi' : value,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return PageBody(
      maxWidth: 600,
      children: [
        const PageHeader('Profil'),
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
                    Text(
                      user.position.isEmpty ? user.email : user.position,
                      style: TextStyle(color: c.heroSub),
                    ),
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
              info(Icons.mail_rounded, 'Email', user.email),
              info(Icons.badge_rounded, 'Nomor induk karyawan', user.employeeNo),
              info(Icons.apartment_rounded, 'Departemen', user.department),
              info(Icons.work_rounded, 'Jabatan', user.position),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _edit(context),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Ubah profil'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Tampilan',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Ikuti perangkat'),
                    selected: appState.themeMode == ThemeMode.system,
                    onSelected: (_) => appState.setTheme(ThemeMode.system),
                  ),
                  ChoiceChip(
                    label: const Text('Terang'),
                    selected: appState.themeMode == ThemeMode.light,
                    onSelected: (_) => appState.setTheme(ThemeMode.light),
                  ),
                  ChoiceChip(
                    label: const Text('Gelap'),
                    selected: appState.themeMode == ThemeMode.dark,
                    onSelected: (_) => appState.setTheme(ThemeMode.dark),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: appState.logout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Keluar'),
        ),
      ],
    );
  }
}
