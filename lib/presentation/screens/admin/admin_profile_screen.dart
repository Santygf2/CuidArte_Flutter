import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/admin_api.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/error_retry.dart';
import 'admin_widgets.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key, this.api});

  final AdminApi? api;

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  late final AdminApi _api;
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _correo = TextEditingController();
  final _usuario = TextEditingController();
  Map<String, dynamic>? _profile;
  DateTime? _fechaNacimiento;
  bool _loading = true;
  bool _saving = false;
  bool _editing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AdminApi();
    _load();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _correo.dispose();
    _usuario.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _perfil {
    final raw = _profile?['perfil'];
    return raw is Map
        ? Map<String, dynamic>.from(raw)
        : const <String, dynamic>{};
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.profile();
      if (!mounted) return;
      setState(() {
        _profile = data;
        _loading = false;
        _fillControllers();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el perfil. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  void _fillControllers() {
    _nombre.text = (_profile?['first_name'] ?? _perfil['nombre'] ?? '')
        .toString();
    _apellido.text = (_profile?['last_name'] ?? _perfil['apellido'] ?? '')
        .toString();
    _correo.text = (_profile?['email'] ?? '').toString();
    _usuario.text = (_profile?['username'] ?? '').toString();
    final fecha = _perfil['fecha_nacimiento']?.toString();
    _fechaNacimiento = fecha == null || fecha.isEmpty
        ? null
        : DateTime.tryParse(fecha);
  }

  Future<void> _pickBirthDate() async {
    final current = _fechaNacimiento ?? DateTime(1990, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Fecha de nacimiento',
    );
    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final body = <String, dynamic>{
        'nombre': _nombre.text.trim(),
        'apellido': _apellido.text.trim(),
        'correo': _correo.text.trim(),
        'usuario': _usuario.text.trim(),
      };
      if (_fechaNacimiento != null) {
        body['fecha_nacimiento'] = DateFormat('yyyy-MM-dd')
            .format(_fechaNacimiento!);
      }
      await _api.updateProfile(body);
      if (mounted) {
        await context.read<AuthProvider>().reloadProfile();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente.'),
          backgroundColor: AppColors.secondaryDark,
        ),
      );
      setState(() => _editing = false);
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = 'No se pudo actualizar el perfil. Intenta de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Perfil de Administrador',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AdminPageHeader(
              title: 'Perfil de Administrador',
              subtitle: 'Información de tu cuenta administrativa',
            ),
            AdminBody(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _error != null && _profile == null
                      ? ErrorRetry(message: _error!, onRetry: _load)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_error != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.rejectedContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _error!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    color: const Color(0xFF991B1B),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            _buildSummary(),
                            const SizedBox(height: 18),
                            _editing ? _buildEditForm() : _buildInfo(),
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

  Widget _buildSummary() {
    final username = (_profile?['username'] ?? '').toString();
    final fullName = (_profile?['full_name'] ?? username).toString();
    final email = (_profile?['email'] ?? '').toString();
    final joined = DateTime.tryParse(
      (_profile?['date_joined'] ?? '').toString(),
    );
    final initial = username.isEmpty
        ? 'A'
        : username.substring(0, 1).toUpperCase();
    return AdminCard(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        runSpacing: 14,
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.brandGradient,
            ),
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '@$username · ${email.isEmpty ? 'Sin correo' : email}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    const AdminBadge(
                      text: 'ADMINISTRADOR',
                      foreground: Color(0xFF0369A1),
                      background: Color(0xFFE0F2FE),
                    ),
                    if (joined != null)
                      AdminBadge(
                        text:
                            'Miembro desde ${DateFormat('dd/MM/yyyy').format(joined)}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    final fecha = _perfil['fecha_nacimiento']?.toString();
    final edad = _perfil['edad'];
    final joined = DateTime.tryParse(
      (_profile?['date_joined'] ?? '').toString(),
    );
    final fullName = '${_nombre.text} ${_apellido.text}'.trim();
    final birthText = fecha == null || fecha.isEmpty
        ? '—'
        : '${DateFormat('dd/MM/yyyy').format(DateTime.parse(fecha))}'
              '${edad == null ? '' : ' ($edad años)'}';
    return AdminCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Información de la cuenta',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow('Nombre completo', fullName.isEmpty ? '—' : fullName),
          _infoRow('Usuario', _usuario.text),
          _infoRow(
            'Correo electrónico',
            _correo.text.isEmpty ? '—' : _correo.text,
          ),
          _infoRowWidget(
            'Rol',
            const AdminBadge(
              text: 'ADMINISTRADOR',
              foreground: Color(0xFF0369A1),
              background: Color(0xFFE0F2FE),
            ),
          ),
          _infoRow('Fecha de nacimiento', birthText),
          _infoRow(
            'Miembro desde',
            joined == null
                ? '—'
                : DateFormat('dd/MM/yyyy HH:mm').format(joined),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _fillControllers();
              setState(() {
                _editing = true;
                _error = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return AdminCard(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editar perfil',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Actualiza la información de tu cuenta administrativa',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            _field('Nombre', _nombre),
            const SizedBox(height: 14),
            _field('Apellido', _apellido),
            const SizedBox(height: 14),
            _field(
              'Correo electrónico',
              _correo,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return 'Este campo es obligatorio';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _field('Usuario', _usuario),
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha de nacimiento',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickBirthDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _fechaNacimiento == null
                                ? 'Selecciona una fecha'
                                : DateFormat('dd/MM/yyyy')
                                      .format(_fechaNacimiento!),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _fechaNacimiento == null
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 19,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Guardar cambios',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            TextButton(
              onPressed: _saving
                  ? null
                  : () => setState(() {
                      _editing = false;
                      _error = null;
                      _fillControllers();
                    }),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator:
              validator ??
              (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRowWidget(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            value,
          ],
        ),
      ),
    );
  }
}
