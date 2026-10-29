import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/network/admin_api.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/admin_models.dart';
import '../../widgets/error_retry.dart';
import 'admin_module_config.dart';
import 'admin_widgets.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key, this.api});

  final AdminApi? api;

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  static const _statuses = <String, String>{
    'pendiente': 'Pendiente',
    'pagado': 'Pagado',
    'confirmado': 'Confirmado',
    'enviado': 'Enviado',
    'entregado': 'Entregado',
  };

  late final AdminApi _api;
  final TextEditingController _searchController = TextEditingController();
  List<AdminOrderItem> _orders = [];
  int _totalCompras = 0;
  int _totalPedidos = 0;
  String _query = '';
  bool _loading = true;
  String? _error;

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
      final page = await _api.orders(q: _query);
      if (!mounted) return;
      setState(() {
        _orders = page.items;
        _totalCompras = page.totalCompras;
        _totalPedidos = page.totalPedidos;
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
        _error = 'No se pudieron cargar los pedidos. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  Future<void> _search() async {
    setState(() => _query = _searchController.text.trim());
    await _load();
  }

  Future<void> _changeStatus(AdminOrderItem order, String status) async {
    if (status == order.status) return;
    try {
      await _api.updateOrderStatus(order.id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Estado del pedido ${order.orderNumber} actualizado a '
            '${_statuses[status] ?? status}.',
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pedidos',
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
                title: 'Pedidos de todos los usuarios',
                subtitle:
                    '$_totalCompras compra(s) · $_totalPedidos producto(s) en total',
              ),
              AdminBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearch(),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 70),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      ErrorRetry(message: _error!, onRetry: _load)
                    else if (_orders.isEmpty)
                      AdminEmptyState(
                        message: _query.isEmpty
                            ? 'No hay pedidos registrados aún.'
                            : 'No se encontraron pedidos para "$_query".',
                        icon: Icons.receipt_long_outlined,
                      )
                    else
                      for (final order in _orders)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildOrder(order),
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
          hintText: 'Buscar por usuario o email...',
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
                backgroundColor: AppColors.primary,
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
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildOrder(AdminOrderItem order) {
    final chip = orderStatusChip(order.status);
    final date = DateFormat('dd/MM/yyyy hh:mm a').format(order.date);
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
                  color: AppColors.infoContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.info,
                  size: 21,
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
                            order.orderNumber,
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        AdminBadge(
                          text: chip.text,
                          foreground: chip.foreground,
                          background: chip.background,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.buyerName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${order.buyerUsername} · ${order.buyerEmail}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${order.itemsCount} producto(s) · '
                  '${Formatters.formatCurrency(order.total)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (order.recipientPhone.isNotEmpty)
                  Text(
                    'Tel: ${order.recipientPhone}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                if (order.shippingAddress.isNotEmpty)
                  Text(
                    'Envío: ${order.shippingAddress}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 4),
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                'Ver productos del pedido',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
              children: [
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity} × ${item.productName}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(item.subtotal),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Estado del pedido:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statuses.containsKey(order.status)
                          ? order.status
                          : 'pendiente',
                      isExpanded: true,
                      icon: const Icon(Icons.expand_more_rounded, size: 19),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                      items: [
                        for (final entry in _statuses.entries)
                          DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) _changeStatus(order, value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
