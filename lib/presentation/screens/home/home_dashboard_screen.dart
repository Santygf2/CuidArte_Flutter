import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:cuidarte_app/core/theme/app_colors.dart';
import 'package:cuidarte_app/core/utils/formatters.dart';
import 'package:cuidarte_app/models/client_dashboard_model.dart';
import 'package:cuidarte_app/models/user_model.dart';
import 'package:cuidarte_app/models/visit_model.dart';
import 'package:cuidarte_app/providers/auth_provider.dart';
import 'package:cuidarte_app/providers/caregiver_provider.dart';
import 'package:cuidarte_app/providers/client_dashboard_provider.dart';
import 'package:cuidarte_app/providers/shop_provider.dart';
import 'package:cuidarte_app/providers/visit_provider.dart';
import 'package:cuidarte_app/providers/workshop_provider.dart';
import 'package:cuidarte_app/presentation/screens/chat/messages_inbox_screen.dart';
import 'package:cuidarte_app/presentation/screens/profile/my_orders_screen.dart';
import 'package:cuidarte_app/presentation/screens/profile/my_visits_screen.dart';
import 'package:cuidarte_app/presentation/screens/public/contactanos_screen.dart';
import 'package:cuidarte_app/presentation/screens/public/servicios_screen.dart';
import 'package:cuidarte_app/presentation/screens/public/sobre_nosotros_screen.dart';
import 'package:cuidarte_app/presentation/screens/shop/cart_screen.dart';
import 'package:cuidarte_app/presentation/widgets/cuidarte_logo.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeDashboardScreen({super.key, required this.onNavigateTab});

  static const List<BoxShadow> _softShadow = [
    BoxShadow(color: Color(0x12000000), blurRadius: 30, offset: Offset(0, 8)),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final dashboardProv = context.watch<ClientDashboardProvider>();
    final shopProv = context.watch<ShopProvider>();
    final notifications = dashboardProv.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const CuidArteLogo(),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
              if (shopProv.cartCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.rejected,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${shopProv.cartCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => _openNotifications(context, dashboardProv),
              ),
              if (notifications.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.rejected,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${notifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHero(context, user),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 60,
                    ),
                    child: Column(
                      children: [
                        _buildKpis(context, dashboardProv),
                        const SizedBox(height: 24),
                        _responsiveTwoColumn(
                          context,
                          left: _buildUpcomingVisitsPanel(
                            context,
                            dashboardProv,
                          ),
                          right: _buildUpcomingWorkshopsPanel(dashboardProv),
                          breakpoint: 820,
                        ),
                        const SizedBox(height: 24),
                        _responsiveTwoColumn(
                          context,
                          left: _buildQuickActionsPanel(context),
                          right: _buildHelpPanel(context),
                          breakpoint: 820,
                        ),
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

  Widget _buildHero(BuildContext context, UserModel? user) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleSize = (screenWidth * 0.026).clamp(24.0, 33.6);
    final fullName = (user?.name ?? '').trim();
    final greeting = fullName.isEmpty ? 'Hola' : 'Hola, $fullName';

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
                _heroAvatar(user?.avatarUrl),
                const SizedBox(height: 12),
                Text(
                  greeting,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                _heroBadge(),
                const SizedBox(height: 16),
                _searchButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'CLIENTE',
        style: GoogleFonts.poppins(
          fontSize: 12.48,
          fontWeight: FontWeight.w700,
          height: 1,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _searchButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onNavigateTab(1),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            alignment: Alignment.center,
            child: Text(
              'Buscar cuidadores',
              style: GoogleFonts.poppins(
                fontSize: 15.68,
                fontWeight: FontWeight.w600,
                height: 1,
                color: const Color(0xFF27BEF5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroAvatar(String? url) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: SizedBox(
          width: 74,
          height: 74,
          child: (url != null && url.isNotEmpty)
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _avatarFallback(),
                )
              : _avatarFallback(),
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Image.asset(
      'assets/images/user2.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.white,
        child: const Icon(Icons.person, color: AppColors.primary, size: 42),
      ),
    );
  }

  Widget _buildKpis(BuildContext context, ClientDashboardProvider provider) {
    if (provider.isLoading && provider.dashboard == null) {
      return const LinearProgressIndicator(minHeight: 4);
    }
    if (provider.errorMessage != null && provider.dashboard == null) {
      return _errorCard(provider.errorMessage!, provider.load);
    }

    final stats = provider.stats;
    final cards = <Widget>[
      _kpiCard(
        icon: Icons.calendar_month_rounded,
        value: '${stats.visits}',
        label: 'Visitas solicitadas',
        gradient: const [AppColors.primary, AppColors.primaryLight],
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MyVisitsScreen())),
      ),
      _kpiCard(
        icon: Icons.schedule_rounded,
        value: '${stats.pendingVisits}',
        label: 'Visitas por confirmar',
        gradient: const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MyVisitsScreen())),
      ),
      _kpiCard(
        icon: Icons.school_rounded,
        value: '${stats.workshops}',
        label: 'Talleres inscritos',
        gradient: const [Color(0xFF34D399), Color(0xFF10B981)],
        onTap: () => onNavigateTab(2),
      ),
      _kpiCard(
        icon: Icons.chat_bubble_outline_rounded,
        value: '${stats.unreadMessages}',
        label: 'Mensajes sin leer',
        gradient: const [AppColors.accent, Color(0xFFFF9BBD)],
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MessagesInboxScreen())),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + 16) / (190 + 16)).floor().clamp(
          1,
          cards.length,
        );
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 86,
          ),
          itemBuilder: (_, index) => cards[index],
        );
      },
    );
  }

  Widget _kpiCard({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EAF0)),
        boxShadow: _softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 24.8,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2937),
                          height: 1.1,
                        ),
                      ),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13.12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4B5563),
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

  Widget _buildUpcomingVisitsPanel(
    BuildContext context,
    ClientDashboardProvider provider,
  ) {
    final visits = provider.upcomingVisits;
    Widget content;

    if (provider.isLoading && provider.dashboard == null) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (provider.errorMessage != null) {
      content = _panelError(provider.errorMessage!, provider.load);
    } else if (visits.isEmpty) {
      content = _emptyState(
        emoji: '📅',
        text: 'No tienes visitas confirmadas próximas.',
      );
    } else {
      content = Column(
        children: visits.map((visit) => _visitRow(visit)).toList(),
      );
    }

    return _panelShell(
      child: Column(
        children: [
          _panelHeader(
            title: 'Próximas visitas',
            actionText: 'Ver todas',
            onAction: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MyVisitsScreen())),
          ),
          content,
        ],
      ),
    );
  }

  Widget _visitRow(VisitModel visit) {
    final initial = visit.caregiverName.isNotEmpty
        ? visit.caregiverName[0].toUpperCase()
        : 'C';
    final startTime = visit.timeSlot.split(' - ').first;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                fontSize: 15.2,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.caregiverName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.72,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  visit.caregiverSpecialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.12,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${DateFormat('d MMM', 'es').format(visit.date)} · $startTime',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    fontSize: 13.12,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 4),
                _successBadge(visit.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _successBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.48,
          fontWeight: FontWeight.w700,
          height: 1,
          color: const Color(0xFF166534),
        ),
      ),
    );
  }

  Widget _buildUpcomingWorkshopsPanel(ClientDashboardProvider provider) {
    final workshops = provider.upcomingWorkshops;
    Widget content;

    if (provider.isLoading && provider.dashboard == null) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (provider.errorMessage != null) {
      content = _panelError(provider.errorMessage!, provider.load);
    } else if (workshops.isEmpty) {
      content = _emptyState(
        emoji: '🎓',
        text: 'No tienes talleres programados.',
        actionText: 'Ver talleres',
        onAction: () => onNavigateTab(2),
      );
    } else {
      content = Column(
        children: workshops.map((workshop) => _workshopRow(workshop)).toList(),
      );
    }

    return _panelShell(
      child: Column(
        children: [
          _panelHeader(
            title: 'Próximos talleres',
            actionText: 'Ver mis talleres',
            onAction: () => onNavigateTab(2),
            dotColor: const Color(0xFF10B981),
          ),
          content,
        ],
      ),
    );
  }

  Widget _workshopRow(UpcomingWorkshopModel workshop) {
    final dateLabel = DateFormat("EEEE, d MMM y", 'es').format(workshop.date);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF34D399), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text('🎓', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workshop.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.72,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '$dateLabel · ${_format12h(workshop.time)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.12,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _format12h(String time) {
    final parts = time.split(':');
    if (parts.length < 2) {
      return time;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return time;
    }
    final value = DateTime(2000, 1, 1, hour, minute);
    return DateFormat('h:mm a', 'es').format(value);
  }

  Widget _buildQuickActionsPanel(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.search_rounded,
        label: 'Buscar cuidadores',
        onTap: () => onNavigateTab(1),
      ),
      _QuickAction(
        icon: Icons.medical_services_outlined,
        label: 'Servicios',
        onTap: () => _openPublic(
          context,
          'Servicios',
          ServiciosScreen(onNavigateTab: (_) {}, onLoginPressed: () {}),
        ),
      ),
      _QuickAction(
        icon: Icons.storefront_outlined,
        label: 'Tienda',
        onTap: () => onNavigateTab(3),
      ),
      _QuickAction(
        icon: Icons.receipt_long_outlined,
        label: 'Mis pedidos',
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
      ),
      _QuickAction(
        icon: Icons.school_outlined,
        label: 'Mis talleres',
        onTap: () => onNavigateTab(2),
      ),
      _QuickAction(
        icon: Icons.person_outline_rounded,
        label: 'Mi cuenta',
        onTap: () => onNavigateTab(4),
      ),
    ];

    return _panelShell(
      child: Column(
        children: [
          _panelHeader(title: 'Accesos rápidos'),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = ((width + 12) / (150 + 12)).floor().clamp(
                1,
                actions.length,
              );
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
                itemBuilder: (_, index) {
                  final action = actions[index];
                  return Material(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: action.onTap,
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
                              action.icon,
                              color: const Color(0xFF27BEF5),
                              size: 22,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              action.label,
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

  Widget _buildHelpPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F9FF), Colors.white],
          stops: [0, 0.6],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeader(
            title: '¿Necesitas ayuda?',
            dotColor: const Color(0xFFEF4444),
          ),
          Text(
            'Nuestro equipo puede orientarte para elegir al cuidador ideal, '
            'resolver dudas sobre tus visitas o acompañarte en el proceso.',
            style: GoogleFonts.poppins(
              fontSize: 14.72,
              height: 1.6,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _gradientButton(
                text: 'Contactar soporte',
                onTap: () => _openPublic(
                  context,
                  'Contáctanos',
                  const ContactanosScreen(),
                ),
              ),
              _ghostButton(
                text: 'Conoce CuidArte',
                onTap: () => _openPublic(
                  context,
                  'Sobre CuidArte',
                  const SobreNosotrosScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({required String text, required VoidCallback onTap}) {
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
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15.68,
                fontWeight: FontWeight.w600,
                height: 1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ghostButton({required String text, required VoidCallback onTap}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
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
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15.68,
                fontWeight: FontWeight.w600,
                height: 1,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _responsiveTwoColumn(
    BuildContext context, {
    required Widget left,
    required Widget right,
    required double breakpoint,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > breakpoint) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 24),
          Expanded(child: right),
        ],
      );
    }
    return Column(children: [left, const SizedBox(height: 24), right]);
  }

  Widget _panelShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EAF0)),
        boxShadow: _softShadow,
      ),
      child: child,
    );
  }

  Widget _panelHeader({
    required String title,
    Color dotColor = const Color(0xFF27BEF5),
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
                '$actionText →',
                style: GoogleFonts.poppins(
                  fontSize: 13.6,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0284C7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _panelError(String message, Future<void> Function() onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required String emoji,
    required String text,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return _DashedRoundedBorder(
      color: const Color(0xFFE6EAF0),
      radius: 20,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF27BEF5).withOpacity(0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 24),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                height: 1.35,
                color: const Color(0xFF4B5563),
              ),
            ),
            if (actionText != null) ...[
              const SizedBox(height: 12),
              _outlineSmallButton(text: actionText, onTap: onAction!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _outlineSmallButton({
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
                height: 1,
                color: const Color(0xFF27BEF5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorCard(String message, Future<void> Function() retry) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.rejected.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.rejected.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.rejected),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(onPressed: () => retry(), child: const Text('Reintentar')),
        ],
      ),
    );
  }

  void _openPublic(BuildContext context, String title, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text(title)),
          body: screen,
        ),
      ),
    );
  }

  Future<void> _openNotifications(
    BuildContext context,
    ClientDashboardProvider provider,
  ) async {
    if (provider.notifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes notificaciones pendientes.')),
      );
      return;
    }

    final notifications = List<AppNotificationModel>.from(
      provider.notifications,
    );
    await provider.markNotificationsRead();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificaciones',
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: notifications.take(8).map((notification) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryContainer,
                            child: Icon(
                              Icons.notifications_active_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            notification.title,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            notification.message,
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          trailing: Text(
                            Formatters.formatDate(notification.date),
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData(BuildContext context) async {
    await Future.wait([
      context.read<ClientDashboardProvider>().load(),
      context.read<VisitProvider>().loadMyVisits(),
      context.read<ShopProvider>().loadOrders(),
      context.read<ShopProvider>().loadProducts(),
      context.read<CaregiverProvider>().load(),
      context.read<WorkshopProvider>().load(),
    ]);
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _DashedRoundedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;

  const _DashedRoundedBorder({
    required this.child,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedRoundedBorderPainter(
        color: color,
        radius: radius,
      ),
      child: child,
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 4).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + 3;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
