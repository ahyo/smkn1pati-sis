import 'package:flutter/material.dart';

// Shared widgets used by login_screen.dart and register_screen.dart.
// Mirrors the visual language of landing_screen.dart (same gradient, circles, nav).

class AuthGradientBg extends StatelessWidget {
  const AuthGradientBg({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              Color.lerp(scheme.primary, scheme.tertiary, 0.55)!,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -80,
              top: -60,
              child: _DecorCircle(300),
            ),
            Positioned(
              left: -100,
              bottom: -80,
              child: _DecorCircle(380),
            ),
            Positioned(
              right: 120,
              bottom: 160,
              child: _DecorCircle(160, alpha: 0.04),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle(this.size, {this.alpha = 0.06});
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class AuthTopBar extends StatelessWidget {
  const AuthTopBar({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
            tooltip: 'Kembali',
          ),
          const Icon(Icons.school, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'SMK Negeri 1 Pati',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthInfoPanel extends StatelessWidget {
  const AuthInfoPanel({
    super.key,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.bullets,
  });

  final String tag;
  final String title;
  final String subtitle;
  final List<(IconData, String)> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        ...bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Icon(b.$1, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 14),
                Text(
                  b.$2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
