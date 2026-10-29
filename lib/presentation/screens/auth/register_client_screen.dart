import 'package:flutter/material.dart';
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
import '../navigation/main_navigation_screen.dart';
import 'login_screen.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    _birthDateController.dispose();
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
    final lastAllowed = DateTime(now.year - 18, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 60),
      firstDate: DateTime(1900),
      lastDate: lastAllowed,
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
      await context.read<AuthProvider>().registerClientAccount(
            name: _nameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            birthDate: _birthDate!,
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
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
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
      title: 'Registro de Cliente',
      subtitle: 'Encuentra al cuidador ideal para ti',
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
              label: 'Fecha de nacimiento *',
              hint: 'dd/mm/aaaa',
              helper: 'Debes ser mayor de 18 años.',
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
}
