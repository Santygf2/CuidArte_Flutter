import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class CuidArteHeader extends StatelessWidget implements PreferredSizeWidget {
  final int activeIndex;
  final Function(int) onTabSelected;
  final VoidCallback onLoginPressed;

  const CuidArteHeader({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
    required this.onLoginPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48.0 : 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LOGO
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onTabSelected(0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 46,
                        width: 46,
                        errorBuilder: (_, __, ___) => Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            gradient: AppColors.brandGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite, color: Colors.white, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => AppColors.brandGradient.createShader(bounds),
                        child: Text(
                          'CuidArte',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // DESKTOP NAVIGATION
              if (isDesktop) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNavItem('Inicio', 0),
                    const SizedBox(width: 24),
                    _buildNavItem('Contáctanos', 1),
                    const SizedBox(width: 24),
                    _buildNavItem('Sobre Nosotros', 2),
                    const SizedBox(width: 24),
                    _buildNavItem('Servicios', 3),
                    const SizedBox(width: 24),
                    _buildNavItem('Tienda', 4),
                  ],
                ),

                // INGRESAR BUTTON
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onLoginPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Ingresar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // MOBILE / TABLET ACTIONS
                Row(
                  children: [
                    // Quick Login Button on Mobile
                    GestureDetector(
                      onTap: onLoginPressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Ingresar',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Builder(
                      builder: (scaffoldContext) => IconButton(
                        icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 28),
                        onPressed: () {
                          Scaffold.of(scaffoldContext).openEndDrawer();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, int index) {
    final bool isActive = activeIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2.5,
                width: isActive ? 24 : 0,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
