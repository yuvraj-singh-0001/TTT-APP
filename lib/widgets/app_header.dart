import 'package:flutter/material.dart';

import '../app_branding.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.height = 86,
    this.logoWidth = 180,
    this.title = 'Top The Real Exam',
  });

  final double height;
  final double logoWidth;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      titleSpacing: 16,
      title: Row(
        children: [
          Hero(
            tag: kBrandHeroTag,
            child: const Material(
              color: Colors.transparent,
              child: BrandLogo(width: 180),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
            ),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kBrandBlack, kBrandSurface],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
