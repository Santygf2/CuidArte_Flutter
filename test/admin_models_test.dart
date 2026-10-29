import 'package:cuidarte_app/models/admin_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Modelos del panel administrador', () {
    test('AdminDashboardStats interpreta los totales', () {
      final stats = AdminDashboardStats.fromJson({
        'total_usuarios': 12,
        'total_usuarios_deshabilitados': 2,
        'total_cuidadores': 8,
        'total_cuidadores_deshabilitados': 1,
        'total_servicios': 5,
        'total_productos': 9,
        'total_mensajes': 4,
        'total_especialidades': 6,
        'total_pedidos_compra': 3,
        'total_pedidos_items': 7,
        'total_talleres': 5,
        'total_recursos': 11,
      });

      expect(stats.totalUsuarios, 12);
      expect(stats.totalUsuariosDeshabilitados, 2);
      expect(stats.totalCuidadores, 8);
      expect(stats.totalPedidosCompra, 3);
      expect(stats.totalPedidosItems, 7);
      expect(stats.totalRecursos, 11);
    });

    test('AdminUserItem interpreta perfil de cuidador', () {
      final user = AdminUserItem.fromJson({
        'id': 4,
        'username': 'cuidador_admin',
        'email': 'cuidador@example.com',
        'first_name': 'Carlos',
        'last_name': 'Pérez',
        'full_name': 'Carlos Pérez',
        'role': 'cuidador',
        'is_active': false,
        'date_joined': '2026-01-15T10:00:00Z',
        'perfil': {
          'tipo_usuario': 'cuidador',
          'telefono': '3111234567',
          'direccion': 'Bogotá',
          'cedula': '12345678',
          'especialidades': 'Geriatría',
          'foto': '',
        },
      });

      expect(user.fullName, 'Carlos Pérez');
      expect(user.isCaregiver, isTrue);
      expect(user.isActive, isFalse);
      expect(user.cedula, '12345678');
      expect(user.specialties, 'Geriatría');
      expect(user.initials, 'CP');
    });

    test('AdminOrderItem interpreta comprador y productos', () {
      final order = AdminOrderItem.fromJson({
        'id': 'uuid-compra',
        'order_number': '#ABC12345',
        'date': '2026-02-01T12:30:00Z',
        'total': 240000,
        'status': 'enviado',
        'status_display': 'Enviado',
        'recipient_name': 'María Gómez',
        'buyer_username': 'cliente_admin',
        'buyer_email': 'cliente@example.com',
        'recipient_phone': '3001234567',
        'shipping_address': 'Calle 1 # 2-3',
        'items_count': 1,
        'items': [
          {
            'quantity': 2,
            'subtotal': 240000,
            'address': 'Calle 1 # 2-3',
            'product': {'name': 'Tensiómetro digital', 'image_url': ''},
          },
        ],
      });

      expect(order.buyerName, 'María Gómez');
      expect(order.buyerUsername, 'cliente_admin');
      expect(order.status, 'enviado');
      expect(order.itemsCount, 1);
      expect(order.items.first.productName, 'Tensiómetro digital');
      expect(order.items.first.quantity, 2);
    });

    test('AdminMessageItem interpreta el asunto legible', () {
      final message = AdminMessageItem.fromJson({
        'id': 3,
        'nombre': 'Laura',
        'apellido': 'Díaz',
        'correo': 'laura@example.com',
        'telefono': '3101234567',
        'ciudad': 'Cali',
        'asunto': 'servicios',
        'asunto_display': 'Servicios',
        'mensaje': 'Necesito información.',
        'fecha': '2026-02-02T09:00:00Z',
        'leido': false,
      });

      expect(message.fullName, 'Laura Díaz');
      expect(message.asuntoDisplay, 'Servicios');
      expect(message.leido, isFalse);
    });
  });
}
