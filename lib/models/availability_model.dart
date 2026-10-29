class VisitSlot {
  final String start;
  final String end;
  final String label;

  const VisitSlot({
    required this.start,
    required this.end,
    required this.label,
  });

  factory VisitSlot.fromJson(Map<String, dynamic> json) {
    return VisitSlot(
      start: (json['start'] ?? '').toString(),
      end: (json['end'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }
}

class AvailabilityModel {
  final int caregiverId;
  final List<DateTime> dates;
  final DateTime? selectedDate;
  final List<VisitSlot> slots;

  const AvailabilityModel({
    required this.caregiverId,
    required this.dates,
    required this.selectedDate,
    required this.slots,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    final datesRaw = json['dates'];
    final dates = <DateTime>[];
    if (datesRaw is List) {
      for (final value in datesRaw) {
        final parsed = DateTime.tryParse(value.toString());
        if (parsed != null) {
          dates.add(parsed);
        }
      }
    }

    final slotsRaw = json['slots'];
    final slots = <VisitSlot>[];
    if (slotsRaw is List) {
      for (final value in slotsRaw) {
        if (value is Map) {
          slots.add(VisitSlot.fromJson(Map<String, dynamic>.from(value)));
        }
      }
    }

    return AvailabilityModel(
      caregiverId: (json['caregiver_id'] as num?)?.toInt() ?? 0,
      dates: dates,
      selectedDate: DateTime.tryParse(
        (json['selected_date'] ?? '').toString(),
      ),
      slots: slots,
    );
  }

  bool get hasSlots => slots.isNotEmpty;
}
