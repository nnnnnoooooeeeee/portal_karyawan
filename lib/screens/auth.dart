import 'package:flutter/material.dart';

import '../l10n.dart';
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
  final _nik = TextEditingController();
  final _fingerNo = TextEditingController();
  final _department = TextEditingController();
  final _position = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _nik.dispose();
    _fingerNo.dispose();
    _department.dispose();
    _position.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    String? err;
    if (_register) {
      err = appState.register(
        name: _name.text,
        nik: _nik.text,
        fingerNo: _fingerNo.text,
        department: _department.text,
        position: _position.text,
        password: _password.text,
      );
    } else {
      err = appState.login(_fingerNo.text, _password.text);
    }
    if (err != null && mounted) setState(() => _error = err);
  }

  void _fillDemo() {
    setState(() {
      _register = false;
      _error = null;
      _fingerNo.text = kDemoFingerNo;
      _password.text = kDemoPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    Widget field(TextEditingController controller, String label, IconData icon,
        {TextInputType? keyboard}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          textInputAction: TextInputAction.next,
          decoration: fieldDeco(context, label, icon: icon),
        ),
      );
    }

    String optional(String key) => tr('optional', {'label': tr(key)});

    return Scaffold(
      body: WebSelectable(
          child: SafeArea(
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
                      Expanded(
                        child: Text(
                          tr('app_name'),
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: tr('language'),
                        icon: const Icon(Icons.language_rounded),
                        initialValue: currentLanguage.code,
                        onSelected: (code) => setState(() {
                          appState.setLanguage(code);
                          _error = null;
                        }),
                        itemBuilder: (context) => [
                          for (final l in kLanguages)
                            PopupMenuItem(value: l.code, child: Text(l.name)),
                        ],
                      ),
                      IconButton(
                        tooltip: tr('theme_toggle'),
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
                            text:
                                '${tr(_register ? 'auth_join_1' : 'auth_hello_1')}\n'),
                        TextSpan(
                          text: tr(_register ? 'auth_join_2' : 'auth_hello_2'),
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
                          field(_name, tr('full_name'), Icons.person_rounded),
                          field(_nik, optional('nik'), Icons.badge_rounded),
                          field(_department, optional('department'),
                              Icons.apartment_rounded),
                          field(_position, optional('position'),
                              Icons.work_rounded),
                        ],
                        field(_fingerNo, tr('finger_no'),
                            Icons.fingerprint_rounded,
                            keyboard: TextInputType.number),
                        TextField(
                          controller: _password,
                          obscureText: _hide,
                          onSubmitted: (_) => _submit(),
                          decoration: fieldDeco(context, tr('password'),
                                  icon: Icons.lock_rounded)
                              .copyWith(
                            suffixIcon: IconButton(
                              tooltip: tr(
                                  _hide ? 'show_password' : 'hide_password'),
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
                          child: Text(tr(_register ? 'sign_up' : 'sign_in')),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {
                            _register = !_register;
                            _error = null;
                          }),
                          child: Text(
                              tr(_register ? 'have_account' : 'no_account')),
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
                            tr('demo_hint', {
                              'finger': kDemoFingerNo,
                              'password': kDemoPassword,
                            }),
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
      )),
    );
  }
}
