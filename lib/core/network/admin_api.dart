import '../../models/admin_models.dart';
import 'api_client.dart';

class AdminApi {
  AdminApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AdminDashboardStats> dashboard() async {
    final data = await _client.get('/admin/dashboard/');
    return AdminDashboardStats.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<AdminUsersPage> users({
    required String tipo,
    required String estado,
    String q = '',
  }) async {
    final params = <String, String>{'type': tipo, 'estado': estado};
    if (q.trim().isNotEmpty) {
      params['q'] = q.trim();
    }
    final query = params.entries
        .map((entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');
    final data = await _client.get('/admin/users/?$query');
    final map = Map<String, dynamic>.from(data as Map);
    final results = map['results'];
    final items = <AdminUserItem>[];
    if (results is List) {
      for (final item in results) {
        if (item is Map) {
          items.add(AdminUserItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return AdminUsersPage(
      items: items,
      activeCount: (map['conteo_activos'] as num?)?.toInt() ?? 0,
      disabledCount: (map['conteo_deshabilitados'] as num?)?.toInt() ?? 0,
      allCount: (map['conteo_todos'] as num?)?.toInt() ?? 0,
    );
  }

  Future<String> setUserActive(
    int userId, {
    required bool active,
    String? motivo,
  }) async {
    final action = active ? 'activate' : 'disable';
    final data = await _client.post(
      '/admin/users/$userId/$action/',
      body: motivo == null ? const <String, dynamic>{} : {'motivo': motivo},
    );
    final map = Map<String, dynamic>.from(data as Map);
    return (map['detail'] ?? 'Cuenta actualizada.').toString();
  }

  Future<AdminOrdersPage> orders({String q = ''}) async {
    final query = q.trim().isEmpty
        ? ''
        : '?q=${Uri.encodeQueryComponent(q.trim())}';
    final data = await _client.get('/admin/orders/$query');
    final map = Map<String, dynamic>.from(data as Map);
    final results = map['results'];
    final items = <AdminOrderItem>[];
    if (results is List) {
      for (final item in results) {
        if (item is Map) {
          items.add(AdminOrderItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return AdminOrdersPage(
      items: items,
      totalCompras: (map['total_compras'] as num?)?.toInt() ?? 0,
      totalPedidos: (map['total_pedidos'] as num?)?.toInt() ?? 0,
    );
  }

  Future<AdminOrderItem> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    final data = await _client.patch(
      '/admin/orders/$orderId/status/',
      body: {'status': status},
    );
    return AdminOrderItem.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<AdminMessageItem>> messages() async {
    final data = await _client.get('/admin/messages/');
    final list = data is List
        ? data
        : (data is Map && data['results'] is List
              ? data['results'] as List
              : const <dynamic>[]);
    return list
        .whereType<Map>()
        .map(
          (item) => AdminMessageItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> markMessageRead(int id) async {
    await _client.post(
      '/admin/messages/$id/read/',
      body: const <String, dynamic>{},
    );
  }

  Future<void> deleteMessage(int id) async {
    await _client.delete('/admin/messages/$id/');
  }

  Future<Map<String, dynamic>> profile() async {
    final data = await _client.get('/admin/profile/');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final data = await _client.patch('/admin/profile/', body: body);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> records(
    String endpoint, {
    String? query,
  }) async {
    final suffix = query == null || query.isEmpty ? '' : '?$query';
    final data = await _client.get('$endpoint$suffix');
    final list = data is List
        ? data
        : (data is Map && data['results'] is List
              ? data['results'] as List
              : const <dynamic>[]);
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> createRecord(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.post(endpoint, body: body);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> updateRecord(
    String endpoint,
    int id,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.patch('$endpoint$id/', body: body);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> deleteRecord(String endpoint, int id) async {
    await _client.delete('$endpoint$id/');
  }
}
