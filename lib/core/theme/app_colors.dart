import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette - CuidArte Sky Blue
  static const Color primary = Color(0xFF27BEF5);
  static const Color primaryLight = Color(0xFF6DD5FA);
  static const Color primaryDark = Color(0xFF1BA0D1);
  static const Color primaryContainer = Color(0xFFE0F2FE);

  // Secondary & Accents
  static const Color accent = Color(0xFFFF6B9D);
  static const Color caregiver = Color(0xFFFF9800);
  static const Color caregiverLight = Color(0xFFFFB74D);
  static const Color secondary = Color(0xFF10B981); // Emerald / Success
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryContainer = Color(0xFFDCFCE7);

  // Background & Surfaces
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color darkFooter = Color(0xFF181A1B);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status & Alerts
  static const Color pending = Color(0xFFF59E0B); // Amber
  static const Color pendingContainer = Color(0xFFFEF3C7);
  static const Color verified = Color(0xFF10B981); // Green
  static const Color verifiedContainer = Color(0xFFDCFCE7);
  static const Color rejected = Color(0xFFEF4444); // Red
  static const Color rejectedContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoContainer = Color(0xFFE0F2FE);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA), Color(0xFF27BEF5)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: const Color(0xFF27BEF5).withOpacity(0.30),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
