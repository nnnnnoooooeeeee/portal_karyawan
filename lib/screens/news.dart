import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

void openPost(BuildContext context, Post post) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => PostDetail(post)),
  );
}

String _initialsOf(String name) {
  final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final a = parts.first[0];
  final b = parts.length > 1 ? parts.last[0] : '';
  return (a + b).toUpperCase();
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String _category = 'Semua';
  late final TextEditingController _search =
      TextEditingController(text: appState.newsQuery);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final q = appState.newsQuery.toLowerCase();
    final list = appState.posts.where((p) {
      final okCategory = _category == 'Semua' || p.category == _category;
      final okQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.body.toLowerCase().contains(q);
      return okCategory && okQuery;
    }).toList()
      ..sort((a, b) => b.time.compareTo(a.time));

    return PageBody(
      children: [
        const PageHeader('Berita', subtitle: 'Kabar terbaru dari perusahaan'),
        TextField(
          controller: _search,
          onChanged: appState.setNewsQuery,
          textInputAction: TextInputAction.search,
          decoration:
              fieldDeco(context, 'Cari berita', icon: Icons.search_rounded),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final cat in const ['Semua', 'Berita', 'Pengumuman', 'Umum'])
              ChoiceChip(
                label: Text(cat),
                selected: _category == cat,
                onSelected: (_) => setState(() => _category = cat),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'Tidak ada berita yang cocok.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted),
            ),
          ),
        ...spaced([for (final p in list) PostCard(p)]),
      ],
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard(this.post, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final liked = post.likes.contains(appState.user!.email);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => openPost(context, post),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            color: c.tint,
            alignment: Alignment.center,
            child: Icon(Icons.image_rounded, size: 40, color: c.muted),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Avatar(_initialsOf(post.author), size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${post.author}  ·  ${timeAgo(post.time)}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.muted, fontSize: 13),
                      ),
                    ),
                    Tag(post.category),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  post.title,
                  style: const TextStyle(
                      fontSize: 19, height: 1.3, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.muted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionPill(
                      icon: liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      label: post.likes.isEmpty
                          ? 'Suka'
                          : 'Suka (${post.likes.length})',
                      highlighted: liked,
                      onTap: () => appState.toggleLike(post),
                    ),
                    ActionPill(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: post.comments.isEmpty
                          ? 'Komentar'
                          : 'Komentar (${post.comments.length})',
                      onTap: () => openPost(context, post),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  const ActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final bg = highlighted ? c.active : c.tint;
    final fg = highlighted ? c.onActive : c.ink;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class PostDetail extends StatefulWidget {
  final Post post;
  const PostDetail(this.post, {super.key});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _send() {
    if (_comment.text.trim().isEmpty) return;
    appState.addComment(widget.post, _comment.text);
    _comment.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final c = AppColors.of(context);
        final post = widget.post;
        final user = appState.user;
        if (user == null) return const SizedBox.shrink();
        final liked = post.likes.contains(user.email);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: c.bg,
            surfaceTintColor: Colors.transparent,
            title: Text(post.category),
          ),
          body: SafeArea(
            child: PageBody(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 180,
                    color: c.tint,
                    alignment: Alignment.center,
                    child: Icon(Icons.image_rounded, size: 48, color: c.muted),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 26,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${post.author}  ·  ${fmtDate(post.time)}',
                    style: TextStyle(color: c.muted)),
                const SizedBox(height: 16),
                Text(post.body,
                    style: const TextStyle(fontSize: 16, height: 1.6)),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ActionPill(
                    icon: liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: post.likes.isEmpty
                        ? 'Suka'
                        : 'Suka (${post.likes.length})',
                    highlighted: liked,
                    onTap: () => appState.toggleLike(post),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Komentar (${post.comments.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (post.comments.isEmpty)
                  Text('Jadi yang pertama berkomentar.',
                      style: TextStyle(color: c.muted)),
                for (final cm in post.comments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Avatar(_initialsOf(cm.author), size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: c.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${cm.author}  ·  ${timeAgo(cm.time)}',
                                  style: TextStyle(
                                      color: c.muted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(cm.text),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _comment,
                        onSubmitted: (_) => _send(),
                        decoration: fieldDeco(context, 'Tulis komentar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Kirim komentar',
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
