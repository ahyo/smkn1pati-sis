import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'news_data.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollCtrl = ScrollController();
  bool _navSolid = false;

  // Anchor untuk navigasi menu (scroll ke bagian terkait).
  final _featuresKey = GlobalKey();
  final _newsKey = GlobalKey();
  final _galleryKey = GlobalKey();
  final _aboutKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final solid = _scrollCtrl.offset > 60;
      if (solid != _navSolid) setState(() => _navSolid = solid);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Menangani klik menu di header & footer.
  void onNav(String target) {
    switch (target) {
      case 'home':
        _scrollCtrl.animateTo(0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
        break;
      case 'enroll':
        context.go('/enroll');
        break;
      case 'features':
        _scrollToKey(_featuresKey);
        break;
      case 'news':
        _scrollToKey(_newsKey);
        break;
      case 'gallery':
        _scrollToKey(_galleryKey);
        break;
      case 'about':
        _scrollToKey(_aboutKey);
        break;
    }
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            // Bangun semua bagian agar anchor menu selalu tersedia untuk scroll.
            // ignore: deprecated_member_use
            cacheExtent: 4000,
            slivers: [
              const SliverToBoxAdapter(child: _HeroSection()),
              const SliverToBoxAdapter(child: _StatsSection()),
              SliverToBoxAdapter(
                  child: KeyedSubtree(
                      key: _featuresKey, child: const _FeaturesSection())),
              SliverToBoxAdapter(
                  child: KeyedSubtree(
                      key: _newsKey, child: const _NewsSection())),
              SliverToBoxAdapter(
                  child: KeyedSubtree(
                      key: _galleryKey, child: const _GallerySection())),
              SliverToBoxAdapter(
                  child: KeyedSubtree(
                      key: _aboutKey, child: const _InfoSection())),
              SliverToBoxAdapter(child: _Footer(onNav: onNav)),
            ],
          ),
          _NavBar(solid: _navSolid, onNav: onNav),
        ],
      ),
    );
  }
}

// ─── Navigation Bar ───────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar({required this.solid, required this.onNav});
  final bool solid;
  final void Function(String target) onNav;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 700;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      color: solid
          ? scheme.surface.withValues(alpha: 0.96)
          : Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: narrow ? 16 : 32),
          decoration: solid
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                )
              : null,
          child: Row(
            children: [
              // Logo + Nama
              Icon(Icons.school, color: solid ? scheme.primary : Colors.white,
                  size: 28),
              const SizedBox(width: 10),
              Text(
                'SMK Negeri 1 Pati',
                style: TextStyle(
                  color: solid ? scheme.onSurface : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: narrow ? 13 : 15,
                ),
              ),
              const Spacer(),
              if (!narrow) ...[
                _NavLink(
                    label: 'Beranda',
                    solid: solid,
                    onTap: () => onNav('home')),
                _NavLink(
                    label: 'Berita',
                    solid: solid,
                    onTap: () => onNav('news')),
                _NavLink(
                    label: 'Galeri',
                    solid: solid,
                    onTap: () => onNav('gallery')),
                _NavLink(
                    label: 'Tentang',
                    solid: solid,
                    onTap: () => onNav('about')),
                const SizedBox(width: 8),
              ],
              OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: solid ? scheme.primary : Colors.white,
                  side: BorderSide(
                      color: solid
                          ? scheme.primary
                          : Colors.white.withValues(alpha: 0.7)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Masuk'),
              ),
              const SizedBox(width: 8),
              if (!narrow)
                FilledButton(
                  onPressed: () => context.go('/enroll'),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Daftar Siswa'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(
      {required this.label, required this.solid, required this.onTap});
  final String label;
  final bool solid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: solid ? scheme.onSurface : Colors.white,
      ),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 720;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 560),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.tertiary, 0.6)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -60,
            top: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: -80,
            bottom: -60,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(
                narrow ? 20 : 60, 100, narrow ? 20 : 60, 60),
            child: narrow
                ? _HeroContent(scheme: scheme, theme: theme)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 6,
                          child: _HeroContent(scheme: scheme, theme: theme)),
                      const SizedBox(width: 40),
                      Expanded(flex: 4, child: _HeroIllustration()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.scheme, required this.theme});
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Sistem Manajemen Pembelajaran',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Belajar Lebih Cerdas,\nBersama SMK N 1 Pati',
          style: theme.textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Platform pembelajaran digital terpadu untuk siswa, guru, dan orang tua. '
          'Akses materi, ujian, jurnal, dan informasi sekolah dalam satu sistem yang mudah digunakan.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => GoRouter.of(context).go('/login'),
              icon: const Icon(Icons.login_outlined),
              label: const Text('Masuk ke Sistem'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: scheme.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 14),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => GoRouter.of(context).go('/enroll'),
              icon: const Icon(Icons.assignment_ind_outlined),
              label: const Text('Daftar Siswa Baru'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IllustrationRow(icon: Icons.quiz_outlined, label: 'Ujian Online',
              value: '24 aktif'),
          const Divider(color: Colors.white24, height: 24),
          _IllustrationRow(icon: Icons.menu_book_outlined, label: 'Materi',
              value: '9 mata pelajaran'),
          const Divider(color: Colors.white24, height: 24),
          _IllustrationRow(icon: Icons.groups_outlined, label: 'Siswa Aktif',
              value: '40+ siswa'),
          const Divider(color: Colors.white24, height: 24),
          _IllustrationRow(icon: Icons.event_available_outlined,
              label: 'Presensi', value: 'Real-time'),
        ],
      ),
    );
  }
}

class _IllustrationRow extends StatelessWidget {
  const _IllustrationRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ],
    );
  }
}

// ─── Stats ────────────────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  static const _stats = [
    (Icons.groups_outlined, '40+', 'Siswa Aktif'),
    (Icons.school_outlined, '6', 'Guru Pengajar'),
    (Icons.menu_book_outlined, '7', 'Mata Pelajaran'),
    (Icons.emoji_events_outlined, '12+', 'Prestasi Sekolah'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final count = width > 900 ? 4 : width > 600 ? 2 : 2;

    return Container(
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: GridView.count(
        crossAxisCount: count,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: _stats
            .map((s) => _StatChip(icon: s.$1, value: s.$2, label: s.$3))
            .toList(),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: scheme.primary, size: 32),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary)),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}

// ─── Features ─────────────────────────────────────────────────────────────────

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  static const _features = [
    (
      Icons.quiz_outlined,
      'Ujian Online',
      'Siswa mengerjakan soal pilihan ganda, benar/salah, dan esai langsung dari browser. Hasil langsung tersedia setelah pengerjaan.',
    ),
    (
      Icons.menu_book_outlined,
      'Materi Digital',
      'Guru mengunggah dan mengelola materi pelajaran per kelas dan mata pelajaran. Siswa bisa mengakses kapan saja.',
    ),
    (
      Icons.fact_check_outlined,
      'Presensi Cerdas',
      'Guru mencatat kehadiran siswa secara digital. Orang tua dapat memantau rekam presensi anak secara real-time.',
    ),
    (
      Icons.event_note_outlined,
      'Jurnal Mengajar',
      'Guru mencatat kegiatan pembelajaran harian. Laporan jurnal dapat dicetak untuk kebutuhan administrasi.',
    ),
    (
      Icons.assessment_outlined,
      'Laporan Nilai',
      'Admin dan orang tua dapat melihat rekap nilai siswa dari seluruh ujian yang telah dikerjakan.',
    ),
    (
      Icons.family_restroom_outlined,
      'Portal Orang Tua',
      'Pantau perkembangan belajar, presensi, dan nilai anak Anda melalui akun khusus orang tua.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final cols = width > 900 ? 3 : width > 580 ? 2 : 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          _SectionHeader(
            label: 'FITUR UNGGULAN',
            title: 'Semua yang Dibutuhkan\ndalam Satu Platform',
            subtitle:
                'Dirancang untuk mempermudah proses belajar-mengajar di SMK Negeri 1 Pati.',
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: width > 900 ? 1.5 : 1.6,
            ),
            itemCount: _features.length,
            itemBuilder: (_, i) {
              final f = _features[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(f.$1, color: scheme.primary, size: 22),
                      ),
                      const SizedBox(height: 14),
                      Text(f.$2,
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          f.$3,
                          style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── News ─────────────────────────────────────────────────────────────────────

class _NewsSection extends StatelessWidget {
  const _NewsSection();

  static const _news = kNewsArticles;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final cols = width > 840 ? 3 : width > 560 ? 2 : 1;

    return Container(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          _SectionHeader(
            label: 'BERITA',
            title: 'Berita & Pengumuman\nTerkini',
            subtitle: 'Informasi terbaru seputar kegiatan dan prestasi sekolah.',
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: width > 840 ? 0.85 : 1.0,
            ),
            itemCount: _news.length,
            itemBuilder: (_, i) {
              final n = _news[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go('/berita/${n.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            NetworkImageBox(
                              url: n.imageUrl(800),
                              color: n.color,
                              icon: n.icon,
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: _CategoryBadge(
                                  label: n.category, color: n.color),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  n.excerpt,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 12,
                                      height: 1.5),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 12,
                                      color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    n.date,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: scheme.onSurfaceVariant),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Selengkapnya',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: n.color),
                                  ),
                                  Icon(Icons.arrow_forward,
                                      size: 12, color: n.color),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Gambar jaringan dengan placeholder berwarna + ikon saat memuat/gagal.
class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    required this.url,
    required this.color,
    required this.icon,
    this.iconSize = 54,
  });

  final String url;
  final Color color;
  final IconData icon;
  final double iconSize;

  Widget _fallback() => Container(
        color: color.withValues(alpha: 0.12),
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize, color: color.withValues(alpha: 0.4)),
      );

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _fallback(),
      errorBuilder: (context, error, stack) => _fallback(),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ─── Gallery ──────────────────────────────────────────────────────────────────

class _GallerySection extends StatelessWidget {
  const _GallerySection();

  static final _gallery = [
    _GalleryItem('Laboratorium Komputer', Icons.computer_outlined,
        Color(0xFF1976D2), 'photo-1581091226825-a6a2a5aee158'),
    _GalleryItem('Bengkel Otomotif', Icons.car_repair_outlined,
        Color(0xFFE65100), 'photo-1606761568499-6d2451b23c66'),
    _GalleryItem('Perpustakaan Digital', Icons.local_library_outlined,
        Color(0xFF388E3C), 'photo-1481627834876-b7833e8f5570'),
    _GalleryItem('Kegiatan Siswa', Icons.flag_outlined,
        Color(0xFF7B1FA2), 'photo-1488521787991-ed7bbaae773c'),
    _GalleryItem('Kegiatan Olahraga', Icons.sports_soccer_outlined,
        Color(0xFFF57C00), 'photo-1574629810360-7efbbe195018'),
    _GalleryItem('Wisuda & Kelulusan', Icons.school_outlined,
        Color(0xFF00838F), 'photo-1524178232363-1fb2b075b655'),
  ];

  static String _galleryUrl(String photo) =>
      'https://images.unsplash.com/$photo?auto=format&fit=crop&w=700&q=70';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 900 ? 3 : width > 560 ? 2 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          _SectionHeader(
            label: 'GALERI',
            title: 'Galeri Foto\nKegiatan Sekolah',
            subtitle:
                'Dokumentasi berbagai kegiatan, fasilitas, dan momen berharga di SMK Negeri 1 Pati.',
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemCount: _gallery.length,
            itemBuilder: (_, i) {
              final g = _gallery[i];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkImageBox(
                      url: _galleryUrl(g.photo),
                      color: g.color,
                      icon: g.icon,
                      iconSize: 56,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xCC000000),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          g.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    // Hover overlay
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        splashColor: g.color.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GalleryItem {
  const _GalleryItem(this.title, this.icon, this.color, this.photo);
  final String title;
  final IconData icon;
  final Color color;
  final String photo;
}

// ─── Info Sekolah ─────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 760;

    return Container(
      color: scheme.primaryContainer.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          _SectionHeader(
            label: 'INFO SEKOLAH',
            title: 'Tentang SMK Negeri 1 Pati',
            subtitle:
                'Sekolah Menengah Kejuruan unggulan di Pati dengan fokus pada kompetensi teknik dan teknologi.',
          ),
          const SizedBox(height: 40),
          narrow
              ? Column(
                  children: [
                    _AboutCard(),
                    const SizedBox(height: 16),
                    _ContactCard(),
                    const SizedBox(height: 16),
                    _HoursCard(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _AboutCard()),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _ContactCard(),
                          const SizedBox(height: 16),
                          _HoursCard(),
                        ],
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 36),
          // CTA Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.tertiary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: narrow
                ? Column(
                    children: [
                      Text(
                        'Bergabunglah Bersama Kami',
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Daftarkan putra-putri Anda sekarang dan raih masa depan cerah bersama SMK N 1 Pati.',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => GoRouter.of(context).go('/enroll'),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Daftar Sekarang'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: scheme.primary,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bergabunglah Bersama Kami',
                              style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Daftarkan putra-putri Anda sekarang dan raih masa depan cerah bersama SMK N 1 Pati.',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      FilledButton.icon(
                        onPressed: () => GoRouter.of(context).go('/enroll'),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Daftar Sekarang'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: scheme.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Profil Sekolah',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: scheme.primary)),
              ],
            ),
            const Divider(height: 20),
            _InfoRow2(label: 'NPSN', value: '20317573'),
            _InfoRow2(label: 'Status', value: 'Negeri'),
            _InfoRow2(label: 'Akreditasi', value: 'A (Unggul)'),
            _InfoRow2(label: 'Kepala Sekolah', value: 'Drs. H. Slamet, M.Pd.'),
            _InfoRow2(label: 'Tahun Berdiri', value: '1968'),
            _InfoRow2(
              label: 'Program Keahlian',
              value:
                  'Teknik Otomotif, Teknik Pemesinan, Teknik Instalasi Tenaga Listrik, Multimedia',
            ),
            const SizedBox(height: 8),
            Text(
              'SMK Negeri 1 Pati merupakan sekolah kejuruan terkemuka yang telah mencetak ribuan tenaga ahli siap kerja di berbagai bidang teknik dan teknologi selama lebih dari 5 dekade.',
              style: TextStyle(
                  color: scheme.onSurfaceVariant, fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_phone_outlined,
                    color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Kontak',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: scheme.primary)),
              ],
            ),
            const Divider(height: 20),
            _ContactRow(
                icon: Icons.location_on_outlined,
                text:
                    'Jl. AMD Patiunus No. 1, Pati Lor, Kabupaten Pati, Jawa Tengah 59114'),
            const SizedBox(height: 12),
            _ContactRow(
                icon: Icons.phone_outlined, text: '(0291) 431947'),
            const SizedBox(height: 12),
            _ContactRow(
                icon: Icons.email_outlined,
                text: 'info@smkn1pati.sch.id'),
            const SizedBox(height: 12),
            _ContactRow(
                icon: Icons.language_outlined,
                text: 'www.smkn1pati.sch.id'),
          ],
        ),
      ),
    );
  }
}

class _HoursCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_outlined, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Jam Operasional',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: scheme.primary)),
              ],
            ),
            const Divider(height: 20),
            _InfoRow2(label: 'Senin – Kamis', value: '07.00 – 15.30 WIB'),
            _InfoRow2(label: 'Jumat', value: '07.00 – 11.30 WIB'),
            _InfoRow2(label: 'Sabtu', value: '07.00 – 13.30 WIB'),
            _InfoRow2(label: 'Minggu', value: 'Libur'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow2 extends StatelessWidget {
  const _InfoRow2({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(
                    color: scheme.onSurfaceVariant, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13, height: 1.4)),
        ),
      ],
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({required this.onNav});
  final void Function(String target) onNav;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final narrow = width < 720;

    return Container(
      color: scheme.onSurface.withValues(alpha: 0.92),
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
      child: Column(
        children: [
          narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FooterBrand(scheme: scheme, theme: theme),
                    const SizedBox(height: 32),
                    _FooterLinks(scheme: scheme, onNav: onNav),
                    const SizedBox(height: 32),
                    _FooterContact(scheme: scheme),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 4,
                        child: _FooterBrand(scheme: scheme, theme: theme)),
                    const SizedBox(width: 32),
                    Expanded(
                        flex: 3,
                        child: _FooterLinks(scheme: scheme, onNav: onNav)),
                    const SizedBox(width: 32),
                    Expanded(
                        flex: 3,
                        child: _FooterContact(scheme: scheme)),
                  ],
                ),
          const SizedBox(height: 40),
          Divider(color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '© 2026 SMK Negeri 1 Pati. Hak cipta dilindungi.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () => GoRouter.of(context).go('/login'),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.5)),
                child: const Text('Portal Masuk', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand({required this.scheme, required this.theme});
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.school, color: scheme.primary, size: 26),
            const SizedBox(width: 10),
            Text('SMK N 1 Pati',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Membentuk generasi penerus bangsa yang kompeten, berkarakter, dan siap menghadapi tantangan industri global.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              height: 1.6),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _SocialIcon(icon: Icons.facebook_outlined, onTap: () {}),
            _SocialIcon(icon: Icons.share_outlined, onTap: () {}),
            _SocialIcon(icon: Icons.play_circle_outline, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({required this.scheme, required this.onNav});
  final ColorScheme scheme;
  final void Function(String target) onNav;

  @override
  Widget build(BuildContext context) {
    const links = <(String, String)>[
      ('Profil Sekolah', 'about'),
      ('Program Keahlian', 'features'),
      ('Berita & Prestasi', 'news'),
      ('Galeri', 'gallery'),
      ('PPDB Online', 'enroll'),
      ('Hubungi Kami', 'about'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tautan',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
        const SizedBox(height: 14),
        ...links.map(
          (l) => InkWell(
            onTap: () => onNav(l.$2),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(l.$1,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13)),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterContact extends StatelessWidget {
  const _FooterContact({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hubungi Kami',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
        const SizedBox(height: 14),
        _FooterContactRow(
            icon: Icons.location_on_outlined,
            text: 'Jl. AMD Patiunus No. 1\nPati Lor, Pati 59114'),
        const SizedBox(height: 10),
        _FooterContactRow(
            icon: Icons.phone_outlined, text: '(0291) 431947'),
        const SizedBox(height: 10),
        _FooterContactRow(
            icon: Icons.email_outlined, text: 'info@smkn1pati.sch.id'),
      ],
    );
  }
}

class _FooterContactRow extends StatelessWidget {
  const _FooterContactRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.white54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  height: 1.4)),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.white54),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.label, required this.title, required this.subtitle});
  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.8),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800, height: 1.25),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: scheme.onSurfaceVariant, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}
