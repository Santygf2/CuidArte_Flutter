class CaregiverModel {
  final String id;
  final String name;
  final String username;
  final int? age;
  final String email;
  final String phone;
  final String city;
  final String address;
  final String cedula;
  final int experienceYears;
  final double rating;
  final int reviewCount;
  final List<String> specialties;
  final bool isVerified;
  final String bio;
  final double hourlyRate;
  final String avatarUrl;
  final List<String> certifications;
  final bool isAvailable;

  CaregiverModel({
    required this.id,
    required this.name,
    this.username = '',
    this.age,
    required this.email,
    required this.phone,
    required this.city,
    required this.address,
    required this.cedula,
    required this.experienceYears,
    required this.rating,
    required this.reviewCount,
    required this.specialties,
    this.isVerified = true,
    required this.bio,
    required this.hourlyRate,
    required this.avatarUrl,
    required this.certifications,
    this.isAvailable = true,
  });

  factory CaregiverModel.fromJson(Map<String, dynamic> json) {
    final specialtiesRaw = json['specialties'];
    final specialties = specialtiesRaw is List
        ? specialtiesRaw.map((item) => item.toString()).toList()
        : <String>[];
    final certificationsRaw = json['certifications'];
    final certifications = certificationsRaw is List
        ? certificationsRaw.map((item) => item.toString()).toList()
        : <String>[];

    return CaregiverModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      age: (json['age'] as num?)?.toInt(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      cedula: (json['cedula'] ?? '').toString(),
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      specialties: specialties,
      isVerified: json['is_verified'] == true,
      bio: (json['bio'] ?? '').toString(),
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0,
      avatarUrl: (json['avatar_url'] ?? '').toString(),
      certifications: certifications,
      isAvailable: json['is_available'] == true,
    );
  }

  bool get hasReviews => reviewCount > 0;

  CaregiverModel copyWith({
    String? id,
    String? name,
    String? username,
    int? age,
    String? email,
    String? phone,
    String? city,
    String? address,
    String? cedula,
    int? experienceYears,
    double? rating,
    int? reviewCount,
    List<String>? specialties,
    bool? isVerified,
    String? bio,
    double? hourlyRate,
    String? avatarUrl,
    List<String>? certifications,
    bool? isAvailable,
  }) {
    return CaregiverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      age: age ?? this.age,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      cedula: cedula ?? this.cedula,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      specialties: specialties ?? this.specialties,
      isVerified: isVerified ?? this.isVerified,
      bio: bio ?? this.bio,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      certifications: certifications ?? this.certifications,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
