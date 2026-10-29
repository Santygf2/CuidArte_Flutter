import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class CuidArteFooter extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const CuidArteFooter({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isTablet = width >= 600 && width < 900;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Top accent gradient bar
          Container(
            height: 3,
            decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          ),

          // Main footer content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60.0 : 24.0,
              vertical: 48.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildBrandCol()),
                        const SizedBox(width: 40),
                        Expanded(flex: 2, child: _buildNavCol()),
                        const SizedBox(width: 32),
                        Expanded(flex: 2, child: _buildHelpCol()),
                        const SizedBox(width: 32),
                        Expanded(flex: 2, child: _buildContactCol()),
                      ],
                    )
                  : isTablet
                  ? Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildBrandCol()),
                            const SizedBox(width: 30),
                            Expanded(child: _buildNavCol()),
                          ],
                        ),
                        const SizedBox(height: 36),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildHelpCol()),
                            const SizedBox(width: 30),
                            Expanded(child: _buildContactCol()),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandCol(),
                        const SizedBox(height: 32),
                        _buildNavCol(),
                        const SizedBox(height: 32),
                        _buildHelpCol(),
                        const SizedBox(height: 32),
                        _buildContactCol(),
                      ],
                    ),
            ),
          ),

          // Divider and Copyright
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60.0 : 24.0,
              vertical: 20.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '© 2026 CuidArte. Todos los derechos reservados.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.brandGradient.createShader(bounds),
              child: Text(
                'CuidArte',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Tu espacio para aprender a cuidarte, crecer y compartir bienestar. Conectamos familias con cuidadores profesionales verificados.',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.72),
            fontSize: 13.5,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _buildSocialButton(Icons.phone_outlined),
            const SizedBox(width: 10),
            _buildSocialButton(Icons.email_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildNavCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NAVEGACIÓN',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink('Inicio', 0),
        _buildFooterLink('Sobre Nosotros', 2),
        _buildFooterLink('Servicios', 3),
        _buildFooterLink('Tienda', 4),
      ],
    );
  }

  Widget _buildHelpCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AYUDA',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink('Contáctanos', 1),
        _buildFooterLink('Buscar Cuidadores', 3),
        _buildFooterLink('Suministros', 4),
        _buildFooterLink('Talleres', 3),
      ],
    );
  }

  Widget _buildContactCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACTO',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactLine('Medellín, Colombia'),
        _buildContactLine('cuidartesk@gmail.com'),
        _buildContactLine('Lun – Vie 8:00 – 18:00'),
      ],
    );
  }

  Widget _buildFooterLink(String label, int targetTab) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (onNavigateTab != null) {
              onNavigateTab!(targetTab);
            }
          },
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.72),
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.72),
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
