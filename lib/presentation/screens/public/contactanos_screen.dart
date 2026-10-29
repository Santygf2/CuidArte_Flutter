import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/cuidarte_footer.dart';

class ContactanosScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const ContactanosScreen({super.key, this.onNavigateTab});

  @override
  State<ContactanosScreen> createState() => _ContactanosScreenState();
}

class _ContactanosScreenState extends State<ContactanosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _mensajeController = TextEditingController();

  String? _selectedCiudad;
  String? _selectedAsunto;
  bool _isSubmitting = false;

  final List<String> _ciudades = [
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

  final List<String> _asuntos = [
    'Información general',
    'Servicios',
    'Soporte',
    'Otro',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 3) return 'Mínimo 3 letras';
    if (RegExp(r'\d').hasMatch(text)) return 'No puede contener números';
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').trim();
    if (phone.length != 10 || int.tryParse(phone) == null) {
      return 'Debe tener exactamente 10 dígitos';
    }
    return null;
  }

  String _asuntoValue(String asunto) {
    switch (asunto) {
      case 'Información general':
        return 'informacion';
      case 'Servicios':
        return 'servicios';
      case 'Soporte':
        return 'soporte';
      default:
        return 'otro';
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCiudad == null) {
      _showError('Por favor selecciona una ciudad');
      return;
    }
    if (_selectedAsunto == null) {
      _showError('Por favor selecciona un asunto');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final api = ApiClient();
      await api.post(
        '/contact/',
        auth: false,
        body: {
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'correo': _correoController.text.trim(),
          'telefono': _telefonoController.text.trim(),
          'ciudad': _selectedCiudad,
          'asunto': _asuntoValue(_selectedAsunto!),
          'mensaje': _mensajeController.text.trim(),
        },
      );
      if (!mounted) return;
      _nombreController.clear();
      _apellidoController.clear();
      _correoController.clear();
      _telefonoController.clear();
      _mensajeController.clear();
      setState(() {
        _selectedCiudad = null;
        _selectedAsunto = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF065F46),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Gracias por tu mensaje! Nos pondremos en contacto '
                  'contigo pronto.',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) {
        _showError(
          'No se pudo enviar el mensaje. Verifica tu conexión e intenta '
          'de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.rejected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. HERO HEADER (Screenshot 3)
          _buildHeroHeader(isDesktop),

          // 2. MAIN SECTION: INFO + FORM (Screenshots 3 & 4)
          Container(
            color: const Color(0xFFF7F8FC),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48.0 : 20.0,
              vertical: 60.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildInfoCard()),
                          const SizedBox(width: 40),
                          Expanded(flex: 6, child: _buildFormCard()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildInfoCard(),
                          const SizedBox(height: 36),
                          _buildFormCard(),
                        ],
                      ),
              ),
            ),
          ),

          // 3. FOOTER (Screenshot 4)
          CuidArteFooter(onNavigateTab: widget.onNavigateTab),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA), Color(0xFF27BEF5)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: isDesktop ? 70.0 : 45.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              Text(
                'Contáctanos',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 44 : 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Estamos aquí para ayudarte. Si tienes alguna pregunta o necesitas más información sobre nuestros servicios, no dudes en comunicarte con nosotros.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 16 : 14.5,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de contacto',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Encuentra diferentes formas de comunicarte con nosotros',
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 36),

          // Email
          _buildInfoItem(
            icon: Icons.mail_outline_rounded,
            title: 'Email',
            lines: ['cuidartesk@gmail.com'],
          ),

          // Teléfono
          _buildInfoItem(
            icon: Icons.phone_outlined,
            title: 'Teléfono',
            lines: ['+57 310 499 53 42', '+57 302 209 35 10'],
          ),

          // Ubicación
          _buildInfoItem(
            icon: Icons.location_on_outlined,
            title: 'Ubicación',
            lines: ['Medellín, Antioquia', 'Colombia'],
          ),

          // Horario
          _buildInfoItem(
            icon: Icons.access_time_rounded,
            title: 'Horario',
            lines: ['Lunes a Viernes: 8AM – 6PM', 'Sábados: 9AM – 2PM'],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required List<String> lines,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                ...lines.map(
                  (line) => Text(
                    line,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envíanos un mensaje',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completa el formulario y te responderemos pronto',
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 28),

            // Row 1: Nombre + Apellido
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 500;
                if (isNarrow) {
                  return Column(
                    children: [
                      _buildTextField(
                        controller: _nombreController,
                        label: 'Nombre *',
                        hint: 'Tu nombre',
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _apellidoController,
                        label: 'Apellido *',
                        hint: 'Tu apellido',
                        validator: _validateName,
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nombreController,
                        label: 'Nombre *',
                        hint: 'Tu nombre',
                        validator: _validateName,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _apellidoController,
                        label: 'Apellido *',
                        hint: 'Tu apellido',
                        validator: _validateName,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Row 2: Correo + Teléfono
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 500;
                if (isNarrow) {
                  return Column(
                    children: [
                      _buildTextField(
                        controller: _correoController,
                        label: 'Correo *',
                        hint: 'correo@ejemplo.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!v.contains('@')) {
                            return 'Correo no válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _telefonoController,
                        label: 'Teléfono *',
                        hint: '10 dígitos',
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _correoController,
                        label: 'Correo *',
                        hint: 'correo@ejemplo.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!v.contains('@')) {
                            return 'Correo no válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _telefonoController,
                        label: 'Teléfono *',
                        hint: '10 dígitos',
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Field 3: Ciudad * (Dropdown)
            _buildDropdownField(
              label: 'Ciudad *',
              hint: 'Selecciona una ciudad',
              value: _selectedCiudad,
              items: _ciudades,
              onChanged: (val) => setState(() => _selectedCiudad = val),
            ),

            const SizedBox(height: 16),

            // Field 4: Asunto * (Dropdown)
            _buildDropdownField(
              label: 'Asunto *',
              hint: 'Selecciona un asunto',
              value: _selectedAsunto,
              items: _asuntos,
              onChanged: (val) => setState(() => _selectedAsunto = val),
            ),

            const SizedBox(height: 16),

            // Field 5: Mensaje *
            _buildTextField(
              controller: _mensajeController,
              label: 'Mensaje *',
              hint: 'Escribe tu mensaje (mínimo 10 caracteres)',
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().length < 10) {
                  return 'El mensaje debe tener al menos 10 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Submit Button: Enviar mensaje
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _isSubmitting ? null : _submitForm,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Enviar mensaje',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            color: const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(
                hint,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
