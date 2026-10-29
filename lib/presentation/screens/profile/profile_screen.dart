import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/session/session_cleanup.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/client_dashboard_provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/visit_provider.dart';
import '../../widgets/cuidarte_logo.dart';
import '../chat/messages_inbox_screen.dart';
import '../navigation/main_navigation_screen.dart';
import '../public/public_main_wrapper.dart';
import 'edit_profile_screen.dart';
import 'my_orders_screen.dart';
import 'my_visits_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    resetClientProviders(context);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PublicMainWrapper()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final dashboard = context.watch<ClientDashboardProvider>();
    final visits = context.watch<VisitProvider>();
    final shop = context.watch<ShopProvider>();
    final stats = dashboard.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CuidArteLogo(),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, color: AppColors.rejected),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
                  child: Column(
                    children: [
                      _buildProfileHero(context, user),
                      _buildStats(
                        context,
                        orders: shop.orders.length,
                        contacts: stats.contacts,
                        visits: visits.visits.length,
                        workshops: stats.workshops,
                      ),
                      _buildProfileGrid(context, user),
                      _buildQuickActions(context),
                      _buildCompleteness(context, user),
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
                  'Mi cuenta',
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
                  'Administra tu información personal y revisa tu actividad en CuidArte',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 17.6,
                    color: Colors.white.withOpacity(0.94),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHero(BuildContext context, UserModel? user) {
    final wide = MediaQuery.of(context).size.width > 700;
    final avatarSize = wide ? 118.0 : 92.0;
    final username = (user?.username ?? '').isNotEmpty
        ? user!.username
        : (user?.email ?? '').split('@').first;
    final memberSince = user?.dateJoined != null
        ? DateFormat('dd/MM/yyyy', 'es').format(user!.dateJoined!)
        : '—';

    final avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        color: const Color(0xFFF3F4F6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
            ? Image.network(
                user.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _profileAvatarFallback(),
              )
            : _profileAvatarFallback(),
      ),
    );

    final info = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          user?.name ?? 'Usuario',
          textAlign: wide ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: wide ? 25.6 : 21.6,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@$username · ${(user?.email ?? '').isNotEmpty ? user!.email : 'Sin correo'}',
          textAlign: wide ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15.2,
            color: const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _badge(
              'CLIENTE',
              background: const Color(0xFFE0F2FE),
              color: const Color(0xFF0369A1),
            ),
            if ((user?.city ?? '').isNotEmpty)
              _badge(
                '📍 ${user!.city}',
                background: const Color(0xFFF3F4F6),
                color: const Color(0xFF4B5563),
                weight: FontWeight.w400,
              ),
            _badge(
              'Miembro desde $memberSince',
              background: const Color(0xFFF3F4F6),
              color: const Color(0xFF4B5563),
              weight: FontWeight.w400,
            ),
          ],
        ),
      ],
    );

    final editButton = _gradientButton(
      text: 'Editar datos',
      onTap: () => _openEdit(context),
    );

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: wide
          ? Row(
              children: [
                avatar,
                const SizedBox(width: 24),
                Expanded(child: info),
                const SizedBox(width: 16),
                editButton,
              ],
            )
          : Column(
              children: [
                avatar,
                const SizedBox(height: 16),
                info,
                const SizedBox(height: 16),
                editButton,
              ],
            ),
    );
  }

  Widget _profileAvatarFallback() {
    return Image.asset(
      'assets/images/user2.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.person,
        size: 48,
        color: Color(0xFF9CA3AF),
      ),
    );
  }

  Widget _badge(
    String text, {
    required Color background,
    required Color color,
    FontWeight weight = FontWeight.w700,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.48,
          fontWeight: weight,
          color: color,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildStats(
    BuildContext context, {
    required int orders,
    required int contacts,
    required int visits,
    required int workshops,
  }) {
    final items = [
      ('$orders', 'Pedidos'),
      ('$contacts', 'Contactos'),
      ('$visits', 'Visitas'),
      ('$workshops', 'Talleres'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + 16) / (130 + 16)).floor().clamp(1, 4);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 84,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6EAF0)),
                boxShadow: _softShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.$1,
                    style: GoogleFonts.poppins(
                      fontSize: 27.2,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF27BEF5),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    item.$2,
                    style: GoogleFonts.poppins(
                      fontSize: 13.44,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileGrid(BuildContext context, UserModel? user) {
    final wide = MediaQuery.of(context).size.width > 700;
    final personal = _profileCard(
      title: 'Información personal',
      actionText: 'Editar →',
      onAction: () => _openEdit(context),
      child: _rows([
        ('Nombre completo', user?.name ?? 'Usuario'),
        ('Usuario', (user?.username ?? '').isNotEmpty ? user!.username : '—'),
        ('Correo', (user?.email ?? '').isNotEmpty ? user!.email : 'No especificado'),
        ('📞 Teléfono', (user?.phone ?? '').isNotEmpty ? user!.phone : 'No especificado'),
        ('📍 Ciudad', (user?.city ?? '').isNotEmpty ? user!.city : 'No especificado'),
      ]),
    );

    final security = _profileCard(
      title: 'Seguridad y accesos',
      dotColor: const Color(0xFF10B981),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rows([
            ('Contraseña', '••••••••'),
            ('Cuenta', 'Activa'),
          ]),
          const SizedBox(height: 16),
          Text(
            'Puedes actualizar tu contraseña desde la sección de edición de tus datos.',
            style: GoogleFonts.poppins(
              fontSize: 14.08,
              height: 1.6,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _smallOutlineButton(
                text: 'Cambiar contraseña',
                onTap: () => _openEdit(context),
              ),
              _smallGhostButton(
                text: 'Ver mensajes',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MessagesInboxScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: personal),
          const SizedBox(width: 24),
          Expanded(child: security),
        ],
      );
    }
    return Column(
      children: [
        personal,
        const SizedBox(height: 24),
        security,
      ],
    );
  }

  Widget _profileCard({
    required String title,
    Color dotColor = const Color(0xFF27BEF5),
    String? actionText,
    VoidCallback? onAction,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              if (actionText != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0284C7),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionText,
                    style: GoogleFonts.poppins(
                      fontSize: 13.6,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _rows(List<(String, String)> rows) {
    return Column(
      children: rows
          .map(
            (row) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: GoogleFonts.poppins(
                        fontSize: 14.08,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      row.$2,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        fontSize: 14.72,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (
        Icons.calendar_month_outlined,
        'Mis visitas',
        () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyVisitsScreen()),
            ),
      ),
      (
        Icons.receipt_long_outlined,
        'Mis pedidos',
        () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            ),
      ),
      (
        Icons.school_outlined,
        'Mis talleres',
        () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainNavigationScreen(initialIndex: 2),
              ),
              (route) => false,
            ),
      ),
      (
        Icons.search_rounded,
        'Buscar cuidadores',
        () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainNavigationScreen(initialIndex: 1),
              ),
              (route) => false,
            ),
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Accesos rápidos',
                style: GoogleFonts.poppins(
                  fontSize: 16.8,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  ((constraints.maxWidth + 12) / (150 + 12)).floor().clamp(1, 4);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: actions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 96,
                ),
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return Material(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: action.$3,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE6EAF0)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              action.$1,
                              color: const Color(0xFF27BEF5),
                              size: 22,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              action.$2,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14.4,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteness(BuildContext context, UserModel? user) {
    final completitud = user?.completitud ?? 0;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFF27BEF5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Datos completos',
                  style: GoogleFonts.poppins(
                    fontSize: 16.8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              _badge(
                '$completitud%',
                background: const Color(0xFFDCFCE7),
                color: const Color(0xFF166534),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completitud / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFEEF1F5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF27BEF5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (completitud >= 100)
            Text(
              '¡Excelente! Tus datos están completos.',
              style: GoogleFonts.poppins(
                fontSize: 14.4,
                color: const Color(0xFF4B5563),
              ),
            )
          else
            Text.rich(
              TextSpan(
                text:
                    'Completar tus datos mejora tu experiencia y la confianza de los cuidadores. ',
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _openEdit(context),
                      child: Text(
                        'Completar ahora →',
                        style: GoogleFonts.poppins(
                          fontSize: 14.4,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              style: GoogleFonts.poppins(
                fontSize: 14.4,
                color: const Color(0xFF4B5563),
              ),
            ),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE6EAF0)),
      boxShadow: _softShadow,
    );
  }

  static const List<BoxShadow> _softShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];

  Widget _gradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15.68,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallOutlineButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF27BEF5), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14.4,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF27BEF5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallGhostButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14.4,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
