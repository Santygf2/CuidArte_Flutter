import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuidarte_app/models/workshop_model.dart';
import 'package:cuidarte_app/core/network/api_client.dart';
import 'package:cuidarte_app/core/theme/app_colors.dart';
import 'package:cuidarte_app/core/utils/formatters.dart';
import 'package:cuidarte_app/providers/client_dashboard_provider.dart';
import 'package:cuidarte_app/providers/workshop_provider.dart';
import 'package:cuidarte_app/presentation/widgets/custom_button.dart';

class WorkshopDetailScreen extends StatelessWidget {
  final WorkshopModel workshop;

  const WorkshopDetailScreen({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    final workshopProv = context.watch<WorkshopProvider>();
    final currentWorkshop = workshopProv.workshops.firstWhere(
      (w) => w.id == workshop.id,
      orElse: () => workshop,
    );

    final isVirtual = currentWorkshop.modality.toLowerCase() == 'virtual';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalle del Taller'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enlace del taller copiado.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    currentWorkshop.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.primaryContainer),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isVirtual ? AppColors.primary : AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentWorkshop.modality,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentWorkshop.price == 0 ? 'GRATUITO' : Formatters.formatCurrency(currentWorkshop.price),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentWorkshop.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date, Time & Location
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              Formatters.formatDate(currentWorkshop.date),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              currentWorkshop.time,
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.divider),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              isVirtual ? Icons.link_rounded : Icons.location_on_outlined,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                currentWorkshop.locationOrLink,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Facilitador del Taller',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(Icons.psychology_rounded, color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentWorkshop.instructor,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currentWorkshop.instructorRole,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Descripción del Taller',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentWorkshop.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: currentWorkshop.isEnrolled
                          ? AppColors.secondaryContainer
                          : AppColors.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          currentWorkshop.isEnrolled
                              ? Icons.verified_rounded
                              : Icons.groups_rounded,
                          color: currentWorkshop.isEnrolled
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currentWorkshop.isEnrolled
                                ? '¡Ya estás inscrito a este taller! Te enviaremos el recordatorio 2 horas antes.'
                                : 'Cupos disponibles: ${currentWorkshop.availableSlots} de ${currentWorkshop.totalSlots}. Reserva tu lugar.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: currentWorkshop.isEnrolled
                                  ? AppColors.secondaryDark
                                  : AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: currentWorkshop.isEnrolled ? 'Cancelar mi Inscripción' : 'Inscribirme al Taller',
                    icon: currentWorkshop.isEnrolled ? Icons.cancel_outlined : Icons.check_circle_outline,
                    customColor: currentWorkshop.isEnrolled ? AppColors.rejected : AppColors.primary,
                    onPressed: () async {
                      try {
                        final updated = await workshopProv
                            .toggleEnrollment(currentWorkshop.id);
                        if (!context.mounted) return;
                        context.read<ClientDashboardProvider>().load();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: updated.isEnrolled
                                ? AppColors.secondary
                                : AppColors.rejected,
                            content: Text(updated.isEnrolled
                                ? '¡Te has inscrito exitosamente al taller!'
                                : 'Inscripción cancelada.'),
                          ),
                        );
                      } on ApiException catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.rejected,
                            content: Text(error.message),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
