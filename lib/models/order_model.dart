import 'cart_item_model.dart';
import 'product_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final DateTime date;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final String recipientName;
  final String recipientPhone;
  final String recipientEmail;
  final String shippingAddress;
  final String city;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final int statusStep;
  final String qrCodeData;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    this.discount = 0.0,
    required this.total,
    required this.recipientName,
    required this.recipientPhone,
    this.recipientEmail = '',
    required this.shippingAddress,
    required this.city,
    required this.paymentMethod,
    this.paymentStatus = 'Aprobado',
    this.status = 'pendiente',
    this.statusStep = 1,
    required this.qrCodeData,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final items = <CartItemModel>[];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is Map) {
          final data = Map<String, dynamic>.from(item);
          final productRaw = data['product'];
          if (productRaw is Map) {
            items.add(
              CartItemModel(
                product: ProductModel.fromJson(
                  Map<String, dynamic>.from(productRaw),
                ),
                quantity: (data['quantity'] as num?)?.toInt() ?? 1,
                address: (data['address'] ?? '').toString(),
              ),
            );
          }
        }
      }
    }

    return OrderModel(
      id: (json['id'] ?? '').toString(),
      orderNumber: (json['order_number'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ??
          DateTime.now(),
      items: items,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      recipientName: (json['recipient_name'] ?? '').toString(),
      recipientPhone: (json['recipient_phone'] ?? '').toString(),
      recipientEmail: (json['recipient_email'] ?? '').toString(),
      shippingAddress: (json['shipping_address'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      paymentMethod: (json['payment_method'] ?? '').toString(),
      paymentStatus: (json['payment_status'] ?? 'Pendiente').toString(),
      status: (json['status'] ?? 'pendiente').toString(),
      statusStep: (json['status_step'] as num?)?.toInt() ?? 1,
      qrCodeData: (json['qr_code_data'] ?? '').toString(),
    );
  }
}
