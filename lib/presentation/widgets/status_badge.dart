import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    final normalized = status.toLowerCase();

    if (normalized.contains('aceptad') ||
        normalized.contains('verificad') ||
        normalized.contains('completad') ||
        normalized.contains('aprobado')) {
      bg = AppColors.verifiedContainer;
      fg = AppColors.verified;
      icon = Icons.check_circle_outline_rounded;
    } else if (normalized.contains('pendient')) {
      bg = AppColors.pendingContainer;
      fg = AppColors.pending;
      icon = Icons.schedule_rounded;
    } else {
      bg = AppColors.rejectedContainer;
      fg = AppColors.rejected;
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: fg),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
