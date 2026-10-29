import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/auth/auth_buttons.dart';
import '../../widgets/auth/auth_terms_checkbox.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/registration_layout.dart';
import '../navigation/caregiver_dashboard_screen.dart';
import 'login_screen.dart';

class RegisterCaregiverScreen extends StatefulWidget {
  const RegisterCaregiverScreen({super.key});

  @override
  State<RegisterCaregiverScreen> createState() => _RegisterCaregiverScreenState();
}

class _RegisterCaregiverScreenState extends State<RegisterCaregiverScreen> {
  static const List<String> _specialties = [
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

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _experienceController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _specialty;
  DateTime? _birthDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  String? _submitError;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _experienceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 3) return 'Mínimo 3 letras, sin números';
    if (RegExp(r'[0-9]').hasMatch(text)) return 'Mínimo 3 letras, sin números';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingresa tu correo electrónico';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.length != 10) return 'Ingresa los 10 dígitos';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(password);
    if (password.length < 8 || !hasUppercase || !hasNumber || !hasSpecial) {
      return 'Debe tener al menos un número, una mayúscula y un carácter especial.';
    }
    return null;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 40),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (selected != null) {
      setState(() {
        _birthDate = selected;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(selected);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _submitError = null;
    });

    try {
      await context.read<AuthProvider>().registerCaregiverAccount(
            name: _nameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            birthDate: _birthDate!,
            specialty: _specialty!,
            experience: _experienceController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            acceptedTerms: _acceptedTerms,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text('¡Cuenta creada! Bienvenido a CuidArte.'),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CaregiverDashboardScreen()),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _submitError = error.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationLayout(
      title: 'Registro de Cuidador',
      subtitle: 'Comienza tu carrera en cuidados',
      onLoginTap: _goToLogin,
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              label: 'Nombre *',
              hint: 'Mínimo 3 letras, sin números',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Apellido *',
              hint: 'Mínimo 3 letras, sin números',
              controller: _lastNameController,
              textInputAction: TextInputAction.next,
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Correo electrónico *',
              hint: 'correo@ejemplo.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Teléfono *',
              hint: '10 dígitos',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Fecha de nacimiento *',
              hint: 'dd/mm/aaaa',
              helper: 'La edad se calcula automáticamente.',
              controller: _birthDateController,
              readOnly: true,
              onTap: _pickBirthDate,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                onPressed: _pickBirthDate,
              ),
              validator: (_) => _birthDate == null ? 'Selecciona tu fecha de nacimiento' : null,
            ),
            const SizedBox(height: 16),
            _buildSpecialtyField(),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Experiencia *',
              hint: '5 a 200 caracteres',
              helper: 'Mínimo 5, máximo 200 caracteres.',
              controller: _experienceController,
              maxLines: 3,
              maxLength: 200,
              textInputAction: TextInputAction.newline,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.length < 5 || text.length > 200) {
                  return 'Mínimo 5, máximo 200 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Contraseña *',
              hint: '••••••••',
              helper: 'Debe tener al menos un número, una mayúscula y un carácter especial.',
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF9CA3AF),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Confirmar Contraseña *',
              hint: '••••••••',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF9CA3AF),
                ),
                onPressed: () =>
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Confirma tu contraseña';
                if (value != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthTermsCheckbox(
              onChanged: (value) => _acceptedTerms = value,
            ),
            if (_submitError != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.rejected.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.rejected.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _submitError!,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: AppColors.rejected,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            AuthGradientButton(
              text: 'Crear cuenta',
              isLoading: _isLoading,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Todos los campos con * son obligatorios',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especialidades *',
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _specialty,
          isExpanded: true,
          hint: Text(
            'Selecciona una especialidad',
            style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF9CA3AF)),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
          style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.rejected, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.rejected, width: 2),
            ),
            errorStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.rejected),
          ),
          items: _specialties
              .map(
                (specialty) => DropdownMenuItem<String>(
                  value: specialty,
                  child: Text(
                    specialty,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 15),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _specialty = value),
          validator: (value) =>
              value == null || value.isEmpty ? 'Selecciona una especialidad' : null,
        ),
      ],
    );
  }
}
