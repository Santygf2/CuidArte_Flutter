import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/cuidarte_footer.dart';

class SobreNosotrosScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const SobreNosotrosScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. HERO HEADER (Screenshot 5)
          _buildHeroHeader(isDesktop),

          // 2. NUESTRO EQUIPO (Screenshot 5)
          _buildTeamSection(context, isDesktop),

          // 3. STATS SECTION (Screenshot 5)
          _buildStatsSection(context, isDesktop),

          // 4. NUESTRA ESENCIA: MISIÓN, VISIÓN, VALORES (Screenshot 5)
          _buildEssenceSection(context, isDesktop),

          // 5. FOOTER
          CuidArteFooter(onNavigateTab: onNavigateTab),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(bool isDesktop) {
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
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: isDesktop ? 70.0 : 45.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              Text(
                'Más sobre nosotros',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 44 : 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 16.5 : 14.5,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.65,
                  ),
                  children: const [
                    TextSpan(text: 'En '),
                    TextSpan(
                      text: 'CuidArte',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ', nuestra misión es ser el puente de confianza y bienestar que une a las familias con los mejores profesionales del cuidado.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context, bool isDesktop) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              Text(
                'Nuestro Equipo',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 36),

              // Two Team Cards
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 560;
                    if (isNarrow) {
                      return Column(
                        children: [
                          _buildTeamCard(
                            image: 'assets/images/santiago.png',
                            name: 'Santiago Grajales Franco',
                            role: 'Co-fundador',
                            badgeBg: const Color(0xFFE0F2FE),
                            badgeColor: const Color(0xFF0284C7),
                            imageBg: const Color(0xFFE0F2FE),
                          ),
                          const SizedBox(height: 24),
                          _buildTeamCard(
                            image: 'assets/images/keren.png',
                            name: 'Keren Tatiana Becerra Molina',
                            role: 'Co-fundadora',
                            badgeBg: const Color(0xFFFCE7F3),
                            badgeColor: const Color(0xFFBE185D),
                            imageBg: const Color(0xFFFCE7F3),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _buildTeamCard(
                            image: 'assets/images/santiago.png',
                            name: 'Santiago Grajales Franco',
                            role: 'Co-fundador',
                            badgeBg: const Color(0xFFE0F2FE),
                            badgeColor: const Color(0xFF0284C7),
                            imageBg: const Color(0xFFE0F2FE),
                          ),
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          child: _buildTeamCard(
                            image: 'assets/images/keren.png',
                            name: 'Keren Tatiana Becerra Molina',
                            role: 'Co-fundadora',
                            badgeBg: const Color(0xFFFCE7F3),
                            badgeColor: const Color(0xFFBE185D),
                            imageBg: const Color(0xFFFCE7F3),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 36),

              // Description Card
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Comprendemos la profunda responsabilidad y el amor que implica buscar el apoyo ideal para nuestros seres queridos mayores. Somos una plataforma diseñada para fomentar el bienestar integral y la salud emocional de la persona mayor, brindando tranquilidad y apoyo a sus familias y cuidadores.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4B5563),
                      fontSize: 14.5,
                      height: 1.7,
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

  Widget _buildTeamCard({
    required String image,
    required String name,
    required String role,
    required Color badgeBg,
    required Color badgeColor,
    required Color imageBg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image header
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: imageBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.person, color: badgeColor, size: 64),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              if (isSmall) {
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildStatItem('10+', 'ESPECIALIDADES'),
                    _buildStatItem('100%', 'COMPROMISO'),
                    _buildStatItem('24/7', 'DISPONIBILIDAD'),
                    _buildStatItem('∞', 'DEDICACIÓN'),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('10+', 'ESPECIALIDADES'),
                  _buildStatItem('100%', 'COMPROMISO'),
                  _buildStatItem('24/7', 'DISPONIBILIDAD'),
                  _buildStatItem('∞', 'DEDICACIÓN'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildEssenceSection(BuildContext context, bool isDesktop) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            children: [
              Text(
                'Nuestra Esencia',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 36),

              // 3 Cards: Misión, Visión, Valores
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 800;
                  if (isNarrow) {
                    return Column(
                      children: [
                        _buildEssenceCard(
                          emoji: '🎯',
                          title: 'Misión',
                          desc: 'Ser el puente que une a las familias con cuidadores especializados para ofrecer atención compasiva y personalizada para adultos mayores.',
                          topBorderColor: const Color(0xFF27BEF5),
                          iconBg: const Color(0xFFE0F2FE),
                        ),
                        const SizedBox(height: 20),
                        _buildEssenceCard(
                          emoji: '🌟',
                          title: 'Visión',
                          desc: 'Ser la plataforma líder en cuidado geriátrico, conectando familias con cuidadores expertos de excelencia humana.',
                          topBorderColor: const Color(0xFFF59E0B),
                          iconBg: const Color(0xFFFEF3C7),
                        ),
                        const SizedBox(height: 20),
                        _buildValoresCard(),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildEssenceCard(
                          emoji: '🎯',
                          title: 'Misión',
                          desc: 'Ser el puente que une a las familias con cuidadores especializados para ofrecer atención compasiva y personalizada para adultos mayores.',
                          topBorderColor: const Color(0xFF27BEF5),
                          iconBg: const Color(0xFFE0F2FE),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildEssenceCard(
                          emoji: '🌟',
                          title: 'Visión',
                          desc: 'Ser la plataforma líder en cuidado geriátrico, conectando familias con cuidadores expertos de excelencia humana.',
                          topBorderColor: const Color(0xFFF59E0B),
                          iconBg: const Color(0xFFFEF3C7),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildValoresCard(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEssenceCard({
    required String emoji,
    required String title,
    required String desc,
    required Color topBorderColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -24,
            left: -24,
            right: -24,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: topBorderColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValoresCard() {
    final valores = ['Empatía', 'Respeto', 'Compromiso', 'Inclusión'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -24,
            left: -24,
            right: -24,
            child: Container(
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('💎', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Valores',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: valores.map((valor) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      valor,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
