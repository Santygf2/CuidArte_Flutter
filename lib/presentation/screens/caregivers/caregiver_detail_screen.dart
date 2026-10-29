import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/caregiver_model.dart';
import '../../../providers/chat_provider.dart';
import '../chat/chat_screen.dart';
import 'schedule_visit_modal.dart';

class CaregiverDetailScreen extends StatelessWidget {
  final CaregiverModel caregiver;

  const CaregiverDetailScreen({super.key, required this.caregiver});

  void _openBookingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScheduleVisitModal(caregiver: caregiver),
    );
  }

  Future<void> _contactCaregiver(BuildContext context) async {
    try {
      final thread = await context.read<ChatProvider>().startThread(
        caregiver.id,
      );
      if (!context.mounted) return;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ChatScreen(thread: thread)));
    } on ApiException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rejected,
          content: Text(error.message),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = (width * 0.026).clamp(24.0, 33.6);
    final specialty = caregiver.specialties.isNotEmpty
        ? caregiver.specialties.first
        : 'Cuidador profesional';
    final age = caregiver.age ?? 0;
    final username = caregiver.username.isNotEmpty
        ? caregiver.username
        : caregiver.email.split('@').first;
    final isFallbackAvatar =
        caregiver.avatarUrl.isEmpty ||
        caregiver.avatarUrl.contains('user1.png');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Perfil del Cuidador')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Text(
                          caregiver.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Perfil profesional del cuidador',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 17.6,
                            color: Colors.white.withOpacity(0.94),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 36,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        label: Text(
                          'Volver a cuidadores',
                          style: GoogleFonts.poppins(
                            fontSize: 14.4,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            Container(
                              height: 260,
                              width: double.infinity,
                              color: const Color(0xFFF3F4F6),
                              padding: isFallbackAvatar
                                  ? const EdgeInsets.all(20)
                                  : EdgeInsets.zero,
                              child: caregiver.avatarUrl.isEmpty
                                  ? Image.asset(
                                      'assets/images/user1.png',
                                      fit: BoxFit.contain,
                                    )
                                  : Image.network(
                                      caregiver.avatarUrl,
                                      fit: isFallbackAvatar
                                          ? BoxFit.contain
                                          : BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        'assets/images/user1.png',
                                        fit: isFallbackAvatar
                                            ? BoxFit.contain
                                            : BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(26),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    caregiver.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@$username · ${caregiver.email}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _chip(
                                        text: '🎓 $specialty',
                                        background: const Color(0xFFE0F2FE),
                                        color: const Color(0xFF0369A1),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      if (age > 0)
                                        _chip(
                                          text: '🎂 $age años',
                                          background: const Color(0xFFFEF3C7),
                                          color: const Color(0xFF92400E),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      if (caregiver.city.isNotEmpty)
                                        _chip(
                                          text: '📍 ${caregiver.city}',
                                          background: const Color(0xFFF3F4F6),
                                          color: const Color(0xFF374151),
                                          fontWeight: FontWeight.w600,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _infoBlock(
                                    label: 'Experiencia',
                                    child: Text(
                                      caregiver.bio.isNotEmpty ? caregiver.bio : 'Este cuidador aún no ha agregado su experiencia.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        height: 1.6,
                                        color: const Color(0xFF374151),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _infoBlock(
                                          label: '📞 Teléfono',
                                          child: Text(
                                            caregiver.phone.isNotEmpty
                                                ? caregiver.phone
                                                : 'No especificado',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _infoBlock(
                                          label: '🆔 Cédula',
                                          child: Text(
                                            caregiver.cedula.isNotEmpty
                                                ? caregiver.cedula
                                                : 'No especificado',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1F2937),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _gradientButton(
                                          text: 'Contactar',
                                          onTap: () =>
                                              _contactCaregiver(context),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _ghostButton(
                                        text: 'Volver',
                                        onTap: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFECFDF5),
                                          Color(0xFFD1FAE5),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFA7F3D0),
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Agendar visita gratis',
                                          style: GoogleFonts.poppins(
                                            fontSize: 17.6,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF065F46),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Mira el calendario disponible y elige el horario que te quede más fácil.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.08,
                                            color: const Color(0xFF047857),
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _greenButton(
                                          text: '📅 Ver calendario',
                                          onTap: () =>
                                              _openBookingModal(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String text,
    required Color background,
    required Color color,
    required FontWeight fontWeight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.6,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }

  Widget _infoBlock({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.6,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _gradientButton({required String text, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ghostButton({required String text, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }

  Widget _greenButton({required String text, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF059669),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14.08,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
