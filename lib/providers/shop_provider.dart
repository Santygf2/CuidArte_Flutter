import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class ShopProvider extends ChangeNotifier {
  ShopProvider({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  List<ProductModel> _products = [];
  final Map<String, CartItemModel> _cartItems = {};
  final List<OrderModel> _orders = [];
  String _selectedCategory = 'Todas';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _loaded = false;
  bool _ordersLoading = false;
  bool _ordersLoaded = false;
  String? _errorMessage;
  String? _ordersErrorMessage;

  List<ProductModel> get products => _products;
  Map<String, CartItemModel> get cartItems => _cartItems;
  List<CartItemModel> get cartList => _cartItems.values.toList();
  List<OrderModel> get orders => _orders;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _loaded;
  bool get ordersLoading => _ordersLoading;
  bool get ordersLoaded => _ordersLoaded;
  String? get errorMessage => _errorMessage;
  String? get ordersErrorMessage => _ordersErrorMessage;

  int get cartCount =>
      _cartItems.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _cartItems.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get shippingFee => 0.0;

  double get total => subtotal + shippingFee;

  List<String> get categories => [
    'Todas',
    'Dispositivos Biomédicos',
    'Suministros Médicos',
    'Movilidad y Ortopedia',
    'Cuidado Personal',
    'Otros',
  ];

  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Todas' || product.category == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<ProductModel> get featuredProducts {
    final destacados = _products
        .where((product) => product.isFeatured)
        .toList();
    if (destacados.isEmpty) {
      return _products.take(4).toList();
    }
    return destacados;
  }

  Future<void> ensureLoaded() async {
    await Future.wait([loadProducts(), loadOrders()]);
  }

  Future<void> loadProducts() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.get('/products/');
      final list = _extractList(data);
      _products = list
          .map(
            (item) =>
                ProductModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
      _loaded = true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar los productos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    if (_ordersLoading) {
      return;
    }
    _ordersLoading = true;
    _ordersErrorMessage = null;
    notifyListeners();

    try {
      final data = await _api.get('/orders/');
      final list = _extractList(data);
      _orders
        ..clear()
        ..addAll(
          list.map(
            (item) =>
                OrderModel.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
      _ordersLoaded = true;
    } on ApiException catch (error) {
      _ordersErrorMessage = error.message;
    } catch (_) {
      _ordersErrorMessage = 'No se pudieron cargar tus pedidos.';
    } finally {
      _ordersLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addToCart(ProductModel product, {int quantity = 1}) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems[product.id]!.quantity += quantity;
    } else {
      _cartItems[product.id] = CartItemModel(
        product: product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (_cartItems.containsKey(productId)) {
      if (newQuantity <= 0) {
        _cartItems.remove(productId);
      } else {
        _cartItems[productId]!.quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<OrderModel> checkout({
    required String recipientName,
    required String recipientPhone,
    required String shippingAddress,
    required String city,
    required String paymentMethod,
    String notes = '',
    String email = '',
  }) async {
    if (_cartItems.isEmpty) {
      throw ApiException(null, 'Tu carrito está vacío.');
    }

    final data = await _api.post(
      '/orders/',
      body: {
        'items': _cartItems.values
            .map(
              (item) => {
                'product_id': int.tryParse(item.product.id) ?? item.product.id,
                'quantity': item.quantity,
              },
            )
            .toList(),
        'recipient_name': recipientName,
        'phone': recipientPhone,
        'email': email.trim(),
        'address': shippingAddress,
        'city': city,
        'payment_method': paymentMethod,
        'notes': notes,
      },
    );

    final order = OrderModel.fromJson(Map<String, dynamic>.from(data as Map));
    _orders.insert(0, order);
    _cartItems.clear();
    notifyListeners();
    return order;
  }

  void reset() {
    _products = [];
    _cartItems.clear();
    _orders.clear();
    _selectedCategory = 'Todas';
    _searchQuery = '';
    _isLoading = false;
    _loaded = false;
    _ordersLoading = false;
    _ordersLoaded = false;
    _errorMessage = null;
    _ordersErrorMessage = null;
    notifyListeners();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    }
    if (data is Map && data['results'] is List) {
      return data['results'] as List;
    }
    return const [];
  }
}
