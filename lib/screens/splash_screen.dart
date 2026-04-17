import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_branding.dart';

const _kSplashDuration = Duration(seconds: 2);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _backdropFade;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoLift;
  late final Animation<double> _titleFade;
  late final Animation<double> _loaderFade;
  Timer? _timer;
  bool _didNavigate = false;
  bool _logoPrecached = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _kSplashDuration)
      ..forward();

    _backdropFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.16, curve: Curves.easeOut),
    );
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.84, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.24, curve: Curves.easeOutBack),
      ),
    );
    _logoLift = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.22, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.08, 0.28, curve: Curves.easeOut),
    );
    _loaderFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.32, curve: Curves.easeOut),
    );
    _timer = Timer(_kSplashDuration, _goHome);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_logoPrecached) return;
    _logoPrecached = true;
    precacheImage(const AssetImage(kBrandLogoAsset), context);
  }

  void _goHome() {
    if (!mounted || _didNavigate) return;
    _didNavigate = true;
    final onFinished = widget.onFinished;
    onFinished?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrandBlack,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
                  return const SizedBox.expand();
                }

                final availableCardWidth = (constraints.maxWidth - 28).clamp(
                  240.0,
                  520.0,
                );
                final cardWidth = availableCardWidth.toDouble();
                final logoWidth = math.min(cardWidth - 24.0, 340.0);

                return Stack(
                  children: [
                    Opacity(
                      opacity: _backdropFade.value,
                      child: const _SplashBackground(),
                    ),
                    Opacity(
                      opacity:
                          1 -
                          ((_controller.value - 0.76) / 0.24).clamp(0.0, 1.0),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          Center(
                            child: Transform.translate(
                              offset: Offset(0, _logoLift.value),
                              child: Opacity(
                                opacity: _logoFade.value,
                                child: Transform.scale(
                                  scale: _logoScale.value,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: cardWidth,
                                      minWidth: 220.0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              34,
                                            ),
                                            color: const Color(0xFF070707),
                                            border: Border.all(
                                              color: kBrandGold.withAlpha(220),
                                              width: 3.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: kBrandGold.withAlpha(50),
                                                blurRadius: 38,
                                                spreadRadius: 3.5,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 22,
                                              vertical: 22,
                                            ),
                                            child: BrandLogo(width: logoWidth),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Opacity(
                                          opacity: _titleFade.value,
                                          child: Text(
                                            'The True Topper',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Opacity(
                            opacity: _loaderFade.value,
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: 46),
                              child: SizedBox(
                                width: 46,
                                height: 46,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.8,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    kBrandGold,
                                  ),
                                  backgroundColor: Color(0x22FFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF10100D),
                  Color(0xFF17120A),
                  Color(0xFF090705),
                  kBrandBlack,
                ],
                stops: [0.0, 0.35, 0.72, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -50,
          child: _GlowOrb(size: 240, color: kBrandGold.withAlpha(34)),
        ),
        Positioned(
          right: -70,
          bottom: 100,
          child: _GlowOrb(size: 180, color: Colors.white.withAlpha(12)),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}
