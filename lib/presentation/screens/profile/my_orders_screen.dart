import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/order_model.dart';
import '../../../providers/shop_provider.dart';
import '../../widgets/error_retry.dart';
import '../navigation/main_navigation_screen.dart';
import '../shop/invoice_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ShopProvider>().loadOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();
    final orders = provider.orders;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroStack(context, orders, provider),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 64),
                  child: _buildContent(provider, orders),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStack(
    BuildContext context,
    List<OrderModel> orders,
    ShopProvider provider,
  ) {
    final units = orders.fold<int>(
      0,
      (sum, order) =>
          sum + order.items.fold<int>(0, (inner, item) => inner + item.quantity),
    );
    final total = orders.fold<double>(0, (sum, order) => sum + order.total);
    final active = orders
        .where((order) => order.status.toLowerCase() != 'entregado')
        .length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildHero(context),
        Positioned(
          left: 0,
          right: 0,
          bottom: -34,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _buildStats(
                  totalOrders: orders.length,
                  totalSpent: total,
                  active: active,
                  units: units,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
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
            Positioned(
              top: -150,
              right: -100,
              child: _circle(400),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _circle(300),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 62, 20, 76),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.34),
                          ),
                        ),
                        child: Text(
                          'TU HISTORIAL DE COMPRAS',
                          style: GoogleFonts.poppins(
                            fontSize: 11.84,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      Text(
                        'Mis Pedidos',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize:
                              (MediaQuery.of(context).size.width * 0.045)
                                  .clamp(32.0, 44.8),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          'Revisa el estado de tus compras, los productos de cada pedido y descarga tus facturas.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16.64,
                            height: 1.6,
                            color: Colors.white.withOpacity(0.96),
                          ),
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
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStats({
    required int totalOrders,
    required double totalSpent,
    required int active,
    required int units,
  }) {
    final stats = [
      (
        Icons.receipt_long_outlined,
        '$totalOrders',
        totalOrders == 1 ? 'pedido' : 'pedidos',
        const Color(0xFFE0F5FE),
        const Color(0xFF0284C7),
      ),
      (
        Icons.credit_card_outlined,
        Formatters.formatCurrency(totalSpent),
        'total invertido',
        const Color(0xFFFFE4EF),
        const Color(0xFFDB2777),
      ),
      (
        Icons.local_shipping_outlined,
        '$active',
        'en proceso',
        const Color(0xFFFEF3C7),
        const Color(0xFFB45309),
      ),
      (
        Icons.check_rounded,
        '$units',
        units == 1 ? 'unidad comprada' : 'unidades compradas',
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + 14) / (180 + 14)).floor().clamp(1, 4);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 82,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFEDF1F6)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x170F172A),
                    blurRadius: 32,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: stat.$4,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(stat.$1, color: stat.$5, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 18.56,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            height: 1.15,
                          ),
                        ),
                        Text(
                          stat.$3.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.68,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.45,
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
        );
      },
    );
  }

  Widget _buildContent(ShopProvider provider, List<OrderModel> orders) {
    if (provider.ordersLoading && orders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 90),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.ordersErrorMessage != null && orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 90),
        child: ErrorRetry(
          message: provider.ordersErrorMessage!,
          onRetry: provider.loadOrders,
        ),
      );
    }
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 90),
        child: _buildEmpty(),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 62),
        ...orders.map((order) => _orderCard(order)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFD6EFFB)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 19,
                color: Color(0xFF1BA0D1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'La factura PDF es la misma copia que enviamos a tu correo al confirmar la compra.',
                  style: GoogleFonts.poppins(
                    fontSize: 13.12,
                    color: const Color(0xFF547081),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Column(
        children: [
          Container(
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
            child: const Text('🛍️', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 24),
          Text(
            'Aún no tienes pedidos',
            style: GoogleFonts.poppins(
              fontSize: 21.6,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando compres en la tienda, tus pedidos y facturas quedarán guardados aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 24),
          _gradientButton(
            text: 'Explorar la tienda',
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen(initialIndex: 3),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _orderCard(OrderModel order) {
    final status = order.status.toLowerCase();
    final statusLabel = _statusLabel(status);
    final isPending = status == 'pendiente';
    final isDelivered = status == 'entregado';
    final badgeBg = isPending
        ? const Color(0xFFFEF9C3)
        : isDelivered
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFE0F2FE);
    final badgeFg = isPending
        ? const Color(0xFF854D0E)
        : isDelivered
            ? const Color(0xFF166534)
            : const Color(0xFF0369A1);
    final date = DateFormat('d MMM y', 'es').format(order.date);
    final time = DateFormat('h:mm a', 'es').format(order.date);
    final count = order.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9EFF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFBFDFF), Color(0xFFF4FBFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0F4F8)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
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
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido ${order.orderNumber}',
                        style: GoogleFonts.poppins(
                          fontSize: 15.36,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '$date · $time · $count producto${count == 1 ? '' : 's'}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.48,
                          color: const Color(0xFF8A96A3),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL',
                      style: GoogleFonts.poppins(
                        fontSize: 10.72,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: const Color(0xFF9AA5B1),
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(order.total),
                      style: GoogleFonts.poppins(
                        fontSize: 21.12,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1BA0D1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF3F6FA)),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ESTADO DEL PEDIDO',
                        style: GoogleFonts.poppins(
                          fontSize: 11.52,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: const Color(0xFF7D8997),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 11.52,
                          fontWeight: FontWeight.w800,
                          color: badgeFg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(4, (index) {
                    final active = order.statusStep >= index + 1;
                    final labels = [
                      'Pendiente',
                      'Confirmado',
                      'Enviado',
                      'Entregado',
                    ];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == 3 ? 0 : 5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: active
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF27BEF5),
                                          Color(0xFF6DD5FA),
                                        ],
                                      )
                                    : null,
                                color: active
                                    ? null
                                    : const Color(0xFFE8EDF3),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              labels[index],
                              style: GoogleFonts.poppins(
                                fontSize: 10.4,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? const Color(0xFF546474)
                                    : const Color(0xFFA1ACB8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: order.items.map((item) => _itemRow(item, statusLabel)).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFCFE),
              border: Border(top: BorderSide(color: Color(0xFFF0F4F8))),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 15,
                  color: Color(0xFF93A0AD),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Factura disponible en PDF',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF93A0AD),
                    ),
                  ),
                ),
                Material(
                  color: const Color(0xFFEAF9FF),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => InvoiceScreen(order: order),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFC9EEFC)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Ver factura PDF',
                        style: GoogleFonts.poppins(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1BA0D1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(CartItemModel item, String statusLabel) {
    final imageUrl = item.product.imageUrl;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F6FA))),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFE8EDF3)),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF9DB8C8),
                    ),
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF9DB8C8),
                  ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.4,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${item.quantity} × ${Formatters.formatCurrency(item.product.price)} · $statusLabel',
                  style: GoogleFonts.poppins(
                    fontSize: 12.16,
                    color: const Color(0xFF8B97A4),
                  ),
                ),
                if (item.address.isNotEmpty)
                  Text(
                    'Envío: ${item.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.68,
                      color: const Color(0xFFA2ACB8),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            Formatters.formatCurrency(item.totalPrice),
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmado':
        return 'Confirmado';
      case 'enviado':
        return 'Enviado';
      case 'entregado':
        return 'Entregado';
      default:
        return 'Pendiente';
    }
  }

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
}
