import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class CuidArteLogo extends StatelessWidget {
  final double imageSize;
  final double fontSize;

  const CuidArteLogo({
    super.key,
    this.imageSize = 42,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: imageSize,
          width: imageSize,
          errorBuilder: (_, __, ___) => Icon(
            Icons.favorite_rounded,
            color: AppColors.primary,
            size: imageSize,
          ),
        ),
        const SizedBox(width: 10),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.brandGradient.createShader(bounds),
          child: Text(
            'CuidArte',
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
