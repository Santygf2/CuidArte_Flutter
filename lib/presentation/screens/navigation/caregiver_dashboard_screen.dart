import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/session/session_cleanup.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/caregiver_agenda_model.dart';
import '../../../models/client_dashboard_model.dart';
import '../../../models/visit_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/caregiver_agenda_provider.dart';
import '../../widgets/cuidarte_logo.dart';
import '../../widgets/error_retry.dart';
import '../chat/messages_inbox_screen.dart';
import '../public/public_main_wrapper.dart';
import '../workshops/workshops_resources_screen.dart';
import 'caregiver_agenda_screen.dart';
import 'caregiver_clients_screen.dart';
import 'caregiver_profile_screen.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CaregiverAgendaProvider>().ensureLoaded();
      }
    });
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

  Future<void> _refresh(BuildContext context) async {
    await context.read<CaregiverAgendaProvider>().load();
  }

  void _openAgenda(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CaregiverAgendaScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final provider = context.watch<CaregiverAgendaProvider>();
    final agenda = provider.agenda;
    final stats = provider.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
      body: RefreshIndicator(
        onRefresh: () => _refresh(context),
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
                    child: provider.isLoading && agenda == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : provider.errorMessage != null && agenda == null
                        ? ErrorRetry(
                            message: provider.errorMessage!,
                            onRetry: provider.load,
                          )
                        : Column(
                            children: [
                              _buildKpis(context, stats),
                              const SizedBox(height: 24),
                              _responsiveTwoColumn(
                                left: _buildUpcomingPanel(context, agenda),
                                right: _buildRecentRequestsPanel(
                                  context,
                                  agenda,
                                ),
                                breakpoint: 820,
                              ),
                              const SizedBox(height: 24),
                              _responsiveTwoColumn(
                                left: _buildNotificationsPanel(context, agenda),
                                right: _buildQuickActions(context),
                                breakpoint: 820,
                              ),
                              const SizedBox(height: 24),
                              _buildCompleteness(context, user),
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

  Widget _buildHero(BuildContext context, dynamic user) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = (width * 0.026).clamp(24.0, 33.6);
    final fullName = (user?.name ?? '').toString().trim();
    final greeting = fullName.isEmpty ? 'Hola' : 'Hola, $fullName';
    final verified = ((user?.cedula ?? '') as String).isNotEmpty;
    final avatar = user?.avatarUrl as String?;

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
                _avatar(avatar),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    verified ? 'CUIDADOR · ✓ Verificado' : 'CUIDADOR',
                    style: GoogleFonts.poppins(
                      fontSize: 12.48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _whiteButton(
                  text: 'Ver mi agenda',
                  onTap: () => _openAgenda(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? url) {
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
      'assets/images/user1.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.white,
        child: const Icon(Icons.person, color: Color(0xFF27BEF5), size: 42),
      ),
    );
  }

  Widget _whiteButton({required String text, required VoidCallback onTap}) {
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
                color: const Color(0xFF27BEF5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpis(BuildContext context, CaregiverAgendaStats stats) {
    final cards = <Widget>[
      _kpiCard(
        icon: Icons.chat_bubble_outline_rounded,
        value: '${stats.solicitudes}',
        label: 'Solicitudes nuevas',
        gradient: const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        onTap: () => _openAgenda(context),
      ),
      _kpiCard(
        icon: Icons.calendar_month_rounded,
        value: '${stats.pendientes}',
        label: 'Visitas por confirmar',
        gradient: const [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
        onTap: () => _openAgenda(context),
      ),
      _kpiCard(
        icon: Icons.people_alt_outlined,
        value: '${stats.clientes}',
        label: 'Clientes',
        gradient: const [Color(0xFF34D399), Color(0xFF10B981)],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CaregiverClientsScreen()),
        ),
      ),
      _kpiCard(
        icon: Icons.mail_outline_rounded,
        value: '${stats.mensajes}',
        label: 'Mensajes sin leer',
        gradient: const [Color(0xFFFF6B9D), Color(0xFFFF9BBD)],
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
        final itemWidth = (width - (columns - 1) * 16) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((card) => SizedBox(width: itemWidth, child: card))
              .toList(),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
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

  Widget _buildUpcomingPanel(
    BuildContext context,
    CaregiverAgendaModel? agenda,
  ) {
    final upcoming = agenda?.upcoming ?? const <VisitModel>[];
    return _panel(
      child: Column(
        children: [
          _panelHeader(
            title: 'Próximas visitas',
            actionText: 'Ver agenda',
            onAction: () => _openAgenda(context),
          ),
          if (upcoming.isEmpty)
            _emptyState(
              emoji: '📅',
              text: 'No tienes visitas confirmadas próximas.',
            )
          else
            ...upcoming.map(_visitRow),
        ],
      ),
    );
  }

  Widget _buildRecentRequestsPanel(
    BuildContext context,
    CaregiverAgendaModel? agenda,
  ) {
    final pending = agenda?.pending ?? const <VisitModel>[];
    return _panel(
      child: Column(
        children: [
          _panelHeader(
            title: 'Solicitudes recientes',
            dotColor: const Color(0xFFF59E0B),
            actionText: 'Ver todas',
            onAction: () => _openAgenda(context),
          ),
          if (pending.isEmpty)
            _emptyState(emoji: '📥', text: 'Aún no has recibido solicitudes.')
          else
            ...pending
                .take(5)
                .map(
                  (visit) => _listRow(
                    avatarText: _initial(visit.clientName),
                    title: visit.clientName,
                    subtitle: DateFormat('dd/MM/yyyy', 'es').format(visit.date),
                    trailing: _statusBadge(visit.status),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPanel(
    BuildContext context,
    CaregiverAgendaModel? agenda,
  ) {
    final notifications =
        agenda?.notifications ?? const <AppNotificationModel>[];
    return _panel(
      child: Column(
        children: [
          _panelHeader(
            title: 'Notificaciones',
            dotColor: const Color(0xFFEF4444),
          ),
          if (notifications.isEmpty)
            _emptyState(emoji: '🔔', text: 'No tienes notificaciones nuevas.')
          else
            ...notifications
                .take(4)
                .map(
                  (notification) => _listRow(
                    avatarText: '🔔',
                    title: notification.title,
                    subtitle: _truncate(notification.message, 60),
                    trailing: Text(
                      DateFormat('d MMM', 'es').format(notification.date),
                      style: GoogleFonts.poppins(
                        fontSize: 13.12,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = <_CaregiverAction>[
      _CaregiverAction(
        icon: Icons.calendar_month_rounded,
        label: 'Mi agenda',
        onTap: () => _openAgenda(context),
      ),
      _CaregiverAction(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Solicitudes',
        onTap: () => _openAgenda(context),
      ),
      _CaregiverAction(
        icon: Icons.people_alt_outlined,
        label: 'Mis clientes',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CaregiverClientsScreen()),
          );
        },
      ),
      _CaregiverAction(
        icon: Icons.mail_outline_rounded,
        label: 'Mensajes',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MessagesInboxScreen()),
          );
        },
      ),
      _CaregiverAction(
        icon: Icons.person_outline_rounded,
        label: 'Mi cuenta',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CaregiverProfileScreen()),
          );
        },
      ),
      _CaregiverAction(
        icon: Icons.school_outlined,
        label: 'Talleres',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const WorkshopsResourcesScreen()),
          );
        },
      ),
    ];

    return _panel(
      child: Column(
        children: [
          _panelHeader(
            title: 'Accesos rápidos',
            dotColor: const Color(0xFF10B981),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = ((width + 12) / (150 + 12)).floor().clamp(1, 3);
              final itemWidth = (width - (columns - 1) * 12) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: actions.map((action) {
                  return SizedBox(
                    width: itemWidth,
                    child: Material(
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
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteness(BuildContext context, dynamic user) {
    final completitud = (user?.completitud as int?) ?? 0;
    return _panel(
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
                  'Perfil completo',
                  style: GoogleFonts.poppins(
                    fontSize: 16.8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: completitud >= 100
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$completitud%',
                  style: GoogleFonts.poppins(
                    fontSize: 12.48,
                    fontWeight: FontWeight.w700,
                    color: completitud >= 100
                        ? const Color(0xFF166534)
                        : const Color(0xFF92400E),
                  ),
                ),
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
          Text(
            completitud >= 100
                ? '¡Excelente! Tu perfil está completo y listo para recibir clientes.'
                : 'Completa tus datos para aparecer mejor en las búsquedas.',
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              color: const Color(0xFF4B5563),
            ),
          ),
          if (completitud < 100)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CaregiverProfileScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
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
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EAF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 18),
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

  Widget _listRow({
    required String avatarText,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
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
              avatarText,
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
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.72,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  subtitle,
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
          trailing,
        ],
      ),
    );
  }

  Widget _visitRow(VisitModel visit) {
    return _listRow(
      avatarText: _initial(visit.clientName),
      title: visit.clientName,
      subtitle:
          '${DateFormat('d MMM', 'es').format(visit.date)} · ${visit.timeSlot}',
      trailing: _statusBadge(visit.status),
    );
  }

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();
    final success =
        normalized.contains('aceptad') ||
        normalized.contains('verificad') ||
        normalized.contains('confirmad');
    final pending = normalized.contains('pendient');
    final background = success
        ? const Color(0xFFDCFCE7)
        : pending
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFFEE2E2);
    final color = success
        ? const Color(0xFF166534)
        : pending
        ? const Color(0xFF92400E)
        : const Color(0xFF991B1B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 12.48,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _emptyState({required String emoji, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 24),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.72,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _responsiveTwoColumn({
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

  String _initial(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : 'C';
  }

  String _truncate(String value, int max) {
    if (value.length <= max) return value;
    return '${value.substring(0, max - 1)}…';
  }
}

class _CaregiverAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CaregiverAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
