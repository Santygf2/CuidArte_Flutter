import 'package:flutter_test/flutter_test.dart';
import 'package:cuidarte_app/models/caregiver_model.dart';
import 'package:cuidarte_app/models/product_model.dart';
import 'package:cuidarte_app/models/user_role.dart';
import 'package:cuidarte_app/models/visit_model.dart';
import 'package:cuidarte_app/models/workshop_model.dart';
import 'package:cuidarte_app/providers/auth_provider.dart';
import 'package:cuidarte_app/providers/shop_provider.dart';

void main() {
  group('CuidArte modelos y estado', () {
    test('AuthProvider inicia sin sesión hasta restaurar el token', () {
      final auth = AuthProvider();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser, isNull);
      expect(auth.status, AuthStatus.unknown);
      expect(auth.currentRole, UserRole.client);
    });

    test('ProductModel interpreta la respuesta de la API', () {
      final product = ProductModel.fromJson({
        'id': 7,
        'name': 'Tensiómetro digital',
        'description': 'Equipo de medición',
        'category': 'Dispositivos Biomédicos',
        'price': 120000,
        'stock': 5,
        'rating': 4.8,
        'reviews_count': 0,
        'image_url': 'https://example.com/producto.png',
        'is_featured': true,
        'features': [],
      });

      expect(product.id, '7');
      expect(product.name, 'Tensiómetro digital');
      expect(product.price, 120000);
      expect(product.stock, 5);
      expect(product.isFeatured, isTrue);
      expect(product.inStock, isTrue);
    });

    test('CaregiverModel interpreta especialidades y verificación', () {
      final caregiver = CaregiverModel.fromJson({
        'id': 3,
        'name': 'Carlos Pérez',
        'email': 'carlos@example.com',
        'phone': '3001234567',
        'city': 'Bogotá',
        'address': 'Bogotá',
        'cedula': '12345678',
        'experience_years': 8,
        'rating': 0,
        'review_count': 0,
        'specialties': ['Geriatría'],
        'is_verified': true,
        'bio': 'Atención domiciliaria durante 8 años.',
        'hourly_rate': 0,
        'avatar_url': 'https://example.com/avatar.png',
        'certifications': ['Cédula y antecedentes verificados'],
        'is_available': true,
      });

      expect(caregiver.name, 'Carlos Pérez');
      expect(caregiver.experienceYears, 8);
      expect(caregiver.specialties, ['Geriatría']);
      expect(caregiver.hasReviews, isFalse);
      expect(caregiver.isVerified, isTrue);
      expect(caregiver.isAvailable, isTrue);
    });

    test('VisitModel interpreta fecha, horario y estado', () {
      final visit = VisitModel.fromJson({
        'id': 12,
        'caregiver_id': 3,
        'caregiver_name': 'Carlos Pérez',
        'caregiver_specialty': 'Geriatría',
        'caregiver_avatar': 'https://example.com/avatar.png',
        'caregiver_phone': '3001234567',
        'client_id': 1,
        'client_name': 'María Gómez',
        'client_address': 'Bogotá',
        'client_phone': '3109876543',
        'elderly_condition': 'Valoración preventiva',
        'date': '2026-10-28',
        'time': '09:00',
        'time_slot': '09:00 - 10:00',
        'status': 'aceptada',
        'status_label': 'Aceptada',
        'notes': 'Primera valoración',
        'is_free_initial_visit': true,
      });

      expect(visit.caregiverName, 'Carlos Pérez');
      expect(visit.timeSlot, '09:00 - 10:00');
      expect(visit.status, 'Aceptada');
      expect(visit.date.year, 2026);
      expect(visit.isFreeInitialVisit, isTrue);
    });

    test('WorkshopModel interpreta cupos e inscripción', () {
      final workshop = WorkshopModel.fromJson({
        'id': 4,
        'title': 'Memoria activa',
        'description': 'Ejercicios cognitivos',
        'modality': 'Virtual',
        'date': '2026-10-30',
        'time': '10:00',
        'available_slots': 7,
        'total_slots': 20,
        'instructor': 'Equipo CuidArte',
        'instructor_role': 'Bienestar y salud',
        'image_url': 'https://example.com/taller.png',
        'location_or_link': 'Virtual (en línea)',
        'price': 0,
        'is_enrolled': true,
        'enrollment_id': 9,
      });

      expect(workshop.title, 'Memoria activa');
      expect(workshop.modality, 'Virtual');
      expect(workshop.availableSlots, 7);
      expect(workshop.isEnrolled, isTrue);
      expect(workshop.enrollmentId, '9');
    });

    test('ShopProvider gestiona cantidades y subtotales del carrito', () {
      final shop = ShopProvider();
      final product = ProductModel(
        id: '1',
        name: 'Tensiómetro',
        description: 'Equipo',
        category: 'Dispositivos Biomédicos',
        price: 120000,
        stock: 5,
        rating: 4.8,
        reviewsCount: 0,
        imageUrl: '',
      );

      shop.addToCart(product);
      expect(shop.cartCount, 1);
      expect(shop.subtotal, 120000);
      expect(shop.total, 120000);

      shop.updateQuantity(product.id, 2);
      expect(shop.cartCount, 2);
      expect(shop.subtotal, 240000);

      shop.removeFromCart(product.id);
      expect(shop.cartCount, 0);
      expect(shop.subtotal, 0);
    });
  });
}
