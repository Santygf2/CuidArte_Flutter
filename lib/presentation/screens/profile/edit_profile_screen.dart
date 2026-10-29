import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_role.dart';
import '../../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _especialidades = [
    'Geriatría',
    'Enfermería',
    'Psicología / Salud Emocional',
    'Fisioterapia / Terapia Física',
    'Nutrición',
    'Cardiología',
    'Oncología',
    'Pediatría',
    'Demencia / Alzheimer',
    'Discapacidad y Movilidad',
    'Cuidados Paliativos',
    'Terapia Ocupacional',
    'Acompañamiento Terapéutico',
  ];

  static const _ciudades = [
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Bucaramanga',
    'Pereira',
    'Santa Marta',
    'Cúcuta',
    'Ibagué',
    'Manizales',
    'Villavicencio',
    'Pasto',
    'Montería',
    'Valledupar',
    'Neiva',
    'Armenia',
    'Sincelejo',
  ];

  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _cedula = TextEditingController();
  final _experience = TextEditingController();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  String? _city;
  String? _specialty;
  DateTime? _birthDate;
  bool _saving = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _name.text = user.firstName.isNotEmpty
          ? user.firstName
          : user.name.split(' ').first;
      _lastName.text = user.lastName.isNotEmpty
          ? user.lastName
          : user.name.split(' ').skip(1).join(' ');
      _email.text = user.email;
      _phone.text = user.phone;
      if (user.city.isNotEmpty) {
        _city = _ciudades.contains(user.city) ? user.city : user.city;
      }
      _birthDate = DateTime.tryParse(user.birthDate ?? '');
      if (user.role == UserRole.caregiver) {
        _cedula.text = user.cedula ?? '';
        _experience.text = user.experience ?? '';
        _specialty = user.specialty;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _cedula.dispose();
    _experience.dispose();
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 3) return 'Mínimo 3 letras';
    if (RegExp(r'[0-9]').hasMatch(text)) return 'No puede contener números';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').trim();
    if (phone.isNotEmpty && phone.length != 10) {
      return 'El teléfono debe tener 10 dígitos';
    }
    return null;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 40),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final career = context.read<AuthProvider>().currentRole ==
          UserRole.caregiver;
      await context.read<AuthProvider>().updateProfile(
            name: _name.text,
            lastName: _lastName.text,
            email: _email.text,
            phone: _phone.text,
            city: _city ?? '',
            birthDate: _birthDate,
            cedula: career ? _cedula.text : null,
            experiencia: career ? _experience.text : null,
            especialidades: career ? _specialty : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text('Cambios guardados correctamente.'),
        ),
      );
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rejected,
          content: Text(error.message),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;
    setState(() => _changingPassword = true);
    try {
      await context.read<AuthProvider>().changePassword(
            oldPassword: _oldPassword.text,
            newPassword: _newPassword.text,
            confirmPassword: _confirmPassword.text,
          );
      if (!mounted) return;
      _oldPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text('Contraseña actualizada correctamente.'),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rejected,
          content: Text(
            error.fieldError('old_password') ??
                error.fieldError('new_password') ??
                error.message,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 60,
                  ),
                  child: Column(
                    children: [
                      _formCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _field(
                                label: 'Nombre *',
                                controller: _name,
                                validator: _validateName,
                              ),
                              _field(
                                label: 'Apellido *',
                                controller: _lastName,
                                validator: _validateName,
                              ),
                              _field(
                                label: 'Correo *',
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),
                              _field(
                                label: 'Teléfono',
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                                validator: _validatePhone,
                              ),
                              _cityField(),
                              _birthDateField(),
                              if (user?.role == UserRole.caregiver) ...[
                                _specialtyField(),
                                _field(
                                  label: 'Cédula',
                                  controller: _cedula,
                                  hint: 'Número de documento',
                                ),
                                _field(
                                  label: 'Experiencia y Descripción *',
                                  controller: _experience,
                                  hint: 'Cuéntale a los clientes sobre tu experiencia',
                                  maxLines: 4,
                                  validator: (value) {
                                    final text = (value ?? '').trim();
                                    if (text.length < 5 || text.length > 200) {
                                      return 'Entre 5 y 200 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              if (user?.avatarUrl != null &&
                                  user!.avatarUrl!.isNotEmpty) ...[
                                Text(
                                  'Foto de perfil',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.4,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D2D2D),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'La foto se actualiza desde la versión web.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Row(
                                children: [
                                  _gradientButton(
                                    text: 'Guardar Cambios',
                                    loading: _saving,
                                    onTap: _saving ? null : _save,
                                  ),
                                  const SizedBox(width: 12),
                                  _secondaryButton(
                                    text: 'Cancelar',
                                    onTap: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _formCard(
                        child: Form(
                          key: _passwordFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cambiar contraseña',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.8,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mínimo 8 caracteres. No puede ser solo números ni una contraseña común.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.08,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _field(
                                label: 'Contraseña actual',
                                controller: _oldPassword,
                                obscure: true,
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Requerido'
                                        : null,
                              ),
                              _field(
                                label: 'Nueva contraseña',
                                controller: _newPassword,
                                obscure: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requerido';
                                  }
                                  if (value.length < 8) {
                                    return 'Mínimo 8 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              _field(
                                label: 'Confirmar nueva contraseña',
                                controller: _confirmPassword,
                                obscure: true,
                                validator: (value) {
                                  if (value != _newPassword.text) {
                                    return 'Las contraseñas no son iguales';
                                  }
                                  return null;
                                },
                              ),
                              _gradientButton(
                                text: 'Actualizar contraseña',
                                loading: _changingPassword,
                                onTap: _changingPassword
                                    ? null
                                    : _changePassword,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = (width * 0.026).clamp(24.0, 33.6);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Text(
                  'Editar Información Personal',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Actualiza tus datos personales',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 17.6,
                    color: Colors.white.withOpacity(0.94),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLines: obscure ? 1 : maxLines,
            validator: validator,
            style: GoogleFonts.poppins(fontSize: 15.2),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 15.2,
                color: const Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF27BEF5),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cityField() {
    final options = <String>[..._ciudades];
    if (_city != null && !options.contains(_city)) {
      options.add(_city!);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ciudad',
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _city,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF27BEF5),
                  width: 2,
                ),
              ),
            ),
            hint: Text(
              'Selecciona una ciudad',
              style: GoogleFonts.poppins(
                fontSize: 15.2,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: 15.2,
              color: const Color(0xFF2D2D2D),
            ),
            items: options
                .map(
                  (city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _city = value),
          ),
        ],
      ),
    );
  }

  Widget _specialtyField() {
    final options = <String>[..._especialidades];
    if (_specialty != null && _specialty!.isNotEmpty && !options.contains(_specialty)) {
      options.add(_specialty!);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Especialidad *',
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _specialty,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF27BEF5),
                  width: 2,
                ),
              ),
            ),
            hint: Text(
              'Selecciona una especialidad',
              style: GoogleFonts.poppins(
                fontSize: 15.2,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: 15.2,
              color: const Color(0xFF2D2D2D),
            ),
            items: options
                .map(
                  (specialty) => DropdownMenuItem(
                    value: specialty,
                    child: Text(specialty),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _specialty = value),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Requerido' : null,
          ),
        ],
      ),
    );
  }

  Widget _birthDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fecha de nacimiento',
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickBirthDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
              ),
              child: Text(
                _birthDate != null
                    ? DateFormat('dd/MM/yyyy', 'es').format(_birthDate!)
                    : 'Selecciona una fecha',
                style: GoogleFonts.poppins(
                  fontSize: 15.2,
                  color: _birthDate != null
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({
    required String text,
    required bool loading,
    VoidCallback? onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27BEF5).withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 14.72,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27BEF5), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14.72,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF27BEF5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
