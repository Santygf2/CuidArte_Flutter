import 'package:flutter/material.dart';
import '../../models/workshop_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class WorkshopCard extends StatelessWidget {
  final WorkshopModel workshop;
  final VoidCallback onTap;
  final VoidCallback onToggleEnrollment;

  const WorkshopCard({
    super.key,
    required this.workshop,
    required this.onTap,
    required this.onToggleEnrollment,
  });

  @override
  Widget build(BuildContext context) {
    final isVirtual = workshop.modality.toLowerCase() == 'virtual';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Header with tags
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: Image.network(
                        workshop.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primaryContainer,
                          child: const Icon(Icons.event, size: 40, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  // Modality Tag
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isVirtual ? AppColors.primary : AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVirtual ? Icons.laptop_chromebook_rounded : Icons.location_on_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            workshop.modality,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Price Tag (Gratis / Valorado)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        workshop.price == 0 ? 'GRATIS' : Formatters.formatCurrency(workshop.price),
                        style: TextStyle(
                          color: workshop.price == 0 ? AppColors.secondaryDark : AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          Formatters.formatDate(workshop.date),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time_rounded, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Text(
                          workshop.time,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      workshop.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Instructor
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(Icons.person, size: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${workshop.instructor} • ${workshop.instructorRole}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 12),
                    // Slots & Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people_outline_rounded, size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              '${workshop.availableSlots} cupos disponibles',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: workshop.availableSlots <= 5
                                    ? AppColors.pending
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: onToggleEnrollment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: workshop.isEnrolled
                                ? AppColors.secondaryContainer
                                : AppColors.primary,
                            foregroundColor: workshop.isEnrolled
                                ? AppColors.secondaryDark
                                : Colors.white,
                            minimumSize: const Size(125, 42),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                workshop.isEnrolled ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                size: 17,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                workshop.isEnrolled ? 'Inscrito' : 'Inscribirme',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
