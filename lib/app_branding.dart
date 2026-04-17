import 'package:flutter/material.dart';

const String kBrandLogoAsset = 'assets/logo-image.png';
const String kBrandHeroTag = 'brand-logo-hero';

const Color kBrandGold = Color(0xFFFFBF12);
const Color kBrandGoldDeep = Color(0xFFF2A900);
const Color kBrandBlack = Color(0xFF050505);
const Color kBrandSurface = Color(0xFF121212);

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.width = 220,
    this.fit = BoxFit.contain,
  });

  final double width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      kBrandLogoAsset,
      width: width,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }
}
