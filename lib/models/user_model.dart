import 'user_role.dart';
import '../core/network/api_client.dart';

class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String address;
  final UserRole role;
  final DateTime? dateJoined;
  final int completitud;
  final String? tutorName;
  final String? elderlyCondition;
  final String? avatarUrl;
  final String? cedula;
  final int? experienceYears;
  final String? specialty;
  final String? experience;
  final String? birthDate;

  UserModel({
    required this.id,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.address,
    required this.role,
    this.dateJoined,
    this.completitud = 0,
    this.tutorName,
    this.elderlyCondition,
    this.avatarUrl,
    this.cedula,
    this.experienceYears,
    this.specialty,
    this.experience,
    this.birthDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final perfilRaw = json['perfil'];
    final perfil = perfilRaw is Map
        ? Map<String, dynamic>.from(perfilRaw)
        : const <String, dynamic>{};

    final role = switch (json['role']?.toString()) {
      'cuidador' => UserRole.caregiver,
      'admin' => UserRole.admin,
      _ => UserRole.client,
    };

    final firstName = (perfil['nombre'] ?? json['first_name'] ?? '')
        .toString()
        .trim();
    final lastName = (perfil['apellido'] ?? json['last_name'] ?? '')
        .toString()
        .trim();
    final fullName = (json['full_name'] ?? '$firstName $lastName')
        .toString()
        .trim();
    final email = (json['email'] ?? perfil['correo'] ?? '').toString();
    final city = (perfil['ciudad'] ?? '').toString().trim();
    final address = (perfil['direccion'] ?? '').toString().trim();

    final avatarRaw = perfil['foto_url'];
    final avatarUrl = avatarRaw is String && avatarRaw.trim().isNotEmpty
        ? ApiClient.resolveUrl(avatarRaw)
        : null;

    final specialtyRaw =
        perfil['especialidades_display'] ?? perfil['especialidades'];
    final specialty =
        specialtyRaw is String && specialtyRaw.trim().isNotEmpty
            ? specialtyRaw
            : null;

    final cedulaRaw = perfil['cedula'];
    final cedula =
        cedulaRaw is String && cedulaRaw.trim().isNotEmpty ? cedulaRaw : null;

    final experienceRaw = perfil['experiencia'];
    final experience =
        experienceRaw is String && experienceRaw.trim().isNotEmpty
            ? experienceRaw
            : null;

    final birthRaw = perfil['fecha_nacimiento'];
    final birthDate =
        birthRaw is String && birthRaw.trim().isNotEmpty ? birthRaw : null;

    return UserModel(
      id: (json['id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      firstName: (json['first_name'] ?? firstName).toString(),
      lastName: (json['last_name'] ?? lastName).toString(),
      name: fullName.isEmpty ? email : fullName,
      email: email,
      phone: (perfil['telefono'] ?? '').toString(),
      city: city.isNotEmpty ? city : address,
      address: address,
      role: role,
      dateJoined: DateTime.tryParse((json['date_joined'] ?? '').toString()),
      completitud: (json['completitud'] as num?)?.toInt() ?? 0,
      avatarUrl: avatarUrl,
      cedula: cedula,
      specialty: specialty,
      experience: experience,
      birthDate: birthDate,
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? phone,
    String? city,
    String? address,
    UserRole? role,
    DateTime? dateJoined,
    int? completitud,
    String? tutorName,
    String? elderlyCondition,
    String? avatarUrl,
    String? cedula,
    int? experienceYears,
    String? specialty,
    String? experience,
    String? birthDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      role: role ?? this.role,
      dateJoined: dateJoined ?? this.dateJoined,
      completitud: completitud ?? this.completitud,
      tutorName: tutorName ?? this.tutorName,
      elderlyCondition: elderlyCondition ?? this.elderlyCondition,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      cedula: cedula ?? this.cedula,
      experienceYears: experienceYears ?? this.experienceYears,
      specialty: specialty ?? this.specialty,
      experience: experience ?? this.experience,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
