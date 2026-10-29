import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/admin_api.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/admin_models.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/error_retry.dart';
import 'admin_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key, required this.tipo, this.api});

  final String tipo;
  final AdminApi? api;

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late final AdminApi _api;
  final TextEditingController _searchController = TextEditingController();
  List<AdminUserItem> _items = [];
  int _activeCount = 0;
  int _disabledCount = 0;
  int _allCount = 0;
  String _estado = 'activos';
  String _query = '';
  bool _loading = true;
  bool _actionLoading = false;
  String? _error;

  bool get _isCaregiver => widget.tipo == 'cuidador';
  Color get _accent =>
      _isCaregiver ? const Color(0xFF059669) : const Color(0xFF0284C7);
  String get _title =>
      _isCaregiver ? 'Gestión de Cuidadores' : 'Gestión de Clientes';
  String get _subtitle => _isCaregiver
      ? 'Administra los perfiles de los cuidadores registrados y su disponibilidad en la plataforma'
      : 'Administra las cuentas de clientes de la plataforma, controlando su estado de acceso';
  String get _searchHint => _isCaregiver
      ? 'Buscar por cédula, nombre, especialidad...'
      : 'Buscar por nombre, correo...';

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
      final page = await _api.users(
        tipo: widget.tipo,
        estado: _estado,
        q: _query,
      );
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _activeCount = page.activeCount;
        _disabledCount = page.disabledCount;
        _allCount = page.allCount;
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
        _error = 'No se pudieron cargar las cuentas. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  Future<void> _search() async {
    setState(() => _query = _searchController.text.trim());
    await _load();
  }

  void _setEstado(String estado) {
    if (_estado == estado) return;
    setState(() => _estado = estado);
    _load();
  }

  Future<void> _toggle(AdminUserItem item) async {
    final activate = !item.isActive;
    final nombre = item.fullName;
    final question = activate
        ? (_isCaregiver
              ? '¿Reactivar al cuidador $nombre?\n\nVolverá a aparecer activo en la plataforma.'
              : '¿Reactivar al usuario ${item.username}?\n\nVolverá a tener acceso a la plataforma.')
        : (_isCaregiver
              ? '¿Deshabilitar al cuidador $nombre?\n\nDejará de aparecer en la búsqueda de clientes y no podrá iniciar sesión hasta que lo reactives.'
              : '¿Deshabilitar al usuario ${item.username}?\n\nLa cuenta quedará deshabilitada y no podrá ingresar a la plataforma, pero no se perderán sus datos ni su historial.');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activate ? 'Reactivar cuenta' : 'Deshabilitar cuenta'),
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: activate
                  ? AppColors.secondaryDark
                  : AppColors.rejected,
            ),
            child: Text(activate ? 'Reactivar' : 'Deshabilitar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _actionLoading = true);
    try {
      final message = await _api.setUserActive(item.id, active: activate);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
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
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selfId = int.tryParse(
      context.watch<AuthProvider>().currentUser?.id ?? '',
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              AdminPageHeader(title: _title, subtitle: _subtitle),
              AdminBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearch(),
                    const SizedBox(height: 14),
                    _buildFilters(),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 70),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      ErrorRetry(message: _error!, onRetry: _load)
                    else if (_items.isEmpty)
                      AdminEmptyState(
                        message: _isCaregiver
                            ? 'No se encontraron cuidadores\n\nNo hay registros para el filtro seleccionado.'
                            : 'No se encontraron clientes\n\nNo hay registros para el filtro seleccionado.',
                        icon: Icons.people_outline_rounded,
                      )
                    else
                      for (final item in _items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildUser(item, selfId),
                        ),
                    if (_actionLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: LinearProgressIndicator(minHeight: 2),
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

  Widget _buildSearch() {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _search(),
        style: GoogleFonts.poppins(fontSize: 13.5),
        decoration: InputDecoration(
          hintText: _searchHint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 12.5,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textMuted,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(5),
            child: TextButton(
              onPressed: _search,
              style: TextButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Buscar'),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 92),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accent, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = <(String, String, int)>[
      ('activos', 'Activos', _activeCount),
      ('deshabilitados', 'Deshabilitados', _disabledCount),
      ('todos', 'Todos', _allCount),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in filters)
          ChoiceChip(
            label: Text('${filter.$2} (${filter.$3})'),
            selected: _estado == filter.$1,
            onSelected: (_) => _setEstado(filter.$1),
            selectedColor: _accent.withOpacity(0.14),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: _estado == filter.$1 ? _accent : AppColors.border,
            ),
            labelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _estado == filter.$1 ? _accent : AppColors.textMuted,
            ),
          ),
      ],
    );
  }

  Widget _buildUser(AdminUserItem item, int? selfId) {
    final joined = item.dateJoined == null
        ? ''
        : DateFormat('dd/MM/yyyy').format(item.dateJoined!);
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isActive
                        ? AppColors.secondary
                        : AppColors.rejected.withOpacity(0.4),
                    width: 1.6,
                  ),
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: _accent.withOpacity(0.12),
                  backgroundImage:
                      item.avatarUrl != null && item.avatarUrl!.isNotEmpty
                      ? NetworkImage(item.avatarUrl!)
                      : null,
                  child: item.avatarUrl == null
                      ? Text(
                          item.initials,
                          style: GoogleFonts.poppins(
                            color: _accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.fullName,
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        AdminBadge(
                          text: item.isActive ? 'Activo' : 'Deshabilitado',
                          foreground: item.isActive
                              ? const Color(0xFF166534)
                              : const Color(0xFF991B1B),
                          background: item.isActive
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${item.username}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.email,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (item.phone.isNotEmpty) _info('Tel: ${item.phone}'),
                        if (_isCaregiver && item.cedula.isNotEmpty)
                          _info('Cédula: ${item.cedula}'),
                        if (_isCaregiver && item.specialties.isNotEmpty)
                          _info(item.specialties),
                        if (!_isCaregiver && item.address.isNotEmpty)
                          _info(item.address),
                      ],
                    ),
                    if (joined.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        'Miembro desde $joined',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: item.id == selfId
                ? const AdminBadge(
                    text: 'Tú (Admin)',
                    foreground: Color(0xFF0369A1),
                    background: Color(0xFFE0F2FE),
                  )
                : AdminActionChipButton(
                    label: item.isActive ? 'Deshabilitar' : 'Reactivar',
                    icon: item.isActive
                        ? Icons.block_rounded
                        : Icons.check_circle_outline_rounded,
                    foreground: item.isActive
                        ? const Color(0xFFE11D48)
                        : const Color(0xFF059669),
                    background: item.isActive
                        ? const Color(0xFFFFF1F2)
                        : const Color(0xFFECFDF5),
                    onPressed: () => _toggle(item),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _info(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
