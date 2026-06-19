import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'news_data.dart';

/// Halaman detail satu berita/pengumuman.
class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final article = newsById(id);
    final scheme = Theme.of(context).colorScheme;

    if (article == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go('/')),
          title: const Text('Berita tidak ditemukan'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.article_outlined,
                  size: 64, color: scheme.onSurfaceVariant),
              const SizedBox(height: 12),
              const Text('Maaf, berita yang Anda cari tidak tersedia.'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final others = kNewsArticles.where((a) => a.id != article.id).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: article.color,
            foregroundColor: Colors.white,
            leading: BackButton(
              color: Colors.white,
              onPressed: () => context.go('/'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.imageUrl(1400),
                    fit: BoxFit.cover,
                    loadingBuilder: (c, child, p) =>
                        p == null ? child : Container(color: article.color),
                    errorBuilder: (c, e, s) => Container(
                      color: article.color.withValues(alpha: 0.2),
                      alignment: Alignment.center,
                      child: Icon(article.icon,
                          size: 72, color: article.color),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xB3000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori + meta
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: article.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              article.category,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          _MetaItem(
                              icon: Icons.calendar_today_outlined,
                              text: article.date),
                          _MetaItem(
                              icon: Icons.person_outline,
                              text: article.author),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        article.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...article.body.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Text(
                            p,
                            textAlign: TextAlign.justify,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.7,
                              color: scheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali ke Beranda'),
                      ),
                      const SizedBox(height: 40),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(
                        'Berita Lainnya',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      ...others.map((a) => _OtherNewsTile(article: a)),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(text,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

class _OtherNewsTile extends StatelessWidget {
  const _OtherNewsTile({required this.article});
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => context.go('/berita/${article.id}'),
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 72,
            height: 56,
            child: Image.network(
              article.imageUrl(200),
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                color: article.color.withValues(alpha: 0.15),
                child: Icon(article.icon, color: article.color),
              ),
            ),
          ),
        ),
        title: Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        subtitle: Text('${article.category} · ${article.date}',
            style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
