import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -200,
            right: -100,
            child: _Bubble(size: 500),
          ),
          const Positioned(
            bottom: -100,
            left: -50,
            child: _Bubble(size: 300),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double size;

  const _Bubble({required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
