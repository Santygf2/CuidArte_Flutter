enum UserRole {
  client,
  caregiver,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'Familiar / Adulto Mayor';
      case UserRole.caregiver:
        return 'Cuidador Profesional';
      case UserRole.admin:
        return 'Administrador';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.client:
        return 'Cliente';
      case UserRole.caregiver:
        return 'Cuidador';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
