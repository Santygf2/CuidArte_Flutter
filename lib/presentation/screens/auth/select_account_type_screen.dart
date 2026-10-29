import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/auth/auth_app_bar.dart';
import '../../widgets/auth/auth_background.dart';
import 'login_screen.dart';
import 'register_caregiver_screen.dart';
import 'register_client_screen.dart';

class SelectAccountTypeScreen extends StatelessWidget {
  const SelectAccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CuidArteAuthAppBar(),
      body: AuthBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 20,
                vertical: isDesktop ? 56 : 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Text(
                        '¿Cómo deseas unirte a CuidArte?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 40 : 27,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Selecciona el tipo de cuenta que mejor se ajuste a tus necesidades',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 17 : 14.5,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildClientCard(context)),
                            const SizedBox(width: 30),
                            Expanded(child: _buildCaregiverCard(context)),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildClientCard(context),
                            const SizedBox(height: 26),
                            _buildCaregiverCard(context),
                          ],
                        ),
                      const SizedBox(height: 42),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes una cuenta? ',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.94),
                              fontSize: 14.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: Text(
                              'Inicia sesión aquí',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context) {
    return _TypeCard(
      accent: AppColors.primary,
      accentGradient: AppColors.brandGradient,
      iconGradient: const LinearGradient(
        colors: [Color(0xFFE3F8FF), Color(0xFFB3E5FC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.home_outlined,
      iconColor: AppColors.primary,
      title: 'Busco Cuidador',
      description:
          'Encuentra profesionales certificados para el cuidado que necesitas',
      benefits: const [
        'Acceso a cuidadores verificados',
        'Reserva fácil y rápida',
        'Seguimiento 24/7',
      ],
      buttonText: 'Registrarme como Cliente',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RegisterClientScreen()),
        );
      },
    );
  }

  Widget _buildCaregiverCard(BuildContext context) {
    return _TypeCard(
      accent: AppColors.caregiver,
      accentGradient: const LinearGradient(
        colors: [AppColors.caregiver, AppColors.caregiverLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      iconGradient: const LinearGradient(
        colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.monitor_heart_outlined,
      iconColor: AppColors.caregiver,
      title: 'Soy Cuidador',
      description: 'Ofrece tus servicios profesionales y conecta con clientes',
      benefits: const [
        'Gestiona tu agenda',
        'Certificación profesional',
        'Plataforma de confianza',
      ],
      buttonText: 'Registrarme como Cuidador',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RegisterCaregiverScreen()),
        );
      },
    );
  }
}

class _TypeCard extends StatelessWidget {
  final Color accent;
  final Gradient accentGradient;
  final Gradient iconGradient;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<String> benefits;
  final String buttonText;
  final VoidCallback onTap;

  const _TypeCard({
    required this.accent,
    required this.accentGradient,
    required this.iconGradient,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.benefits,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 36 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: iconGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 40, color: iconColor),
          ),
          const SizedBox(height: 25),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 30 : 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, size: 20, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      benefit,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: accentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        buttonText,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
