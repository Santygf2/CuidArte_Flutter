import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/educational_resource_model.dart';
import '../../../models/workshop_model.dart';
import '../../../providers/client_dashboard_provider.dart';
import '../../../providers/resource_provider.dart';
import '../../../providers/workshop_provider.dart';
import '../../widgets/cuidarte_logo.dart';
import '../../widgets/error_retry.dart';
import 'resource_viewer_screen.dart';

class WorkshopsResourcesScreen extends StatefulWidget {
  const WorkshopsResourcesScreen({super.key});

  @override
  State<WorkshopsResourcesScreen> createState() =>
      _WorkshopsResourcesScreenState();
}

class _WorkshopsResourcesScreenState extends State<WorkshopsResourcesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _workshopSearch = TextEditingController();
  final _resourceSearch = TextEditingController();
  String _workshopQuery = '';

  static const _workshopThemes = [
    [Color(0xFF0F8FC4), Color(0xFF4FC3F7), Color(0xFF9BE7FF)],
    [Color(0xFF0E7490), Color(0xFF22B8CF), Color(0xFF7FE3E8)],
    [Color(0xFF4F46E5), Color(0xFF7C8CF8), Color(0xFFC4B5FD)],
    [Color(0xFFBE3D75), Color(0xFFFF6B9D), Color(0xFFFFB3CE)],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WorkshopProvider>().ensureLoaded();
      context.read<ResourceProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _workshopSearch.dispose();
    _resourceSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const CuidArteLogo(),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF27BEF5),
          unselectedLabelColor: const Color(0xFF4B5563),
          indicatorColor: const Color(0xFF27BEF5),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.groups_rounded, size: 20),
              text: 'Talleres Grupales',
            ),
            Tab(
              icon: Icon(Icons.menu_book_rounded, size: 20),
              text: 'Biblioteca de Salud',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWorkshopsTab(context), _buildResourcesTab(context)],
      ),
    );
  }

  Widget _buildWorkshopsTab(BuildContext context) {
    final provider = context.watch<WorkshopProvider>();
    final dashboard = context.read<ClientDashboardProvider>();
    final query = _workshopQuery.toLowerCase().trim();
    final sessions = provider.workshops.where((session) {
      if (query.isEmpty) return true;
      return session.title.toLowerCase().contains(query);
    }).toList();
    final groups = _groupWorkshops(sessions);
    final totalSlots = sessions.fold<int>(
      0,
      (sum, session) => sum + session.availableSlots,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWorkshopHero(
            totalWorkshops: groups.length,
            totalSessions: sessions.length,
            totalSlots: totalSlots,
          ),
          Transform.translate(
            offset: const Offset(0, -32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _buildWorkshopSearch(groups.length),
                ),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildWorkshopList(context, provider, dashboard, groups),
              ),
            ),
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildWorkshopHero({
    required int totalWorkshops,
    required int totalSessions,
    required int totalSlots,
  }) {
    final width = MediaQuery.of(context).size.width;
    final compact = width <= 560;
    final titleSize = (width * 0.045).clamp(32.0, 48.0);
    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA), Color(0xFF27BEF5)],
            stops: [0, 0.5, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -150, right: -100, child: _heroCircle(400)),
            Positioned(bottom: -100, left: -80, child: _heroCircle(300)),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 18 : 20,
                    compact ? 52 : 66,
                    compact ? 18 : 20,
                    compact ? 70 : 80,
                  ),
                  child: Column(
                    children: [
                      _heroKicker('AGENDA CUIDARTE'),
                      const SizedBox(height: 14),
                      Text(
                        'Calendario de Talleres',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          'Elige un taller, revisa sus fechas y asegura tu cupo. Todas las sesiones son virtuales y en vivo.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 17.28,
                            height: 1.65,
                            color: Colors.white.withOpacity(0.96),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _heroStat('$totalWorkshops', 'TALLERES'),
                          _heroStat('$totalSessions', 'HORARIOS'),
                          _heroStat('$totalSlots', 'CUPOS LIBRES'),
                        ],
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

  Widget _heroCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _heroKicker(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.34)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11.84,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Container(
      constraints: const BoxConstraints(minWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 23.2,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.52,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopSearch(int totalGroups) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF2F7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.12),
            blurRadius: 44,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _workshopSearch,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    setState(() => _workshopQuery = value.trim());
                  },
                  style: GoogleFonts.poppins(fontSize: 15.68),
                  decoration: InputDecoration(
                    hintText: 'Busca un taller por nombre...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 15.68,
                      color: const Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              _pillButton(
                text: 'Buscar',
                onTap: () {
                  setState(() => _workshopQuery = _workshopSearch.text.trim());
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            totalGroups > 0
                ? '$totalGroups taller${totalGroups == 1 ? '' : 'es'} disponible${totalGroups == 1 ? '' : 's'} · cupos limitados'
                : 'Escribe el nombre o explora todos los talleres',
            style: GoogleFonts.poppins(
              fontSize: 12.8,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillButton({required String text, required VoidCallback onTap}) {
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
            color: const Color(0xFF27BEF5).withOpacity(0.32),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14.08,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopList(
    BuildContext context,
    WorkshopProvider provider,
    ClientDashboardProvider dashboard,
    List<_WorkshopGroup> groups,
  ) {
    if (provider.isLoading && provider.workshops.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.errorMessage != null && provider.workshops.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: ErrorRetry(
          message: provider.errorMessage!,
          onRetry: provider.load,
        ),
      );
    }
    if (groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: _workshopEmpty(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 720 ? 2 : 1;
        final itemWidth = (width - (columns - 1) * 28) / columns;
        return Wrap(
          spacing: 28,
          runSpacing: 28,
          children: List.generate(groups.length, (index) {
            final group = groups[index];
            return SizedBox(
              width: itemWidth,
              child: _WorkshopGroupCard(
                key: ValueKey(group.id),
                group: group,
                themeIndex: index,
                onToggleEnrollment: (session) =>
                    _toggleEnrollment(context, provider, dashboard, session),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _workshopEmpty() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE6EAF0)),
          ),
          child: Column(
            children: [
              _emptyIcon('📅'),
              const SizedBox(height: 24),
              Text(
                _workshopQuery.isNotEmpty
                    ? 'No encontramos talleres para "$_workshopQuery"'
                    : 'Aún no hay talleres programados',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 21.6,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _workshopQuery.isNotEmpty
                    ? 'Prueba con otra palabra o revisa todos los talleres disponibles.'
                    : 'Muy pronto publicaremos nuevas fechas y horarios.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 24),
              _gradientPillButton(
                text: _workshopQuery.isNotEmpty
                    ? 'Ver todos los talleres'
                    : 'Ver Servicios',
                onTap: () {
                  if (_workshopQuery.isNotEmpty) {
                    _workshopSearch.clear();
                    setState(() => _workshopQuery = '');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyIcon(String emoji) {
    return Container(
      width: 72,
      height: 72,
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
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }

  Widget _gradientPillButton({
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

  List<_WorkshopGroup> _groupWorkshops(List<WorkshopModel> sessions) {
    final grouped = <String, List<WorkshopModel>>{};
    for (final session in sessions) {
      final key = session.workshopId.isNotEmpty
          ? session.workshopId
          : session.title;
      grouped.putIfAbsent(key, () => []).add(session);
    }
    final groups =
        grouped.entries.map((entry) {
          final list = entry.value..sort(_compareSessions);
          final first = list.first;
          return _WorkshopGroup(
            id: entry.key,
            title: first.title,
            description: first.description,
            imageUrl: first.imageUrl,
            modality: first.modality,
            location: first.locationOrLink,
            sessions: list,
          );
        }).toList()..sort(
          (a, b) => a.sessions.first.date.compareTo(b.sessions.first.date),
        );
    return groups;
  }

  int _compareSessions(WorkshopModel a, WorkshopModel b) {
    final dateCompare = a.date.compareTo(b.date);
    if (dateCompare != 0) return dateCompare;
    return _minutes(a.time).compareTo(_minutes(b.time));
  }

  int _minutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  Future<void> _toggleEnrollment(
    BuildContext context,
    WorkshopProvider provider,
    ClientDashboardProvider dashboard,
    WorkshopModel session,
  ) async {
    try {
      final updated = await provider.toggleEnrollment(session.id);
      if (!context.mounted) return;
      dashboard.load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: updated.isEnrolled
              ? AppColors.secondary
              : AppColors.rejected,
          content: Text(
            updated.isEnrolled
                ? '¡Te has inscrito al taller exitosamente!'
                : 'Inscripción cancelada.',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rejected,
          content: Text(error.message),
        ),
      );
    }
  }

  Widget _buildResourcesTab(BuildContext context) {
    final provider = context.watch<ResourceProvider>();
    final resources = provider.filteredResources;
    final all = provider.resources;
    final showFeatured =
        provider.selectedCategory == 'Todas' &&
        provider.searchQuery.trim().isEmpty &&
        resources.isNotEmpty;
    final featured = showFeatured ? resources.first : null;
    final gridResources = showFeatured ? resources.skip(1).toList() : resources;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildResourcesHero(resources.length),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 64),
                child: Column(
                  children: [
                    _buildResourceFilters(provider),
                    _buildResourceStats(all, resources.length),
                    _buildResourceNote(),
                    if (provider.isLoading && all.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (provider.errorMessage != null)
                      ErrorRetry(
                        message: provider.errorMessage!,
                        onRetry: provider.load,
                      )
                    else ...[
                      if (featured != null) _buildFeaturedResource(featured),
                      if (resources.isEmpty)
                        _resourceEmpty()
                      else
                        _buildResourceGrid(gridResources),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesHero(int totalResources) {
    final width = MediaQuery.of(context).size.width;
    final compact = width <= 560;
    final titleSize = (width * 0.045).clamp(32.0, 46.4);
    return ClipRect(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA), Color(0xFF27BEF5)],
            stops: [0, 0.5, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -150, right: -100, child: _heroCircle(400)),
            Positioned(bottom: -100, left: -80, child: _heroCircle(300)),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 18 : 20,
                    compact ? 52 : 72,
                    compact ? 18 : 20,
                    compact ? 68 : 84,
                  ),
                  child: Column(
                    children: [
                      _heroKicker('BIBLIOTECA CUIDARTE'),
                      const SizedBox(height: 14),
                      Text(
                        'Recursos y Guías Profesionales',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Text(
                          'Material descargable sobre cuidado profesional, salud del adulto mayor, ejercicios y bienestar emocional.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16.8,
                            height: 1.65,
                            color: Colors.white.withOpacity(0.96),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      _buildResourceSearch(totalResources),
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

  Widget _buildResourceSearch(int total) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 540),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _resourceSearch,
              onChanged: (value) {
                context.read<ResourceProvider>().setSearchQuery(value);
              },
              onSubmitted: (value) {
                context.read<ResourceProvider>().setSearchQuery(value);
              },
              style: GoogleFonts.poppins(fontSize: 15.2),
              decoration: InputDecoration(
                hintText: 'Buscar un recurso o guía...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 15.2,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          _pillButton(
            text: 'Buscar',
            onTap: () {
              context.read<ResourceProvider>().setSearchQuery(
                _resourceSearch.text,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceFilters(ResourceProvider provider) {
    final categories = provider.categories;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final selected = provider.selectedCategory == category;
        final label = category == 'Todas' ? 'Todos' : category;
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              color: selected ? null : Colors.white,
              gradient: selected
                  ? const LinearGradient(
                      colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? Colors.transparent : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF27BEF5).withOpacity(0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: InkWell(
              onTap: () => provider.setCategory(category),
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14.08,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResourceStats(
    List<EducationalResourceModel> all,
    int filteredCount,
  ) {
    final categories = [
      'Cuidado Profesional',
      'Cuerpo del Adulto Mayor',
      'Ejercicio y Salud Física',
      'Salud Emocional y Cognitiva',
      'Otros Recursos',
    ];
    final colors = [
      [const Color(0xFFCFFAFE), const Color(0xFF0E7490)],
      [const Color(0xFFDCFCE7), const Color(0xFF15803D)],
      [const Color(0xFFFFE4EF), const Color(0xFFDB2777)],
      [const Color(0xFFEDE9FE), const Color(0xFF6D28D9)],
      [const Color(0xFFE0F5FE), const Color(0xFF0284C7)],
    ];
    final stats = <(int, String, Color, Color, IconData)>[
      (
        filteredCount,
        'recursos disponibles',
        const Color(0xFFE0F5FE),
        const Color(0xFF0284C7),
        Icons.menu_book_outlined,
      ),
    ];
    for (var i = 0; i < categories.length; i++) {
      final count = all.where((r) => r.category == categories[i]).length;
      if (count > 0) {
        stats.add((
          count,
          categories[i],
          colors[i][0],
          colors[i][1],
          Icons.description_outlined,
        ));
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width <= 560
            ? 2
            : ((width + 12) / (165 + 12)).floor().clamp(1, 5);
        return Padding(
          padding: const EdgeInsets.only(top: 26, bottom: 22),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 70,
            ),
            itemBuilder: (context, index) {
              final stat = stats[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFEDF1F6)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D0F172A),
                      blurRadius: 22,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: stat.$3,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(stat.$5, color: stat.$4, size: 20),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${stat.$1}',
                            style: GoogleFonts.poppins(
                              fontSize: 17.6,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              height: 1.15,
                            ),
                          ),
                          Text(
                            stat.$2.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10.88,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: const Color(0xFF7B8794),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResourceNote() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD3EDFA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: Color(0xFF1BA0D1),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Descargas exclusivas: ',
                children: [
                  TextSpan(
                    text: 'inicia sesión para descargar las guías en PDF. Si ya tienes cuenta, solo pulsa el botón de descarga.',
                    style: GoogleFonts.poppins(
                      fontSize: 13.6,
                      height: 1.5,
                      color: const Color(0xFF4B6B7D),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              style: GoogleFonts.poppins(
                fontSize: 13.6,
                height: 1.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F5F7A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedResource(EducationalResourceModel resource) {
    final wide = MediaQuery.of(context).size.width > 760;
    final visual = Container(
      width: 150,
      height: 150,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 34,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: resource.imageUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                resource.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _featuredIcon(),
              ),
            )
          : _featuredIcon(),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B9D),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'RECURSO DESTACADO',
            style: GoogleFonts.poppins(
              fontSize: 11.04,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 13),
        Text(
          resource.title,
          style: GoogleFonts.poppins(
            fontSize: 24.8,
            fontWeight: FontWeight.w900,
            height: 1.25,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          resource.summary,
          style: GoogleFonts.poppins(
            fontSize: 16,
            height: 1.65,
            color: const Color(0xFF526273),
          ),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _metaChip(resource.category),
            if (resource.createdAt != null)
              _metaChip(
                DateFormat('dd/MM/yyyy', 'es').format(resource.createdAt!),
              ),
          ],
        ),
        const SizedBox(height: 17),
        _gradientPillButton(
          text: 'Descargar PDF',
          onTap: () => _openResource(resource),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 30),
      padding: EdgeInsets.all(wide ? 30 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F9FF), Color(0xFFE6F6FF), Color(0xFFFFEEF5)],
          stops: [0, 0.6, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFCCEBFA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: wide
          ? Row(
              children: [
                Expanded(child: text),
                const SizedBox(width: 24),
                visual,
              ],
            )
          : Column(children: [visual, const SizedBox(height: 20), text]),
    );
  }

  Widget _featuredIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.menu_book_rounded, size: 56, color: Color(0xFF1BA0D1)),
        const SizedBox(height: 6),
        Text(
          'PDF',
          style: GoogleFonts.poppins(
            fontSize: 10.88,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: const Color(0xFFFF6B9D),
          ),
        ),
      ],
    );
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2EEF6)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11.84,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF60758A),
        ),
      ),
    );
  }

  Widget _buildResourceGrid(List<EducationalResourceModel> resources) {
    if (resources.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + 24) / (300 + 24)).floor().clamp(1, 4);
        final itemWidth = (width - (columns - 1) * 24) / columns;
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: resources.map<Widget>((resource) {
            return SizedBox(width: itemWidth, child: _resourceCard(resource));
          }).toList(),
        );
      },
    );
  }

  Widget _resourceCard(EducationalResourceModel resource) {
    final gradient = _resourceGradient(resource.category);
    final icon = _resourceIcon(resource.category);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF1F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 128,
            decoration: BoxDecoration(gradient: gradient),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    size: 44,
                    color: Colors.white.withOpacity(0.94),
                  ),
                ),
                Positioned(
                  top: 11,
                  left: 11,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      resource.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10.56,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 11,
                  right: 11,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      resource.fileType.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 9.92,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 18, 19, 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16.96,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  resource.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.92,
                    height: 1.55,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Color(0xFF9AA5B1),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              resource.createdAt != null
                                  ? DateFormat(
                                      'dd/MM/yyyy',
                                      'es',
                                    ).format(resource.createdAt!)
                                  : '',
                              style: GoogleFonts.poppins(
                                fontSize: 11.52,
                                color: const Color(0xFF9AA5B1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: const Color(0xFFEAF9FF),
                        borderRadius: BorderRadius.circular(9),
                        child: InkWell(
                          onTap: () => _openResource(resource),
                          borderRadius: BorderRadius.circular(9),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFC9EEFC),
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.download_rounded,
                                  size: 15,
                                  color: Color(0xFF1BA0D1),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Descargar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.16,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1BA0D1),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openResource(EducationalResourceModel resource) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResourceViewerScreen(resource: resource),
      ),
    );
  }

  LinearGradient _resourceGradient(String category) {
    switch (category) {
      case 'Cuerpo del Adulto Mayor':
        return const LinearGradient(
          colors: [Color(0xFF0E7490), Color(0xFF27B3C8), Color(0xFF8CE5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Ejercicio y Salud Física':
        return const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF2BB8A4), Color(0xFF93E8CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Salud Emocional y Cognitiva':
        return const LinearGradient(
          colors: [Color(0xFFBE3D75), Color(0xFFFF6B9D), Color(0xFFFFB4CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Otros Recursos':
        return const LinearGradient(
          colors: [Color(0xFF475569), Color(0xFF7C8B9D), Color(0xFFC2CCD6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF0F8FC4), Color(0xFF5BC9F4), Color(0xFFA6E8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _resourceIcon(String category) {
    switch (category) {
      case 'Cuerpo del Adulto Mayor':
        return Icons.accessibility_new_rounded;
      case 'Ejercicio y Salud Física':
        return Icons.monitor_heart_outlined;
      case 'Salud Emocional y Cognitiva':
        return Icons.sentiment_satisfied_alt_rounded;
      case 'Otros Recursos':
        return Icons.folder_outlined;
      default:
        return Icons.favorite_border_rounded;
    }
  }

  Widget _resourceEmpty() {
    final provider = context.read<ResourceProvider>();
    final query = provider.searchQuery.trim();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE6EAF0)),
            ),
            child: Column(
              children: [
                _emptyIcon('📚'),
                const SizedBox(height: 24),
                Text(
                  query.isNotEmpty
                      ? 'No encontramos recursos para "$query"'
                      : 'Aún no hay recursos disponibles',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 21.6,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  query.isNotEmpty
                      ? 'Prueba con otra palabra o revisa todas las categorías.'
                      : 'Muy pronto publicaremos nuevas guías y materiales descargables.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 24),
                _gradientPillButton(
                  text: query.isNotEmpty
                      ? 'Ver todos los recursos'
                      : 'Ver Servicios',
                  onTap: () {
                    if (query.isNotEmpty) {
                      _resourceSearch.clear();
                      provider.setSearchQuery('');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkshopGroup {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String modality;
  final String location;
  final List<WorkshopModel> sessions;

  const _WorkshopGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.modality,
    required this.location,
    required this.sessions,
  });

  int get totalAvailable =>
      sessions.fold(0, (sum, session) => sum + session.availableSlots);

  int get days {
    final dates = sessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();
    return dates.length;
  }
}

class _WorkshopGroupCard extends StatefulWidget {
  final _WorkshopGroup group;
  final int themeIndex;
  final Future<void> Function(WorkshopModel session) onToggleEnrollment;

  const _WorkshopGroupCard({
    super.key,
    required this.group,
    required this.themeIndex,
    required this.onToggleEnrollment,
  });

  @override
  State<_WorkshopGroupCard> createState() => _WorkshopGroupCardState();
}

class _WorkshopGroupCardState extends State<_WorkshopGroupCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final first = group.sessions.first;
    final theme =
        _WorkshopsResourcesScreenState._workshopThemes[widget.themeIndex %
            _WorkshopsResourcesScreenState._workshopThemes.length];
    final available = group.totalAvailable;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9EFF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 36,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: theme,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (group.imageUrl.isNotEmpty)
                        Positioned.fill(
                          child: Image.network(
                            group.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      Positioned(
                        right: 26,
                        bottom: -20,
                        child: Text(
                          group.title.isNotEmpty
                              ? group.title[0].toUpperCase()
                              : 'T',
                          style: GoogleFonts.poppins(
                            fontSize: 112,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(0.13),
                            height: 1,
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 48,
                          color: Colors.white.withOpacity(0.92),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF020617).withOpacity(0.50),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.36, 1],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.96),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${group.days} día${group.days == 1 ? '' : 's'} · ${group.sessions.length} horario${group.sessions.length == 1 ? '' : 's'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.28),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF43F5E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    group.modality.toLowerCase() == 'virtual'
                                        ? 'Virtual en vivo'
                                        : 'Presencial',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.52,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              group.title,
                              style: GoogleFonts.poppins(
                                fontSize: 19.2,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: available > 0
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: available > 0
                                    ? const Color(0xFFA7F3D0)
                                    : const Color(0xFFFECACA),
                              ),
                            ),
                            child: Text(
                              available > 0
                                  ? '$available cupo${available == 1 ? '' : 's'}'
                                  : 'Sin cupos',
                              style: GoogleFonts.poppins(
                                fontSize: 11.52,
                                fontWeight: FontWeight.w800,
                                color: available > 0
                                    ? const Color(0xFF047857)
                                    : const Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        _truncate(group.description, 160),
                        style: GoogleFonts.poppins(
                          fontSize: 14.4,
                          height: 1.6,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 15,
                            color: Color(0xFF27BEF5),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Próxima sesión: ',
                                children: [
                                  TextSpan(
                                    text: DateFormat(
                                      'EEE d MMM',
                                      'es',
                                    ).format(first.date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' · ${_format12h(first.time)}',
                                  ),
                                ],
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 12.8,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF7FBFE), Color(0xFFEFF9FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    border: Border(top: BorderSide(color: Color(0xFFF0F4F8))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ver fechas y horarios',
                              style: GoogleFonts.poppins(
                                fontSize: 13.44,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1BA0D1),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Elige el día y luego tu horario para inscribirte',
                              style: GoogleFonts.poppins(
                                fontSize: 11.52,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF1BA0D1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildExpanded(context),
            crossFadeState: _open
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    final byDate = <DateTime, List<WorkshopModel>>{};
    for (final session in widget.group.sessions) {
      final date = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      byDate.putIfAbsent(date, () => []).add(session);
    }
    final dates = byDate.keys.toList()..sort();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        border: Border(top: BorderSide(color: Color(0xFFE9EFF5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PASO 1',
                      style: GoogleFonts.poppins(
                        fontSize: 11.2,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: const Color(0xFF1BA0D1),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Elige el día que prefieras',
                      style: GoogleFonts.poppins(
                        fontSize: 17.6,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF9FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${dates.length} fecha${dates.length == 1 ? '' : 's'}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.84,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1BA0D1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...dates.map((date) => _buildDateGroup(date, byDate[date]!)),
        ],
      ),
    );
  }

  Widget _buildDateGroup(DateTime date, List<WorkshopModel> sessions) {
    final month = DateFormat('MMM', 'es').format(date);
    final weekday = DateFormat('EEEE', 'es').format(date);
    final weekdayCapitalized = weekday.isEmpty
        ? weekday
        : '${weekday[0].toUpperCase()}${weekday.substring(1)}';
    final monthYear = DateFormat('MMMM y', 'es').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCFE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7EDF4), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF27BEF5).withOpacity(0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('d', 'es').format(date),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Text(
                        month.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 9.28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weekdayCapitalized,
                        style: GoogleFonts.poppins(
                          fontSize: 15.2,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${sessions.length} horario${sessions.length == 1 ? '' : 's'} · $monthYear',
                        style: GoogleFonts.poppins(
                          fontSize: 12.16,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB8C5D3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = (width / 158).floor().clamp(1, 4);
              final itemWidth = (width - (columns - 1) * 11) / columns;
              return Wrap(
                spacing: 11,
                runSpacing: 11,
                children: sessions.map((session) {
                  return SizedBox(
                    width: itemWidth,
                    child: _buildTimeCard(session),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(WorkshopModel session) {
    final full = session.availableSlots <= 0;
    final enrolled = session.isEnrolled;
    final total = session.totalSlots;
    final percent = total > 0
        ? ((total - session.availableSlots) * 100 / total).clamp(0, 100)
        : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(11, 13, 11, 12),
      decoration: BoxDecoration(
        color: enrolled
            ? const Color(0xFFF4FDF8)
            : full
            ? const Color(0xFFFBFCFD)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: enrolled ? const Color(0xFF86EFAC) : const Color(0xFFE7EDF4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF9FF),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFCDEEFC)),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              size: 18,
              color: Color(0xFF1BA0D1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _format12h(session.time),
            style: GoogleFonts.poppins(
              fontSize: 15.52,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            full
                ? 'Sin cupos'
                : '${session.availableSlots} cupo${session.availableSlots == 1 ? '' : 's'} disponible${session.availableSlots == 1 ? '' : 's'}',
            style: GoogleFonts.poppins(
              fontSize: 11.52,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 4,
              backgroundColor: const Color(0xFFEDF2F7),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF27BEF5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (enrolled) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '✓ Inscrito',
                style: GoogleFonts.poppins(
                  fontSize: 12.48,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF047857),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Material(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => widget.onToggleEnrollment(session),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.poppins(
                      fontSize: 11.68,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB91C1C),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (full)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Cupos agotados',
                style: GoogleFonts.poppins(
                  fontSize: 12.48,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            )
          else
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF27BEF5).withOpacity(0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => widget.onToggleEnrollment(session),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    alignment: Alignment.center,
                    child: Text(
                      'Inscribirme',
                      style: GoogleFonts.poppins(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _truncate(String value, int max) {
  if (value.length <= max) {
    return value;
  }
  return '${value.substring(0, max - 1)}…';
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
