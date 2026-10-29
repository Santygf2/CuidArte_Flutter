import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/workshop_model.dart';

class WorkshopProvider extends ChangeNotifier {
  WorkshopProvider({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  List<WorkshopModel> _workshops = [];
  String _selectedModality = 'Todas';
  bool _isLoading = false;
  bool _loaded = false;
  String? _errorMessage;

  List<WorkshopModel> get workshops => _workshops;
  String get selectedModality => _selectedModality;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _loaded;
  String? get errorMessage => _errorMessage;

  List<WorkshopModel> get filteredWorkshops {
    if (_selectedModality == 'Todas') {
      return _workshops;
    }
    return _workshops
        .where((workshop) => workshop.modality == _selectedModality)
        .toList();
  }

  List<WorkshopModel> get myWorkshops =>
      _workshops.where((workshop) => workshop.isEnrolled).toList();

  Future<void> ensureLoaded() async {
    if (_loaded || _isLoading) {
      return;
    }
    await load();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.get('/workshops/');
      final list = _extractList(data);
      _workshops = list
          .map(
            (item) => WorkshopModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      _loaded = true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar los talleres.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setModality(String modality) {
    _selectedModality = modality;
    notifyListeners();
  }

  Future<WorkshopModel> toggleEnrollment(String workshopId) async {
    final index =
        _workshops.indexWhere((workshop) => workshop.id == workshopId);
    if (index == -1) {
      throw ApiException(null, 'Taller no encontrado.');
    }
    final actual = _workshops[index];

    final data = actual.isEnrolled
        ? await _api.delete('/workshops/$workshopId/enroll/')
        : await _api.post(
            '/workshops/$workshopId/enroll/',
            body: const <String, dynamic>{},
          );

    final actualizado = WorkshopModel.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
    final currentIndex =
        _workshops.indexWhere((workshop) => workshop.id == workshopId);
    if (currentIndex != -1) {
      _workshops[currentIndex] = actualizado;
    }
    notifyListeners();
    return actualizado;
  }

  void reset() {
    _workshops = [];
    _selectedModality = 'Todas';
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
