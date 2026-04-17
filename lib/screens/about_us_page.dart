import 'package:flutter/material.dart';

import '../app_branding.dart';
import '../widgets/app_header.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _titleFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _titleFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    ));

    _contentFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'About Us'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _titleFade,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Us',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: kBrandGold,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The True Topper',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Hello! We are The True Topper and people call us TTT.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            height: 1.6,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _slideUp,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kBrandBlack.withAlpha(220),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: kBrandGold.withAlpha(180), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: kBrandGold.withAlpha(40),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TTT is a movement which aims to harness the true potential of every human being with particular focus on students.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.7,
                            ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'TTT provides students with the required skill set which will not only ensure their academic and materialistic excellence, but also ensure their all-round development so that they can truly enjoy their success.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.7,
                            ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'TTT achieves this through different sessions, workshops, and activities delivered through our unique concept of TTT CUP.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.7,
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandGold,
                          foregroundColor: kBrandBlack,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Learn More About Us',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
