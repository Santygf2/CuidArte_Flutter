import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  final String address;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.address = '',
  });

  double get totalPrice => product.price * quantity;
}
