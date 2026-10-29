import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/caregiver_model.dart';

class CaregiverProvider extends ChangeNotifier {
  CaregiverProvider({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  List<CaregiverModel> _caregivers = [];
  String _searchQuery = '';
  String _selectedCity = 'Todas';
  String _selectedSpecialty = 'Todas';
  bool _onlyAvailable = false;
  bool _isLoading = false;
  bool _loaded = false;
  String? _errorMessage;

  List<CaregiverModel> get caregivers => _caregivers;
  String get searchQuery => _searchQuery;
  String get selectedCity => _selectedCity;
  String get selectedSpecialty => _selectedSpecialty;
  bool get onlyAvailable => _onlyAvailable;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _loaded;
  String? get errorMessage => _errorMessage;

  List<String> get availableCities {
    final cities = _caregivers
        .map((caregiver) => caregiver.city.trim())
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
    cities.sort();
    return ['Todas', ...cities];
  }

  List<String> get availableSpecialties {
    final specialties = <String>{};
    for (final caregiver in _caregivers) {
      specialties.addAll(caregiver.specialties);
    }
    final list = specialties.toList()..sort();
    return ['Todas', ...list];
  }

  List<CaregiverModel> get filteredCaregivers {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _caregivers;
    }
    return _caregivers.where((caregiver) {
      return caregiver.specialties.any(
        (specialty) => specialty.toLowerCase().contains(query),
      );
    }).toList();
  }

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
      final data = await _api.get('/caregivers/');
      final list = _extractList(data);
      _caregivers = list
          .map(
            (item) => CaregiverModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      _loaded = true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar los cuidadores.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setSpecialty(String specialty) {
    _selectedSpecialty = specialty;
    notifyListeners();
  }

  void toggleOnlyAvailable() {
    _onlyAvailable = !_onlyAvailable;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCity = 'Todas';
    _selectedSpecialty = 'Todas';
    _onlyAvailable = false;
    notifyListeners();
  }

  void reset() {
    _caregivers = [];
    _loaded = false;
    _isLoading = false;
    _errorMessage = null;
    resetFilters();
  }

  CaregiverModel? getCaregiverById(String id) {
    try {
      return _caregivers.firstWhere((caregiver) => caregiver.id == id);
    } catch (_) {
      return null;
    }
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
