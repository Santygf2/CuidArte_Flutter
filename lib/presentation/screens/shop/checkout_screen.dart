import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/client_dashboard_provider.dart';
import '../../../providers/shop_provider.dart';
import '../../widgets/cuidarte_logo.dart';
import 'invoice_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _processing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _email.text = user?.email ?? '';
    _phone.text = user?.phone ?? '';
    _address.text = user?.city ?? user?.address ?? '';
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').trim();
    if (phone.length != 10 || int.tryParse(phone) == null) {
      return 'Debe tener exactamente 10 dígitos';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if ((value ?? '').trim().length < 5) {
      return 'Mínimo 5 caracteres';
    }
    return null;
  }

  Future<void> _confirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final shop = context.read<ShopProvider>();
    if (shop.cartList.isEmpty) {
      setState(() => _error = 'Tu carrito está vacío.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      setState(
        () => _error = 'Debes iniciar sesión para completar la compra.',
      );
      return;
    }

    setState(() {
      _processing = true;
      _error = null;
    });
    try {
      final order = await shop.checkout(
        recipientName: user.name,
        recipientPhone: _phone.text.trim(),
        shippingAddress: _address.text.trim(),
        city: '',
        paymentMethod: 'Contra entrega',
        email: _email.text.trim(),
      );
      if (!mounted) return;
      context.read<ClientDashboardProvider>().load();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => InvoiceScreen(order: order)),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const CuidArteLogo()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 36,
                  ),
                  child: Column(
                    children: [
                      _buildSummary(shop),
                      const SizedBox(height: 20),
                      _buildShipping(context),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Text(
                  'Confirmar Compra',
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
                  'Revisa tu pedido y confirma tus datos',
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

  Widget _buildSummary(ShopProvider shop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del pedido',
            style: GoogleFonts.poppins(
              fontSize: 16.8,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 14),
          ...shop.cartList.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} x${item.quantity}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.72,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(item.totalPrice),
                    style: GoogleFonts.poppins(
                      fontSize: 14.72,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      fontSize: 17.6,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                Text(
                  Formatters.formatCurrency(shop.total),
                  style: GoogleFonts.poppins(
                    fontSize: 17.6,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipping(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos de envío',
              style: GoogleFonts.poppins(
                fontSize: 16.32,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Puedes editar el correo, el teléfono y la ciudad / dirección. La factura en PDF llegará al correo indicado.',
              style: GoogleFonts.poppins(
                fontSize: 13.6,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            _field(
              label: 'Correo para la factura 📧',
              controller: _email,
              hint: 'correo@ejemplo.com',
              helper: 'Te enviaremos la factura PDF a este correo',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth > 520;
                if (twoColumns) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _field(
                          label: 'Teléfono',
                          controller: _phone,
                          hint: '10 dígitos',
                          helper: 'Debe tener exactamente 10 dígitos',
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          validator: _validatePhone,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _field(
                          label: 'Ciudad / Dirección',
                          controller: _address,
                          hint: 'Ciudad y dirección de envío',
                          validator: _validateAddress,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _field(
                      label: 'Teléfono',
                      controller: _phone,
                      hint: '10 dígitos',
                      helper: 'Debe tener exactamente 10 dígitos',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: _validatePhone,
                    ),
                    _field(
                      label: 'Ciudad / Dirección',
                      controller: _address,
                      hint: 'Ciudad y dirección de envío',
                      validator: _validateAddress,
                    ),
                  ],
                );
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  _error!,
                  style: GoogleFonts.poppins(
                    fontSize: 13.6,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final buttons = [
                  Expanded(
                    child: _gradientButton(
                      text: 'Confirmar compra',
                      loading: _processing,
                      onTap: _processing ? null : _confirm,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ghostButton(
                    text: 'Volver al carrito',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ];
                if (constraints.maxWidth > 520) {
                  return Row(children: buttons);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _gradientButton(
                      text: 'Confirmar compra',
                      loading: _processing,
                      onTap: _processing ? null : _confirm,
                    ),
                    const SizedBox(height: 12),
                    _ghostButton(
                      text: 'Volver al carrito',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? helper,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            validator: validator,
            style: GoogleFonts.poppins(
              fontSize: 15.2,
              color: const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 15.2,
                color: const Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: Colors.white,
              counterText: '',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF27BEF5)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper,
              style: GoogleFonts.poppins(
                fontSize: 12.8,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
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
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27BEF5).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: 14.72,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ghostButton({required String text, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14.72,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
