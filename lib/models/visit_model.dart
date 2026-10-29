class VisitModel {
  final String id;
  final String caregiverId;
  final String caregiverName;
  final String caregiverSpecialty;
  final String caregiverAvatar;
  final String caregiverPhone;
  final String clientId;
  final String clientName;
  final String clientAddress;
  final String clientPhone;
  final String clientEmail;
  final int? clientAge;
  final String clientAvatar;
  final String elderlyCondition;
  final DateTime date;
  final String timeSlot;
  final String status;
  final String notes;
  final String message;
  final bool isFreeInitialVisit;
  final String rejectionReason;

  VisitModel({
    required this.id,
    required this.caregiverId,
    required this.caregiverName,
    required this.caregiverSpecialty,
    required this.caregiverAvatar,
    required this.caregiverPhone,
    required this.clientId,
    required this.clientName,
    required this.clientAddress,
    required this.clientPhone,
    this.clientEmail = '',
    this.clientAge,
    this.clientAvatar = '',
    required this.elderlyCondition,
    required this.date,
    required this.timeSlot,
    this.status = 'Pendiente',
    this.notes = '',
    this.message = '',
    this.isFreeInitialVisit = true,
    this.rejectionReason = '',
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    final fecha = DateTime.tryParse((json['date'] ?? '').toString());
    return VisitModel(
      id: (json['id'] ?? '').toString(),
      caregiverId: (json['caregiver_id'] ?? '').toString(),
      caregiverName: (json['caregiver_name'] ?? '').toString(),
      caregiverSpecialty: (json['caregiver_specialty'] ?? '').toString(),
      caregiverAvatar: (json['caregiver_avatar'] ?? '').toString(),
      caregiverPhone: (json['caregiver_phone'] ?? '').toString(),
      clientId: (json['client_id'] ?? '').toString(),
      clientName: (json['client_name'] ?? '').toString(),
      clientAddress: (json['client_address'] ?? '').toString(),
      clientPhone: (json['client_phone'] ?? '').toString(),
      clientEmail: (json['client_email'] ?? '').toString(),
      clientAge: (json['client_age'] as num?)?.toInt(),
      clientAvatar: (json['client_avatar'] ?? '').toString(),
      elderlyCondition:
          (json['elderly_condition'] ?? 'Valoración preventiva').toString(),
      date: fecha ?? DateTime.now(),
      timeSlot: (json['time_slot'] ?? '').toString(),
      status: (json['status_label'] ?? json['status'] ?? 'Pendiente').toString(),
      notes: (json['notes'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      isFreeInitialVisit: json['is_free_initial_visit'] != false,
      rejectionReason: (json['rejection_reason'] ?? '').toString(),
    );
  }

  VisitModel copyWith({
    String? id,
    String? caregiverId,
    String? caregiverName,
    String? caregiverSpecialty,
    String? caregiverAvatar,
    String? caregiverPhone,
    String? clientId,
    String? clientName,
    String? clientAddress,
    String? clientPhone,
    String? clientEmail,
    int? clientAge,
    String? clientAvatar,
    String? elderlyCondition,
    DateTime? date,
    String? timeSlot,
    String? status,
    String? notes,
    String? message,
    bool? isFreeInitialVisit,
    String? rejectionReason,
  }) {
    return VisitModel(
      id: id ?? this.id,
      caregiverId: caregiverId ?? this.caregiverId,
      caregiverName: caregiverName ?? this.caregiverName,
      caregiverSpecialty: caregiverSpecialty ?? this.caregiverSpecialty,
      caregiverAvatar: caregiverAvatar ?? this.caregiverAvatar,
      caregiverPhone: caregiverPhone ?? this.caregiverPhone,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientAddress: clientAddress ?? this.clientAddress,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      clientAge: clientAge ?? this.clientAge,
      clientAvatar: clientAvatar ?? this.clientAvatar,
      elderlyCondition: elderlyCondition ?? this.elderlyCondition,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      message: message ?? this.message,
      isFreeInitialVisit: isFreeInitialVisit ?? this.isFreeInitialVisit,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
