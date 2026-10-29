import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_app_bar.dart';
import 'auth_background.dart';

class RegistrationLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final VoidCallback onLoginTap;

  const RegistrationLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.onLoginTap,
  });

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
                horizontal: isDesktop ? 40 : 18,
                vertical: isDesktop ? 36 : 26,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 60,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: isDesktop
                          ? IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 4, child: _BrandPanel()),
                                  Expanded(
                                    flex: 6,
                                    child: _FormPanel(
                                      title: title,
                                      subtitle: subtitle,
                                      form: form,
                                      onLoginTap: onLoginTap,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _FormPanel(
                              title: title,
                              subtitle: subtitle,
                              form: form,
                              onLoginTap: onLoginTap,
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const benefits = [
      'Acceso a especialistas certificados',
      'Talleres y recursos exclusivos',
      'Seguimiento personalizado 24/7',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 46),
          ),
          const SizedBox(height: 26),
          Text(
            '¡Únete a CuidArte!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Crea tu cuenta y accede a una plataforma completa de cuidado profesional.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.95),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          ...benefits.map(
            (benefit) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      benefit,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.3,
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
}

class _FormPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final VoidCallback onLoginTap;

  const _FormPanel({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ).createShader(bounds),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 26),
          form,
          const SizedBox(height: 22),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '¿Ya tienes una cuenta? ',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textMuted),
              ),
              GestureDetector(
                onTap: onLoginTap,
                child: Text(
                  'Inicia sesión',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
