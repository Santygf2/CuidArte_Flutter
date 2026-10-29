import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../core/network/api_client.dart';
import '../models/availability_model.dart';
import '../models/visit_model.dart';

class VisitProvider extends ChangeNotifier {
  VisitProvider({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  List<VisitModel> _visits = [];
  bool _isLoading = false;
  bool _loaded = false;
  String? _errorMessage;

  List<VisitModel> get visits => _visits;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _loaded;
  String? get errorMessage => _errorMessage;

  List<VisitModel> get upcomingVisits {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    return _visits
        .where(
          (visit) =>
              visit.date.isAfter(inicio.subtract(const Duration(days: 1))) &&
              visit.status.toLowerCase() == 'aceptada',
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<VisitModel> getVisitsForClient(String clientId) {
    return _visits.where((visit) => visit.clientId == clientId).toList();
  }

  List<VisitModel> getVisitsForCaregiver(String caregiverId) {
    return _visits.where((visit) => visit.caregiverId == caregiverId).toList();
  }

  Future<void> ensureLoaded() async {
    if (_loaded || _isLoading) {
      return;
    }
    await loadMyVisits();
  }

  Future<void> loadMyVisits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.get('/visits/');
      final list = _extractList(data);
      _visits = list
          .map(
            (item) => VisitModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      _loaded = true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar tus visitas.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AvailabilityModel> fetchAvailability(
    String caregiverId, {
    DateTime? date,
  }) async {
    final query = date == null
        ? ''
        : '?date=${DateFormat('yyyy-MM-dd').format(date)}';
    final data = await _api.get('/caregivers/$caregiverId/availability/$query');
    return AvailabilityModel.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<VisitModel> scheduleVisit({
    required String caregiverId,
    required DateTime date,
    required String time,
    String notes = '',
  }) async {
    final id = int.tryParse(caregiverId);
    if (id == null) {
      throw ApiException(null, 'El cuidador seleccionado no es válido.');
    }

    final data = await _api.post(
      '/visits/',
      body: {
        'caregiver': id,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'time': time,
        'message': notes.trim(),
      },
    );
    final visit = VisitModel.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
    _visits.insert(0, visit);
    notifyListeners();
    return visit;
  }

  Future<VisitModel> acceptVisit(String visitId) async {
    final data = await _api.post(
      '/visits/$visitId/accept/',
      body: const <String, dynamic>{},
    );
    return _replaceVisit(
      VisitModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<VisitModel> rejectVisit(String visitId, String reason) async {
    final data = await _api.post(
      '/visits/$visitId/reject/',
      body: {'reason': reason},
    );
    return _replaceVisit(
      VisitModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  VisitModel _replaceVisit(VisitModel visit) {
    final index = _visits.indexWhere((item) => item.id == visit.id);
    if (index != -1) {
      _visits[index] = visit;
    } else {
      _visits.insert(0, visit);
    }
    notifyListeners();
    return visit;
  }

  void updateVisitStatus(String visitId, String newStatus) {
    final index = _visits.indexWhere((visit) => visit.id == visitId);
    if (index != -1) {
      _visits[index] = _visits[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void reset() {
    _visits = [];
    _isLoading = false;
    _loaded = false;
    _errorMessage = null;
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
