import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _register = false;
  bool _hide = true;
  String? _error;

  final _name = TextEditingController();
  final _employeeNo = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _employeeNo.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    String? err;
    if (_register) {
      err = appState.register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        employeeNo: _employeeNo.text,
      );
    } else {
      err = appState.login(_email.text, _password.text);
    }
    if (err != null && mounted) setState(() => _error = err);
  }

  void _fillDemo() {
    setState(() {
      _register = false;
      _error = null;
      _email.text = 'demo@perusahaan.com';
      _password.text = 'demo123';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.hero,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                              color: c.sky, shape: BoxShape.circle),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Portal Karyawan',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Ganti mode terang atau gelap',
                        onPressed: () => appState
                            .toggleTheme(Theme.of(context).brightness),
                        icon: Icon(dark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: _register ? 'Yuk, gabung.\n' : 'Halo lagi.\n'),
                        TextSpan(
                          text: _register
                              ? 'Buat akunmu dulu.'
                              : 'Masuk untuk lanjut.',
                          style: TextStyle(color: c.headline),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 34,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_register) ...[
                          TextField(
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            decoration: fieldDeco(context, 'Nama lengkap',
                                icon: Icons.person_rounded),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _employeeNo,
                            textInputAction: TextInputAction.next,
                            decoration: fieldDeco(
                                context, 'Nomor induk karyawan (opsional)',
                                icon: Icons.badge_rounded),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: fieldDeco(context, 'Email',
                              icon: Icons.mail_rounded),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password,
                          obscureText: _hide,
                          onSubmitted: (_) => _submit(),
                          decoration: fieldDeco(context, 'Kata sandi',
                                  icon: Icons.lock_rounded)
                              .copyWith(
                            suffixIcon: IconButton(
                              tooltip: _hide
                                  ? 'Tampilkan kata sandi'
                                  : 'Sembunyikan kata sandi',
                              onPressed: () => setState(() => _hide = !_hide),
                              icon: Icon(_hide
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded),
                            ),
                          ),
                        ),
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
                        FilledButton(
                          onPressed: _submit,
                          child: Text(_register ? 'Daftar' : 'Masuk'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {
                            _register = !_register;
                            _error = null;
                          }),
                          child: Text(_register
                              ? 'Sudah punya akun? Masuk'
                              : 'Belum punya akun? Daftar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    color: c.tint,
                    onTap: _fillDemo,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: c.ink),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Coba akun demo: demo@perusahaan.com, kata sandi demo123. Ketuk untuk mengisi otomatis.',
                            style: TextStyle(color: c.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
