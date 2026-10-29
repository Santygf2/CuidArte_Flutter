class WorkshopModel {
  final String id;
  final String workshopId;
  final String title;
  final String description;
  final String modality;
  final DateTime date;
  final String time;
  final int availableSlots;
  final int totalSlots;
  final String instructor;
  final String instructorRole;
  final String imageUrl;
  final String locationOrLink;
  final double price;
  final bool isEnrolled;
  final String? enrollmentId;

  WorkshopModel({
    required this.id,
    this.workshopId = '',
    required this.title,
    required this.description,
    required this.modality,
    required this.date,
    required this.time,
    required this.availableSlots,
    required this.totalSlots,
    required this.instructor,
    required this.instructorRole,
    required this.imageUrl,
    required this.locationOrLink,
    this.price = 0.0,
    this.isEnrolled = false,
    this.enrollmentId,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    return WorkshopModel(
      id: (json['id'] ?? '').toString(),
      workshopId: (json['workshop_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      modality: (json['modality'] ?? 'Presencial').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ??
          DateTime.now(),
      time: (json['time'] ?? '').toString(),
      availableSlots: (json['available_slots'] as num?)?.toInt() ?? 0,
      totalSlots: (json['total_slots'] as num?)?.toInt() ?? 0,
      instructor: (json['instructor'] ?? 'Equipo CuidArte').toString(),
      instructorRole:
          (json['instructor_role'] ?? 'Bienestar y salud').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      locationOrLink: (json['location_or_link'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isEnrolled: json['is_enrolled'] == true,
      enrollmentId: json['enrollment_id']?.toString(),
    );
  }

  WorkshopModel copyWith({
    String? id,
    String? workshopId,
    String? title,
    String? description,
    String? modality,
    DateTime? date,
    String? time,
    int? availableSlots,
    int? totalSlots,
    String? instructor,
    String? instructorRole,
    String? imageUrl,
    String? locationOrLink,
    double? price,
    bool? isEnrolled,
    String? enrollmentId,
  }) {
    return WorkshopModel(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      title: title ?? this.title,
      description: description ?? this.description,
      modality: modality ?? this.modality,
      date: date ?? this.date,
      time: time ?? this.time,
      availableSlots: availableSlots ?? this.availableSlots,
      totalSlots: totalSlots ?? this.totalSlots,
      instructor: instructor ?? this.instructor,
      instructorRole: instructorRole ?? this.instructorRole,
      imageUrl: imageUrl ?? this.imageUrl,
      locationOrLink: locationOrLink ?? this.locationOrLink,
      price: price ?? this.price,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      enrollmentId: enrollmentId ?? this.enrollmentId,
    );
  }
}
