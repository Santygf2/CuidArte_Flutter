import '../core/network/api_client.dart';

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalUsuarios,
    required this.totalUsuariosDeshabilitados,
    required this.totalCuidadores,
    required this.totalCuidadoresDeshabilitados,
    required this.totalServicios,
    required this.totalProductos,
    required this.totalMensajes,
    required this.totalEspecialidades,
    required this.totalPedidosCompra,
    required this.totalPedidosItems,
    required this.totalTalleres,
    required this.totalRecursos,
  });

  final int totalUsuarios;
  final int totalUsuariosDeshabilitados;
  final int totalCuidadores;
  final int totalCuidadoresDeshabilitados;
  final int totalServicios;
  final int totalProductos;
  final int totalMensajes;
  final int totalEspecialidades;
  final int totalPedidosCompra;
  final int totalPedidosItems;
  final int totalTalleres;
  final int totalRecursos;

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    int value(String key) => (json[key] as num?)?.toInt() ?? 0;
    return AdminDashboardStats(
      totalUsuarios: value('total_usuarios'),
      totalUsuariosDeshabilitados: value('total_usuarios_deshabilitados'),
      totalCuidadores: value('total_cuidadores'),
      totalCuidadoresDeshabilitados: value('total_cuidadores_deshabilitados'),
      totalServicios: value('total_servicios'),
      totalProductos: value('total_productos'),
      totalMensajes: value('total_mensajes'),
      totalEspecialidades: value('total_especialidades'),
      totalPedidosCompra: value('total_pedidos_compra'),
      totalPedidosItems: value('total_pedidos_items'),
      totalTalleres: value('total_talleres'),
      totalRecursos: value('total_recursos'),
    );
  }
}

class AdminUserItem {
  const AdminUserItem({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.isActive,
    required this.cedula,
    required this.specialties,
    required this.experience,
    required this.avatarUrl,
    required this.dateJoined,
  });

  final int id;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String role;
  final bool isActive;
  final String cedula;
  final String specialties;
  final String experience;
  final String? avatarUrl;
  final DateTime? dateJoined;

  bool get isCaregiver => role == 'cuidador';

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    final perfilRaw = json['perfil'];
    final perfil = perfilRaw is Map
        ? Map<String, dynamic>.from(perfilRaw)
        : const <String, dynamic>{};
    final role = (json['role'] ?? perfil['tipo_usuario'] ?? 'cliente')
        .toString();
    final firstName = (json['first_name'] ?? perfil['nombre'] ?? '')
        .toString()
        .trim();
    final lastName = (json['last_name'] ?? perfil['apellido'] ?? '')
        .toString()
        .trim();
    final fullName = (json['full_name'] ?? '$firstName $lastName')
        .toString()
        .trim();
    final avatar = ApiClient.resolveUrl(
      (perfil['foto'] ?? '').toString().trim(),
    );
    return AdminUserItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: (json['username'] ?? '').toString(),
      fullName: fullName.isEmpty
          ? (json['username'] ?? 'Usuario').toString()
          : fullName,
      email: (json['email'] ?? perfil['correo'] ?? '').toString(),
      phone: (perfil['telefono'] ?? '').toString(),
      address: (perfil['direccion'] ?? '').toString(),
      role: role,
      isActive: json['is_active'] == true,
      cedula: (perfil['cedula'] ?? '').toString(),
      specialties: (perfil['especialidades'] ?? '').toString(),
      experience: (perfil['experiencia'] ?? '').toString(),
      avatarUrl: avatar.isEmpty ? null : avatar,
      dateJoined: DateTime.tryParse((json['date_joined'] ?? '').toString()),
    );
  }
}

class AdminUsersPage {
  const AdminUsersPage({
    required this.items,
    required this.activeCount,
    required this.disabledCount,
    required this.allCount,
  });

  final List<AdminUserItem> items;
  final int activeCount;
  final int disabledCount;
  final int allCount;
}

class AdminOrdersPage {
  const AdminOrdersPage({
    required this.items,
    required this.totalCompras,
    required this.totalPedidos,
  });

  final List<AdminOrderItem> items;
  final int totalCompras;
  final int totalPedidos;
}

class AdminMessageItem {
  const AdminMessageItem({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.ciudad,
    required this.asunto,
    required this.asuntoDisplay,
    required this.mensaje,
    required this.fecha,
    required this.leido,
  });

  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String ciudad;
  final String asunto;
  final String asuntoDisplay;
  final String mensaje;
  final DateTime fecha;
  final bool leido;

  String get fullName => '$nombre $apellido'.trim();

  factory AdminMessageItem.fromJson(Map<String, dynamic> json) {
    return AdminMessageItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      apellido: (json['apellido'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      ciudad: (json['ciudad'] ?? '').toString(),
      asunto: (json['asunto'] ?? '').toString(),
      asuntoDisplay: (json['asunto_display'] ?? json['asunto'] ?? '')
          .toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      fecha:
          DateTime.tryParse((json['fecha'] ?? '').toString()) ?? DateTime.now(),
      leido: json['leido'] == true,
    );
  }
}

class AdminOrderLine {
  const AdminOrderLine({
    required this.productName,
    required this.quantity,
    required this.subtotal,
    required this.address,
    required this.imageUrl,
  });

  final String productName;
  final int quantity;
  final double subtotal;
  final String address;
  final String imageUrl;
}

class AdminOrderItem {
  const AdminOrderItem({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.total,
    required this.status,
    required this.statusDisplay,
    required this.buyerName,
    required this.buyerUsername,
    required this.buyerEmail,
    required this.recipientPhone,
    required this.shippingAddress,
    required this.itemsCount,
    required this.items,
  });

  final String id;
  final String orderNumber;
  final DateTime date;
  final double total;
  final String status;
  final String statusDisplay;
  final String buyerName;
  final String buyerUsername;
  final String buyerEmail;
  final String recipientPhone;
  final String shippingAddress;
  final int itemsCount;
  final List<AdminOrderLine> items;

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    final items = <AdminOrderLine>[];
    final rawItems = json['items'];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is! Map) continue;
        final data = Map<String, dynamic>.from(item);
        final productRaw = data['product'];
        final product = productRaw is Map
            ? Map<String, dynamic>.from(productRaw)
            : const <String, dynamic>{};
        items.add(
          AdminOrderLine(
            productName: (product['name'] ?? product['titulo'] ?? 'Producto')
                .toString(),
            quantity: (data['quantity'] as num?)?.toInt() ?? 1,
            subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
            address: (data['address'] ?? '').toString(),
            imageUrl: ApiClient.resolveUrl(
              (product['image_url'] ?? '').toString(),
            ),
          ),
        );
      }
    }
    return AdminOrderItem(
      id: (json['id'] ?? '').toString(),
      orderNumber: (json['order_number'] ?? '').toString(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: (json['status'] ?? 'pendiente').toString(),
      statusDisplay: (json['status_display'] ?? json['status'] ?? 'Pendiente')
          .toString(),
      buyerName: (json['recipient_name'] ?? '').toString(),
      buyerUsername: (json['buyer_username'] ?? '').toString(),
      buyerEmail: (json['buyer_email'] ?? json['recipient_email'] ?? '')
          .toString(),
      recipientPhone: (json['recipient_phone'] ?? '').toString(),
      shippingAddress: (json['shipping_address'] ?? '').toString(),
      itemsCount: (json['items_count'] as num?)?.toInt() ?? items.length,
      items: items,
    );
  }
}
