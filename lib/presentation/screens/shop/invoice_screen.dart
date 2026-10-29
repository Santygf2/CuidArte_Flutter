import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/url_opener.dart';
import '../../../models/order_model.dart';

class InvoiceScreen extends StatelessWidget {
  final OrderModel order;

  const InvoiceScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      "EEEE, d 'de' MMMM 'de' y — HH:mm",
      'es',
    ).format(order.date);
    final number = order.orderNumber;
    final total = Formatters.formatCurrency(order.total);
    final productCount = order.items.length;
    final pending = order.paymentStatus.toLowerCase() != 'aprobado';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Factura'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(
                  text:
                      'Factura CuidArte $number — Total $total — '
                      '${order.recipientName}',
                ),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Resumen de la factura copiado al portapapeles.',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () async {
              final abierto = await printCurrentPage();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    abierto
                        ? 'Abriendo el diálogo de impresión...'
                        : 'La impresión está disponible en la versión web.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(date, number, pending),
                    const SizedBox(height: 16),
                    _buildCustomerAndShipping(),
                    const SizedBox(height: 16),
                    _buildSummaryBar(productCount, number, total),
                    const SizedBox(height: 14),
                    _buildProductsTable(),
                    const SizedBox(height: 12),
                    _buildTotals(total, pending),
                    const SizedBox(height: 14),
                    _buildNoteAndQr(number),
                    const SizedBox(height: 16),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String date, String number, bool pending) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 560;
        final brand = Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: const BoxDecoration(
            color: Color(0xFF27BEF5),
            border: Border(
              left: BorderSide(color: Color(0xFFFF6B9D), width: 6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CuidArte',
                style: GoogleFonts.poppins(
                  fontSize: 29.3,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'CUIDADO Y BIENESTAR INTEGRAL',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: const Color(0xFFE0F7FF),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'cuidartesk@gmail.com  |  Bogotá, Colombia  |  www.cuidarte.com',
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
              ),
            ],
          ),
        );

        final invoiceHead = Column(
          crossAxisAlignment: wide
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              color: const Color(0xFF1F2937),
              child: Text(
                'FACTURA DE VENTA • DOCUMENTO OFICIAL',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Factura',
              style: GoogleFonts.poppins(
                fontSize: 25.3,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                border: Border.all(color: const Color(0xFF7DD3FC), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: GoogleFonts.poppins(
                      fontSize: 17.3,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: const Color(0xFF0369A1),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'CONSERVA ESTE NÚMERO PARA SOPORTE',
                    style: GoogleFonts.poppins(
                      fontSize: 9.3,
                      letterSpacing: 0.4,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$date · Bogotá (UTC-5)',
              textAlign: wide ? TextAlign.right : TextAlign.left,
              style: GoogleFonts.poppins(
                fontSize: 10.7,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                border: Border.all(color: const Color(0xFFFED7AA), width: 1.5),
              ),
              child: Text(
                pending
                    ? '● PENDIENTE — Pago contra entrega'
                    : '● PAGADA — Pago confirmado',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC2410C),
                ),
              ),
            ),
          ],
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 56, child: brand),
              const SizedBox(width: 16),
              Expanded(flex: 44, child: invoiceHead),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [brand, const SizedBox(height: 16), invoiceHead],
        );
      },
    );
  }

  Widget _buildCustomerAndShipping() {
    final customer = _dataBox(
      color: const Color(0xFF27BEF5),
      borderColor: const Color(0xFF27BEF5),
      title: '◆ Facturado a',
      children: [
        Text(
          order.recipientName,
          style: GoogleFonts.poppins(
            fontSize: 13.3,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '✉ ${order.recipientEmail}',
          style: GoogleFonts.poppins(
            fontSize: 12.7,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '☎ ${order.recipientPhone}',
          style: GoogleFonts.poppins(
            fontSize: 12.7,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Cliente verificado en CuidArte · Gracias por tu confianza',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );

    final shipping = _dataBox(
      color: const Color(0xFFFF6B9D),
      borderColor: const Color(0xFFFF6B9D),
      title: '◆ Envío',
      children: [
        Text(
          order.shippingAddress,
          style: GoogleFonts.poppins(
            fontSize: 12.7,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          const TextSpan(
            text: 'Entrega estimada: ',
            children: [
              TextSpan(
                text: '2-4 días hábiles',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: ' · Envío gratis · Cobertura nacional'),
            ],
          ),
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 560) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: customer),
              const SizedBox(width: 14),
              Expanded(child: shipping),
            ],
          );
        }
        return Column(
          children: [customer, const SizedBox(height: 14), shipping],
        );
      },
    );
  }

  Widget _dataBox({
    required Color color,
    required Color borderColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
          top: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          right: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          bottom: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: color,
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSummaryBar(int count, String number, String total) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1F2937),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 6,
        children: [
          _summaryItem('PRODUCTOS:', '$count'),
          _summaryItem('FACTURA:', number),
          _summaryItem('TOTAL:', total),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Text.rich(
      TextSpan(
        text: '$label ',
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF7DD3FC),
            ),
          ),
        ],
      ),
      style: GoogleFonts.poppins(
        fontSize: 10,
        letterSpacing: 0.6,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProductsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 680,
        child: Table(
          border: TableBorder.all(color: const Color(0xFFE5E7EB), width: 1.5),
          columnWidths: const {
            0: FixedColumnWidth(45),
            1: FlexColumnWidth(3),
            2: FixedColumnWidth(55),
            3: FixedColumnWidth(110),
            4: FixedColumnWidth(110),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF1F2937)),
              children: [
                _tableHeader('#', center: true),
                _tableHeader('Producto'),
                _tableHeader('Cant.', center: true),
                _tableHeader('Precio unit.', right: true),
                _tableHeader(
                  'Subtotal',
                  right: true,
                  background: const Color(0xFF27BEF5),
                ),
              ],
            ),
            ...List.generate(order.items.length, (index) {
              final item = order.items[index];
              final alternate = index % 2 == 0;
              return TableRow(
                decoration: BoxDecoration(
                  color: alternate ? const Color(0xFFF0F9FF) : Colors.white,
                ),
                children: [
                  _tableCell('${index + 1}', center: true),
                  _tableCell(
                    item.product.name,
                    bold: true,
                    color: const Color(0xFF1F2937),
                  ),
                  _tableCell('${item.quantity}', center: true),
                  _tableCell(
                    Formatters.formatCurrency(item.product.price),
                    right: true,
                  ),
                  _tableCell(
                    Formatters.formatCurrency(item.totalPrice),
                    right: true,
                    bold: true,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(
    String text, {
    bool center = false,
    bool right = false,
    Color background = const Color(0xFF1F2937),
  }) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text.toUpperCase(),
        textAlign: center
            ? TextAlign.center
            : right
            ? TextAlign.right
            : TextAlign.left,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _tableCell(
    String text, {
    bool center = false,
    bool right = false,
    bool bold = false,
    Color color = const Color(0xFF374151),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        textAlign: center
            ? TextAlign.center
            : right
            ? TextAlign.right
            : TextAlign.left,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTotals(String total, bool pending) {
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          const TextSpan(
            text: 'Método de pago: ',
            children: [
              TextSpan(
                text:
                    'Pago contra entrega (efectivo / transferencia al recibir)',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          style: GoogleFonts.poppins(
            fontSize: 10.7,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Precios en COP · IVA incluido donde aplica · Cambios dentro de 7 días con factura',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );

    final right = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Column(
        children: [
          _totalRow('Subtotal', total),
          const SizedBox(height: 4),
          _totalRow('Envío', 'GRATIS', valueColor: const Color(0xFF059669)),
          const SizedBox(height: 4),
          _totalRow('Descuento', '—'),
          const SizedBox(height: 8),
          Container(
            color: const Color(0xFF27BEF5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'TOTAL A PAGAR',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      total,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'COP · Pesos colombianos',
                    style: GoogleFonts.poppins(
                      fontSize: 9.3,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              pending
                  ? 'Factura válida como comprobante oficial'
                  : 'Factura pagada correctamente',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 560) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 54, child: left),
              const SizedBox(width: 12),
              Expanded(flex: 46, child: right),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, const SizedBox(height: 12), right],
        );
      },
    );
  }

  Widget _totalRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteAndQr(String number) {
    final note = Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF7ED),
        border: Border(
          left: BorderSide(color: Color(0xFFF59E0B), width: 5),
          top: BorderSide(color: Color(0xFFFED7AA), width: 1.5),
          right: BorderSide(color: Color(0xFFFED7AA), width: 1.5),
          bottom: BorderSide(color: Color(0xFFFED7AA), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ⓘ IMPORTANTE — CONSERVA ESTA FACTURA',
            style: GoogleFonts.poppins(
              fontSize: 10.7,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: const Color(0xFFC2410C),
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: 'Presenta el número ',
              children: [
                TextSpan(
                  text: number,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(
                  text: ' en Mis Pedidos para ver el estado o contactar soporte. El repartidor validará este documento al entregar. ¿Dudas? Escríbenos a ',
                ),
                const TextSpan(
                  text: 'cuidartesk@gmail.com',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '.'),
              ],
            ),
            style: GoogleFonts.poppins(
              fontSize: 10.7,
              height: 1.5,
              color: const Color(0xFF7C2D12),
            ),
          ),
        ],
      ),
    );

    final qr = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          ),
          child: QrImageView(
            data: order.qrCodeData,
            version: QrVersions.auto,
            size: 90,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 120,
          child: Text(
            order.id,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 8.7,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'ESCANEA PARA VALIDAR',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 560) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 68, child: note),
              const SizedBox(width: 12),
              SizedBox(width: 150, child: qr),
            ],
          );
        }
        return Column(children: [note, const SizedBox(height: 14), qr]);
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1F2937),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          Text(
            '¡Gracias por confiar en CuidArte! ♡',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.3,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: const Color(0xFF7DD3FC),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tu compra ayuda a seguir cuidando a quienes más lo necesitan. Te avisaremos cuando tu pedido sea enviado.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.7,
              color: const Color(0xFFD1D5DB),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'CuidArte — Cuidado y bienestar integral para adultos mayores • cuidartesk@gmail.com • Bogotá, Colombia • Documento generado automáticamente y no requiere firma',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.3,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
