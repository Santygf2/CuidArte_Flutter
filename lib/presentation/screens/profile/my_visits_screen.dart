import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/visit_model.dart';
import '../../../providers/visit_provider.dart';
import '../../widgets/error_retry.dart';
import '../navigation/main_navigation_screen.dart';

class MyVisitsScreen extends StatefulWidget {
  const MyVisitsScreen({super.key});

  @override
  State<MyVisitsScreen> createState() => _MyVisitsScreenState();
}

class _MyVisitsScreenState extends State<MyVisitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VisitProvider>().ensureLoaded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VisitProvider>();
    final visits = provider.visits;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: Column(
        children: [
          _buildHero(context),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 36,
                    ),
                    child: _buildContent(provider, visits),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = (width * 0.026).clamp(24.0, 33.6);
    return Container(
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
                  'Mis Visitas',
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
                  'Solicitudes de visita que has enviado a los cuidadores.',
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
    );
  }

  Widget _buildContent(VisitProvider provider, List<VisitModel> visits) {
    if (provider.isLoading && visits.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.errorMessage != null && visits.isEmpty) {
      return ErrorRetry(
        message: provider.errorMessage!,
        onRetry: provider.loadMyVisits,
      );
    }
    if (visits.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children: visits.map((visit) => _visitCard(visit)).toList(),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
          Text(
            'No tienes visitas solicitadas',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Entra al perfil de un cuidador y pulsa 'Agendar visita gratis'.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: const Color(0xFF27BEF5),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MainNavigationScreen(initialIndex: 1),
                  ),
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  'Buscar cuidadores',
                  style: GoogleFonts.poppins(
                    fontSize: 14.4,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitCard(VisitModel visit) {
    final normalized = visit.status.toLowerCase();
    final isPending = normalized.contains('pendiente');
    final isAccepted = normalized.contains('aceptada');
    final borderColor = isPending
        ? const Color(0xFFF59E0B)
        : isAccepted
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);
    final date = DateFormat('dd/MM/yyyy', 'es').format(visit.date);
    final startTime = visit.timeSlot.split(' - ').first;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: borderColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👤 ${visit.caregiverName}',
                      style: GoogleFonts.poppins(
                        fontSize: 16.8,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text: 'Visita el ',
                        children: [
                          TextSpan(
                            text: date,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: ' a las '),
                          TextSpan(
                            text: startTime,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: ' (1 hora)'),
                        ],
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14.4,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    if (visit.message.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Tu mensaje: “${visit.message}”',
                          style: GoogleFonts.poppins(
                            fontSize: 14.08,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                    if (!isPending &&
                        !isAccepted &&
                        visit.rejectionReason.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: 'Motivo del rechazo: ',
                            children: [
                              TextSpan(
                                text: visit.rejectionReason,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14.08,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ] else if (isAccepted) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          '✓ ¡Visita confirmada! El cuidador llegará a tu domicilio a la hora acordada.',
                          style: GoogleFonts.poppins(
                            fontSize: 14.08,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ] else if (isPending) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Esperando respuesta del cuidador...',
                        style: GoogleFonts.poppins(
                          fontSize: 13.6,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _statusBadge(visit.status, isPending, isAccepted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, bool isPending, bool isAccepted) {
    final background = isPending
        ? const Color(0xFFFEF3C7)
        : isAccepted
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEE2E2);
    final color = isPending
        ? const Color(0xFF92400E)
        : isAccepted
            ? const Color(0xFF166534)
            : const Color(0xFF991B1B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 12.8,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
