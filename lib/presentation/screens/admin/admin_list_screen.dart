import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/network/admin_api.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/error_retry.dart';
import 'admin_form_screen.dart';
import 'admin_module_config.dart';
import 'admin_widgets.dart';

class AdminListScreen extends StatefulWidget {
  const AdminListScreen({super.key, required this.config, this.api});

  final AdminModuleConfig config;
  final AdminApi? api;

  @override
  State<AdminListScreen> createState() => _AdminListScreenState();
}

class _AdminListScreenState extends State<AdminListScreen> {
  late final AdminApi _api;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AdminApi();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.records(
        widget.config.endpoint,
        query: widget.config.query,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
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
        _error = 'No se pudo cargar la información. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final term = _query.trim().toLowerCase();
    if (term.isEmpty) return _items;
    return _items.where((item) {
      for (final key in widget.config.searchKeys) {
        final value = item[key]?.toString().toLowerCase() ?? '';
        if (value.contains(term)) return true;
      }
      return false;
    }).toList();
  }

  Future<void> _openForm([Map<String, dynamic>? item]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AdminFormScreen(config: widget.config, item: item, api: _api),
      ),
    );
    if (saved == true) {
      await _load();
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final question = widget.config.deleteQuestion.isNotEmpty
        ? widget.config.deleteQuestion
        : '¿Eliminar este ${widget.config.entitySingular.toLowerCase()}?';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.rejected),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.deleteRecord(widget.config.endpoint, widget.config.idOf(item));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.config.entitySingular} eliminado.'),
          backgroundColor: AppColors.secondaryDark,
        ),
      );
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.rejected,
        ),
      );
    }
  }

  void _openSessions(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminListScreen(
          config: sessionsModule(
            tallerId: widget.config.idOf(item),
            tallerTitle: (item['titulo'] ?? 'Taller').toString(),
            tallerLocation: (item['ubicacion'] ?? '').toString(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.config.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              AdminPageHeader(
                title: widget.config.title,
                subtitle: widget.config.subtitle,
              ),
              AdminBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToolbar(filtered.length),
                    const SizedBox(height: 12),
                    _buildSearch(),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 70),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      ErrorRetry(message: _error!, onRetry: _load)
                    else if (filtered.isEmpty)
                      AdminEmptyState(
                        message: _query.trim().isNotEmpty
                            ? 'No se encontraron resultados para "$_query".'
                            : widget.config.emptyMessage,
                        icon: widget.config.icon,
                      )
                    else
                      for (final item in filtered)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildItem(item),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(int filteredCount) {
    final countText = _query.trim().isEmpty
        ? widget.config.countText(_items.length)
        : '$filteredCount coincidencia(s) de ${_items.length}';
    final count = Text(
      countText,
      style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
    );
    final addButton = ElevatedButton.icon(
      onPressed: () => _openForm(),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text(widget.config.addLabel.replaceFirst('+ ', '')),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    if (!widget.config.canCreate) return count;
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [count, addButton],
    );
  }

  Widget _buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        style: GoogleFonts.poppins(fontSize: 13.5),
        decoration: InputDecoration(
          hintText: widget.config.searchHint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textMuted,
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar búsqueda',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final title = widget.config.titleBuilder(item);
    final subtitle = widget.config.subtitleBuilder(item);
    final chips = widget.config.chipsBuilder(item);
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.config.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  widget.config.icon,
                  color: widget.config.accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                          height: 1.45,
                        ),
                      ),
                    ],
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      AdminChipWrap(chips: chips),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            alignment: WrapAlignment.end,
            children: [
              if (widget.config.canManageSessions)
                AdminActionChipButton(
                  label: 'Fechas',
                  icon: Icons.calendar_month_outlined,
                  onPressed: () => _openSessions(item),
                ),
              if (widget.config.canEdit)
                AdminActionChipButton(
                  label: 'Editar',
                  icon: Icons.edit_outlined,
                  onPressed: () => _openForm(item),
                ),
              if (widget.config.canDelete)
                AdminActionChipButton(
                  label: 'Eliminar',
                  icon: Icons.delete_outline_rounded,
                  foreground: AppColors.rejected,
                  background: AppColors.rejectedContainer,
                  onPressed: () => _delete(item),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
