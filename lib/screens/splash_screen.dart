import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;
  bool _videoInitialized = false;
  bool _videoCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideo();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.asset('assets/videos/logo.mp4');
      _videoController = controller;
      await controller.initialize();
      await controller.setLooping(false);
      controller.addListener(_handleVideoProgress);

      if (!mounted) return;

      setState(() {
        _videoInitialized = true;
      });

      await controller.play();
    } catch (e) {
      if (!mounted) return;
      Future.delayed(const Duration(seconds: 2), _goToHome);
    }
  }

  void _handleVideoProgress() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized || _videoCompleted) {
      return;
    }

    final position = controller.value.position;
    final duration = controller.value.duration;

    if (duration > Duration.zero && position >= duration) {
      _videoCompleted = true;
      _goToHome();
    }
  }

  void _goToHome() {
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _videoController?.removeListener(_handleVideoProgress);
    _videoController?.pause();
    _videoController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;
    final isReady =
        _videoInitialized &&
        controller != null &&
        controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: isReady
                ? FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: controller!.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
