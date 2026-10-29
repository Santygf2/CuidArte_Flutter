import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/network/admin_api.dart';
import '../../../core/network/api_client.dart';
import '../../../core/session/session_cleanup.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/admin_models.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/cuidarte_logo.dart';
import '../../widgets/error_retry.dart';
import '../public/public_main_wrapper.dart';
import '../admin/admin_list_screen.dart';
import '../admin/admin_messages_screen.dart';
import '../admin/admin_module_config.dart';
import '../admin/admin_orders_screen.dart';
import '../admin/admin_profile_screen.dart';
import '../admin/admin_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, this.api});

  final AdminApi? api;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminApi _api;
  AdminDashboardStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AdminApi();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await _api.dashboard();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
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
        _error = 'No se pudo cargar el panel. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    resetClientProviders(context);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PublicMainWrapper()),
      (route) => false,
    );
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final username = (user?.username ?? '').trim();
    final stats = _stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CuidArteLogo(imageSize: 34, fontSize: 20),
        actions: [
          IconButton(
            tooltip: 'Inicio',
            onPressed: _load,
            icon: const Icon(Icons.home_outlined, color: AppColors.info),
          ),
          IconButton(
            tooltip: 'Ver Sitio',
            onPressed: () => _open(const PublicMainWrapper()),
            icon: const Icon(Icons.public_rounded, color: AppColors.info),
          ),
          IconButton(
            tooltip: 'Perfil',
            onPressed: () => _open(const AdminProfileScreen()),
            icon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.info,
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, color: AppColors.rejected),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildWelcome(username),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: _loading && stats == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _error != null && stats == null
                        ? ErrorRetry(message: _error!, onRetry: _load)
                        : Column(
                            children: [
                              _buildGrid(stats ?? _emptyStats),
                              const SizedBox(height: 28),
                              _buildInfoCard(),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AdminDashboardStats get _emptyStats => const AdminDashboardStats(
    totalUsuarios: 0,
    totalUsuariosDeshabilitados: 0,
    totalCuidadores: 0,
    totalCuidadoresDeshabilitados: 0,
    totalServicios: 0,
    totalProductos: 0,
    totalMensajes: 0,
    totalEspecialidades: 0,
    totalPedidosCompra: 0,
    totalPedidosItems: 0,
    totalTalleres: 0,
    totalRecursos: 0,
  );

  Widget _buildWelcome(String username) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 44),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Panel de Administrador',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bienvenido, ${username.isEmpty ? 'administrador' : username} '
                '— gestiona cuidadores, usuarios, servicios y productos '
                'desde el menú superior',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.94),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(AdminDashboardStats stats) {
    final cards = <Widget>[
      _DashboardCard(
        icon: Icons.people_alt_outlined,
        accent: const Color(0xFF0284C7),
        iconBackground: const Color(0xFFE0F2FE),
        gradient: const [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
        value: stats.totalUsuarios.toString(),
        label: 'Clientes Activos',
        note: _statusNote(
          stats.totalUsuariosDeshabilitados,
          'deshabilitado',
          'Todos los clientes activos',
        ),
        description: 'Administra cuentas de clientes y estados de acceso.',
        buttonLabel: 'Gestionar Clientes →',
        buttonForeground: Colors.white,
        onTap: () => _open(const AdminUsersScreen(tipo: 'cliente')),
      ),
      _DashboardCard(
        icon: Icons.monitor_heart_outlined,
        accent: const Color(0xFF059669),
        iconBackground: const Color(0xFFDCFCE7),
        gradient: const [Color(0xFF10B981), Color(0xFF6EE7B7)],
        value: stats.totalCuidadores.toString(),
        label: 'Cuidadores Activos',
        note: _statusNote(
          stats.totalCuidadoresDeshabilitados,
          'deshabilitado',
          'Todos los cuidadores activos',
        ),
        description: 'Revisa perfiles, cédulas y estado de disponibilidad.',
        buttonLabel: 'Ver Cuidadores →',
        buttonForeground: Colors.white,
        onTap: () => _open(const AdminUsersScreen(tipo: 'cuidador')),
      ),
      _DashboardCard(
        icon: Icons.medical_services_outlined,
        accent: const Color(0xFFD97706),
        iconBackground: const Color(0xFFFEF3C7),
        gradient: const [Color(0xFFF59E0B), Color(0xFFFCD34D)],
        value: stats.totalServicios.toString(),
        label: 'Servicios',
        description: 'Crea y edita los servicios de cuidado.',
        buttonLabel: 'Gestionar Servicios →',
        buttonForeground: const Color(0xFF92400E),
        onTap: () => _open(AdminListScreen(config: servicesModule())),
      ),
      _DashboardCard(
        icon: Icons.auto_awesome_outlined,
        accent: const Color(0xFF0369A1),
        iconBackground: const Color(0xFFECFEFF),
        gradient: const [Color(0xFF06B6D4), Color(0xFF7DD3FC)],
        value: stats.totalEspecialidades.toString(),
        label: 'Especialidades',
        description: 'Gestiona las especialidades que se muestran en la página principal.',
        buttonLabel: 'Gestionar Especialidades →',
        buttonForeground: const Color(0xFF065F46),
        onTap: () => _open(AdminListScreen(config: specialtiesModule())),
      ),
      _DashboardCard(
        icon: Icons.shopping_bag_outlined,
        accent: const Color(0xFF7C3AED),
        iconBackground: const Color(0xFFEDE9FE),
        gradient: const [Color(0xFF8B5CF6), Color(0xFFC4B5FD)],
        value: stats.totalProductos.toString(),
        label: 'Productos',
        description: 'Controla catálogo, precios y stock de la tienda.',
        buttonLabel: 'Gestionar Tienda →',
        buttonForeground: Colors.white,
        onTap: () => _open(AdminListScreen(config: productsModule())),
      ),
      _DashboardCard(
        icon: Icons.receipt_long_outlined,
        accent: const Color(0xFF0F766E),
        iconBackground: const Color(0xFFCCFBF1),
        gradient: const [Color(0xFF14B8A6), Color(0xFF6EE7B7)],
        value: stats.totalPedidosCompra.toString(),
        label: 'Pedidos',
        note: Text(
          '${stats.totalPedidosItems} '
          'producto${stats.totalPedidosItems == 1 ? '' : 's'} '
          'vendido${stats.totalPedidosItems == 1 ? '' : 's'}',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        description:
            'Todas las compras (cliente o cuidador) agrupadas por factura.',
        buttonLabel: 'Ver Pedidos →',
        buttonForeground: const Color(0xFF0F766E),
        onTap: () => _open(const AdminOrdersScreen()),
      ),
      _DashboardCard(
        icon: Icons.event_available_outlined,
        accent: const Color(0xFF9333EA),
        iconBackground: const Color(0xFFF3E8FF),
        gradient: const [Color(0xFFA855F7), Color(0xFFC4B5FD)],
        value: stats.totalTalleres.toString(),
        label: 'Talleres',
        description: 'Crea el calendario de talleres y actividades.',
        buttonLabel: 'Gestionar Talleres →',
        buttonForeground: Colors.white,
        onTap: () => _open(AdminListScreen(config: workshopsModule())),
      ),
      _DashboardCard(
        icon: Icons.menu_book_outlined,
        accent: const Color(0xFF0284C7),
        iconBackground: const Color(0xFFE0F2FE),
        gradient: const [Color(0xFF0EA5E9), Color(0xFF7DD3FC)],
        value: stats.totalRecursos.toString(),
        label: 'Recursos',
        description: 'Guías y documentos descargables de cuidado.',
        buttonLabel: 'Gestionar Recursos →',
        buttonForeground: const Color(0xFF075985),
        onTap: () => _open(AdminListScreen(config: resourcesModule())),
      ),
      _DashboardCard(
        icon: Icons.mail_outline_rounded,
        accent: const Color(0xFFDB2777),
        iconBackground: const Color(0xFFFCE7F3),
        gradient: const [Color(0xFFEC4899), Color(0xFFF9A8D4)],
        value: stats.totalMensajes.toString(),
        label: 'Mensajes',
        description: 'Mensajes recibidos desde Contáctanos.',
        buttonLabel: 'Ver Mensajes →',
        buttonForeground: Colors.white,
        onTap: () => _open(const AdminMessagesScreen()),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1020
            ? 3
            : width >= 680
            ? 2
            : 1;
        const spacing = 16.0;
        final cardWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }

  Widget _statusNote(int disabledCount, String noun, String allActiveText) {
    if (disabledCount > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$disabledCount $noun${disabledCount == 1 ? '' : 's'}',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFDC2626),
          ),
        ),
      );
    }
    return Text(
      allActiveText,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF16A34A),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Usa el menú superior '),
                  TextSpan(
                    text: 'Inicio | Ver Sitio | Perfil',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' para navegar y las tarjetas de abajo para '
                        'gestionar. Los cambios se reflejan al instante '
                        'en la base de datos.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.accent,
    required this.iconBackground,
    required this.gradient,
    required this.value,
    required this.label,
    required this.description,
    required this.buttonLabel,
    required this.buttonForeground,
    required this.onTap,
    this.note,
  });

  final IconData icon;
  final Color accent;
  final Color iconBackground;
  final List<Color> gradient;
  final String value;
  final String label;
  final Widget? note;
  final String description;
  final String buttonLabel;
  final Color buttonForeground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(icon, color: accent, size: 26),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 33,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2937),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        label.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      if (note != null) ...[const SizedBox(height: 7), note!],
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: const Color(0xFF9CA3AF),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          buttonLabel,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: buttonForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
