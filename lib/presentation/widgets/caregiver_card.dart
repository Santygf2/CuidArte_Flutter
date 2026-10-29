import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/caregiver_model.dart';

class CaregiverCard extends StatelessWidget {
  final CaregiverModel caregiver;
  final VoidCallback onTap;

  const CaregiverCard({
    super.key,
    required this.caregiver,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final specialty = caregiver.specialties.isNotEmpty
        ? caregiver.specialties.first
        : 'Cuidador profesional';
    final age = caregiver.age ?? 0;
    final city = _truncate(caregiver.city, 18);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 170,
            child: Container(
              color: const Color(0xFFF3F4F6),
              child: caregiver.avatarUrl.isEmpty
                  ? Image.asset(
                      'assets/images/user1.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 56,
                        color: Color(0xFF9CA3AF),
                      ),
                    )
                  : Image.network(
                      caregiver.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/user1.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 56,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caregiver.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16.8,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _truncate(specialty, 40),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14.08,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (age > 0)
                        _chip(
                          text: '$age años',
                          background: const Color(0xFFFEF3C7),
                          color: const Color(0xFF92400E),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.8,
                        ),
                      if (city.isNotEmpty)
                        _chip(
                          text: '📍 $city',
                          background: const Color(0xFFF3F4F6),
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                          fontSize: 12.48,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Material(
                    color: const Color(0xFF27BEF5),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        alignment: Alignment.center,
                        child: Text(
                          'Ver más',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String text,
    required Color background,
    required Color color,
    required FontWeight fontWeight,
    required double fontSize,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }

  String _truncate(String value, int max) {
    if (value.length <= max) {
      return value;
    }
    return '${value.substring(0, max - 1)}…';
  }
}
