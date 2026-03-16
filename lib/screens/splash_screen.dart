import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────
  late AnimationController _bgController;       // continuous slow rotation of bg circles
  late AnimationController _logoController;     // logo entrance sequence
  late AnimationController _particleController; // floating particles
  late AnimationController _textController;     // tagline & loader
  late AnimationController _exitController;     // full-screen exit fade

  // ── Logo animations ──────────────────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoPulse;
  late Animation<double> _logoRotate;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;

  // ── Text animations ───────────────────────────────────────
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _loaderOpacity;
  late Animation<double> _loaderProgress;

  // ── Exit ─────────────────────────────────────────────────
  late Animation<double> _exitOpacity;

  // ── Particles ─────────────────────────────────────────────
  final List<_Particle> _particles = [];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _generateParticles();
    _setupControllers();
    _startSequence();
  }

  void _generateParticles() {
    for (int i = 0; i < 22; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 6 + 2,
        speed: _rng.nextDouble() * 0.3 + 0.1,
        opacity: _rng.nextDouble() * 0.5 + 0.15,
        color: _rng.nextBool() ? AppTheme.primary : AppTheme.secondary,
        phase: _rng.nextDouble() * 2 * pi,
      ));
    }
  }

  void _setupControllers() {
    // Background slow rotation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Logo entrance: 0→1.2s
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15).chain(CurveTween(curve: Curves.easeOutBack)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 40),
    ]).animate(_logoController);

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    _logoPulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(),
      curve: Curves.easeInOut,
    ));

    _logoRotate = Tween<double>(begin: -0.15, end: 0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );

    _ringScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.4), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _ringOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.6), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 70),
    ]).animate(_logoController);

    // Floating particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Text entrance
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0, 0.5, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0, 0.6, curve: Curves.easeOutCubic)),
    );

    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic)),
    );

    _loaderOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _loaderProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)),
    );

    // Exit fade
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );
  }

  void _startSequence() async {
    // Small delay then logo bursts in
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoController.forward();

    // Text slides in after logo lands
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    _textController.forward();

    // Wait for progress bar to finish, then exit
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    await _exitController.forward();
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _exitOpacity,
      builder: (context, child) {
        return Opacity(
          opacity: _exitOpacity.value,
          child: child,
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ── Gradient background ───────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A0A18), Color(0xFF0F0F24), Color(0xFF0D1A2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // ── Rotating background orbs ──────────────────
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) {
                final angle = _bgController.value * 2 * pi;
                return Stack(children: [
                  Positioned(
                    left: size.width * 0.5 + cos(angle) * size.width * 0.35 - 120,
                    top: size.height * 0.3 + sin(angle) * size.height * 0.15 - 120,
                    child: _buildOrb(240, AppTheme.primary, 0.12),
                  ),
                  Positioned(
                    left: size.width * 0.5 + cos(angle + pi) * size.width * 0.3 - 100,
                    top: size.height * 0.6 + sin(angle + pi) * size.height * 0.12 - 100,
                    child: _buildOrb(200, AppTheme.secondary, 0.10),
                  ),
                  Positioned(
                    left: size.width * 0.2 + cos(angle + pi * 0.5) * size.width * 0.1 - 80,
                    top: size.height * 0.15 + sin(angle + pi * 0.5) * size.height * 0.08 - 80,
                    child: _buildOrb(160, AppTheme.accent, 0.08),
                  ),
                ]);
              },
            ),

            // ── Floating particles ────────────────────────
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _particleController.value,
                  ),
                );
              },
            ),

            // ── Grid lines (subtle) ───────────────────────
            CustomPaint(
              size: size,
              painter: _GridPainter(),
            ),

            // ── Main content ──────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo with ring burst
                  _buildLogo(size),

                  const SizedBox(height: 36),

                  // App name
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleOpacity,
                      child: Text(
                        'FundNovaX',
                        style: GoogleFonts.poppins(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(color: AppTheme.primary.withOpacity(0.6), blurRadius: 20),
                            Shadow(color: AppTheme.secondary.withOpacity(0.4), blurRadius: 40),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28, height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.transparent, AppTheme.secondary.withOpacity(0.7)]),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Smart Finance. Simplified.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.65),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 28, height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [AppTheme.secondary.withOpacity(0.7), Colors.transparent]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Progress loader
                  FadeTransition(
                    opacity: _loaderOpacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: _buildLoader(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Loading text
                  FadeTransition(
                    opacity: _loaderOpacity,
                    child: AnimatedBuilder(
                      animation: _loaderProgress,
                      builder: (_, __) {
                        final pct = (_loaderProgress.value * 100).toInt();
                        return Text(
                          'Loading... $pct%',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.35),
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Developer credit
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      'by A List Virtual Solution LLC',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.25),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrb(double size, Color color, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0)],
        ),
      ),
    );
  }

  Widget _buildLogo(Size screenSize) {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _logoPulse]),
      builder: (context, _) {
        return Transform.scale(
          scale: _logoScale.value * _logoPulse.value,
          child: Transform.rotate(
            angle: _logoRotate.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring burst
                Transform.scale(
                  scale: _ringScale.value,
                  child: Opacity(
                    opacity: _ringOpacity.value,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                // Secondary ring
                Transform.scale(
                  scale: _ringScale.value * 0.75,
                  child: Opacity(
                    opacity: _ringOpacity.value * 0.7,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.secondary.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Glow layer
                Opacity(
                  opacity: _logoOpacity.value * 0.5,
                  child: Container(
                    width: 130, height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 40, spreadRadius: 10),
                        BoxShadow(color: AppTheme.secondary.withOpacity(0.3), blurRadius: 60, spreadRadius: 5),
                      ],
                    ),
                  ),
                ),

                // Logo container
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B83FF), Color(0xFF6C63FF), Color(0xFF3ECFCF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary.withOpacity(0.6), blurRadius: 30, offset: const Offset(0, 8)),
                        BoxShadow(color: AppTheme.secondary.withOpacity(0.3), blurRadius: 50, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Center(
                      child: Text('🏦', style: TextStyle(fontSize: 52)),
                    ),
                  ),
                ),

                // Shine overlay
                Opacity(
                  opacity: _logoOpacity.value * 0.4,
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoader() {
    return AnimatedBuilder(
      animation: _loaderProgress,
      builder: (context, _) {
        return Column(
          children: [
            Stack(
              children: [
                // Track
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: _loaderProgress.value,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary.withOpacity(0.6), blurRadius: 6),
                      ],
                    ),
                  ),
                ),
                // Glow dot at tip
                if (_loaderProgress.value > 0.02)
                  FractionallySizedBox(
                    widthFactor: _loaderProgress.value,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 8, height: 8,
                        margin: const EdgeInsets.only(top: -2.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppTheme.secondary.withOpacity(0.9), blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ─── Particle data model ────────────────────────────────────────────────────
class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;
  final double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
    required this.phase,
  });
}

// ─── Particle painter ────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final x = (p.x * size.width + sin(t * 2 * pi + p.phase) * 40) % size.width;
      final y = (p.y * size.height - t * size.height * 0.4) % size.height;
      final alpha = (sin(t * pi) * p.opacity * 255).clamp(0, 255).toInt();

      final paint = Paint()
        ..color = p.color.withAlpha(alpha)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(Offset(x, y), p.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ─── Subtle grid painter ─────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5;

    const spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
