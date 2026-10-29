import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/caregiver_provider.dart';
import '../../widgets/caregiver_card.dart';
import '../../widgets/cuidarte_logo.dart';
import '../../widgets/error_retry.dart';
import 'caregiver_detail_screen.dart';

class CaregiversListScreen extends StatefulWidget {
  const CaregiversListScreen({super.key});

  @override
  State<CaregiversListScreen> createState() => _CaregiversListScreenState();
}

class _CaregiversListScreenState extends State<CaregiversListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<CaregiverProvider>();
      provider.resetFilters();
      provider.ensureLoaded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final value = _searchController.text.trim();
    setState(() => _query = value);
    context.read<CaregiverProvider>().setSearchQuery(value);
  }

  void _clear() {
    _searchController.clear();
    setState(() => _query = '');
    context.read<CaregiverProvider>().setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CaregiverProvider>();
    final caregivers = provider.filteredCaregivers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CuidArteLogo(),
      ),
      body: Column(
        children: [
          _buildHero(context),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 36,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = MediaQuery.of(context).size.width > 780;
                        final sidebar = _buildSidebar();
                        final list = _buildList(provider, caregivers);
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 260, child: sidebar),
                              const SizedBox(width: 24),
                              Expanded(child: list),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            sidebar,
                            const SizedBox(height: 24),
                            list,
                          ],
                        );
                      },
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
                  'Buscar Cuidadores',
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
                  'Encuentra el profesional ideal según su especialidad',
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

  Widget _buildSidebar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF27BEF5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Filtrar por especialidad',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            style: GoogleFonts.poppins(fontSize: 14.72),
            decoration: InputDecoration(
              hintText: 'Ej: Geriatría, Pediatría...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14.72,
                color: const Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF27BEF5)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _fullGradientButton(text: 'Buscar', onTap: _search),
          if (_query.isNotEmpty) ...[
            const SizedBox(height: 8),
            _fullGhostButton(text: 'Limpiar', onTap: _clear),
          ],
          const SizedBox(height: 12),
          Text(
            'Escribe una especialidad y presiona Buscar. Coincidencia parcial.',
            style: GoogleFonts.poppins(
              fontSize: 13.12,
              height: 1.4,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          if (_query.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: 'Resultados para: ',
                children: [
                  TextSpan(
                    text: '"$_query"',
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              style: GoogleFonts.poppins(
                fontSize: 13.6,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fullGradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
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
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14.08,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fullGhostButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14.08,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    CaregiverProvider provider,
    List caregivers,
  ) {
    if (provider.isLoading && provider.caregivers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.errorMessage != null && provider.caregivers.isEmpty) {
      return ErrorRetry(
        message: provider.errorMessage!,
        onRetry: provider.load,
      );
    }
    if (caregivers.isEmpty) {
      return _buildEmpty();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + 18) / (250 + 18)).floor().clamp(1, 4);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${caregivers.length} cuidador(es) encontrado(s)',
              style: GoogleFonts.poppins(
                fontSize: 14.4,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: caregivers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                mainAxisExtent: 340,
              ),
              itemBuilder: (context, index) {
                final caregiver = caregivers[index];
                return CaregiverCard(
                  caregiver: caregiver,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CaregiverDetailScreen(caregiver: caregiver),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'No se encontraron cuidadores',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _query.isNotEmpty
                ? 'Intenta con otra especialidad o limpia el filtro.'
                : 'Aún no hay cuidadores registrados.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          if (_query.isNotEmpty) ...[
            const SizedBox(height: 14),
            _fullGhostButton(text: 'Ver todos', onTap: _clear),
          ],
        ],
      ),
    );
  }
}
