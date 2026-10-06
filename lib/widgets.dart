import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models.dart';
import 'state.dart';
import 'theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: color ?? c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: color == null ? BorderSide(color: c.line) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  const Tag(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: c.tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.ink),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String text;
  final double size;
  const Avatar(this.text, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.sky, shape: BoxShape.circle),
      child: Text(
        text,
        style: TextStyle(
          color: kInkOnSky,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

class DateTile extends StatelessWidget {
  final DateTime date;
  const DateTile(this.date, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: 52,
      height: 56,
      decoration: BoxDecoration(
        color: c.pop,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            monthNamesShort[date.month - 1],
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: c.onPop),
          ),
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 19,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: c.onPop,
            ),
          ),
        ],
      ),
    );
  }
}

/// Judul halaman. Di layar HP, [backTo] menampilkan tombol kembali.
/// [action] tampil di sisi kanan judul.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? backTo;
  final Widget? action;
  const PageHeader(this.title,
      {super.key, this.subtitle, this.backTo, this.action});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final compact = MediaQuery.of(context).size.width < 700;
    final target = backTo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          if (target != null && compact)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                tooltip: tr('back'),
                onPressed: () => appState.go(target),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(color: c.muted)),
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 12), action!],
        ],
      ),
    );
  }
}

/// Isi halaman yang bisa digulir, dengan lebar maksimum supaya nyaman dibaca.
class PageBody extends StatelessWidget {
  final List<Widget> children;
  final double maxWidth;
  const PageBody({super.key, required this.children, this.maxWidth = 760});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: children,
        ),
      ),
    );
  }
}

InputDecoration fieldDeco(BuildContext context, String label,
    {IconData? icon}) {
  final c = AppColors.of(context);
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: c.tint,
    prefixIcon: icon == null ? null : Icon(icon),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}

List<Widget> spaced(List<Widget> items, [double gap = 16]) {
  final out = <Widget>[];
  for (var i = 0; i < items.length; i++) {
    if (i > 0) out.add(SizedBox(height: gap));
    out.add(items[i]);
  }
  return out;
}

void toast(BuildContext context, String text) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(content: Text(text)));
}
