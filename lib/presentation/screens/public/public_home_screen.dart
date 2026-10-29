import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/cuidarte_footer.dart';

class PublicHomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;
  final VoidCallback onLoginPressed;

  const PublicHomeScreen({
    super.key,
    required this.onNavigateTab,
    required this.onLoginPressed,
  });

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  final PageController _carouselController = PageController();
  int _currentSlide = 0;
  Timer? _carouselTimer;

  final List<String> _carouselImages = [
    'assets/images/principal.png',
    'assets/images/carrusel1.png',
    'assets/images/carrusel2.png',
    'assets/images/carrusel3.png',
  ];

  final List<Map<String, String>> _specialties = [
    {
      'title': 'Discapacidades Físicas',
      'desc': 'Rehabilitación y apoyo para movilidad reducida.',
      'image': 'assets/images/discapacidad.png',
    },
    {
      'title': 'Enfermedades Crónicas',
      'desc': 'Manejo integral de enfermedades como diabetes e hipertensión.',
      'image': 'assets/images/enfermedades.png',
    },
    {
      'title': 'Demencia y Alzheimer',
      'desc':
          'Acompañamiento especializado para personas con deterioro cognitivo.',
      'image': 'assets/images/demencia.png',
    },
    {
      'title': 'Geriatría',
      'desc': 'Atención médica y cuidado para adultos mayores.',
      'image': 'assets/images/geriatria.png',
    },
    {
      'title': 'Pediatría',
      'desc': 'Cuidado médico para niños y adolescentes.',
      'image': 'assets/images/pediatria.png',
    },
    {
      'title': 'Oncología',
      'desc': 'Diagnóstico y tratamiento integral para pacientes oncológicos.',
      'image': 'assets/images/oncologia.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_carouselController.hasClients) {
        final nextPage = (_currentSlide + 1) % _carouselImages.length;
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _resetTimer() {
    _carouselTimer?.cancel();
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. HERO SECTION (Identical to Screenshot 1)
          _buildHeroSection(context, isDesktop),

          // 2. SOBRE NOSOTROS PREVIEW (Identical to Screenshot 2)
          _buildAboutPreviewSection(context),

          // 3. NUESTRAS ESPECIALIDADES (Identical to Screenshot 2)
          _buildSpecialtiesSection(context, screenWidth),

          // 4. FOOTER (Identical to Screenshot 4)
          CuidArteFooter(onNavigateTab: widget.onNavigateTab),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA), Color(0xFF27BEF5)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative translucent background circle
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Hero Content
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 24.0,
                vertical: isDesktop ? 68.0 : 40.0,
              ),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 11,
                          child: _buildHeroLeftText(context, true),
                        ),
                        const SizedBox(width: 50),
                        Expanded(flex: 10, child: _buildCarousel(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildHeroLeftText(context, false),
                        const SizedBox(height: 36),
                        _buildCarousel(context),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroLeftText(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          'Tu bienestar comienza\ncon CuidArte',
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 42 : 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.15,
            letterSpacing: -0.8,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.12),
                offset: const Offset(0, 3),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Conectamos familias con cuidadores profesionales verificados y te acompañamos con talleres, recursos y suministros para el bienestar integral.',
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 16.5 : 14.5,
            color: Colors.white.withOpacity(0.93),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 30),

        // Action Buttons Row
        Wrap(
          spacing: 24,
          runSpacing: 16,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // White pill button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onLoginPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    'Buscar cuidador',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Underlined text link: Ver servicios
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => widget.onNavigateTab(3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Ver servicios',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),

        // Hero Trust Stats (Screenshot 1)
        Wrap(
          spacing: 28,
          runSpacing: 14,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _buildTrustBadge('+500', 'familias atendidas'),
            _buildTrustBadge('100%', 'cuidadores verificados'),
            _buildTrustBadge('4.9★', 'valoración promedio'),
          ],
        ),
      ],
    );
  }

  Widget _buildTrustBadge(String strongText, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          strongText,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.92),
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return Container(
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 35,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // PageView slides
            PageView.builder(
              controller: _carouselController,
              itemCount: _carouselImages.length,
              onPageChanged: (index) {
                setState(() => _currentSlide = index);
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _carouselImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white.withOpacity(0.2),
                    child: const Center(
                      child: Icon(Icons.photo, color: Colors.white, size: 60),
                    ),
                  ),
                );
              },
            ),

            // Left arrow button
            Positioned(
              left: 16,
              child: _buildCarouselArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  final prevPage =
                      (_currentSlide - 1 + _carouselImages.length) %
                      _carouselImages.length;
                  _carouselController.animateToPage(
                    prevPage,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                  _resetTimer();
                },
              ),
            ),

            // Right arrow button
            Positioned(
              right: 16,
              child: _buildCarouselArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  final nextPage = (_currentSlide + 1) % _carouselImages.length;
                  _carouselController.animateToPage(
                    nextPage,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                  _resetTimer();
                },
              ),
            ),

            // Indicators at bottom (Screenshot 1)
            Positioned(
              bottom: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_carouselImages.length, (index) {
                  final bool isActive = _currentSlide == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 34 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
      ),
    );
  }

  Widget _buildAboutPreviewSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              Text(
                'Sobre nosotros',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'En CuidArte promovemos la salud mental y el bienestar emocional a través de herramientas, talleres y acompañamiento profesional. Creemos que el cuidado propio es la base para transformar nuestra vida y entorno.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  color: AppColors.textMuted,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 28),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () =>
                      widget.onNavigateTab(2), // Switches to Sobre Nosotros tab
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Text(
                      'Conoce más',
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtiesSection(BuildContext context, double screenWidth) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Nuestras especialidades',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Un equipo multidisciplinario para acompañarte en cada etapa del cuidado.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 48),

              // Responsive Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 3;
                  if (constraints.maxWidth < 650) {
                    crossAxisCount = 1;
                  } else if (constraints.maxWidth < 950) {
                    crossAxisCount = 2;
                  }

                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: _specialties.map((item) {
                      double itemWidth;
                      if (crossAxisCount == 1) {
                        itemWidth = constraints.maxWidth;
                      } else if (crossAxisCount == 2) {
                        itemWidth = (constraints.maxWidth - 24) / 2;
                      } else {
                        itemWidth = (constraints.maxWidth - 48) / 3;
                      }

                      return SizedBox(
                        width: itemWidth,
                        child: _buildSpecialtyCard(item),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard(Map<String, String> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEEF2F7)),
            ),
            child: Image.asset(
              item['image']!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.medical_services_outlined,
                color: AppColors.primary,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item['title']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item['desc']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
