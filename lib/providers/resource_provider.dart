import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/educational_resource_model.dart';

class ResourceProvider extends ChangeNotifier {
  ResourceProvider({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  List<EducationalResourceModel> _resources = [];
  String _selectedCategory = 'Todas';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _loaded = false;
  String? _errorMessage;

  List<EducationalResourceModel> get resources => _resources;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _loaded;
  String? get errorMessage => _errorMessage;

  List<String> get categories => [
        'Todas',
        'Cuidado Profesional',
        'Cuerpo del Adulto Mayor',
        'Ejercicio y Salud Física',
        'Salud Emocional y Cognitiva',
        'Otros Recursos',
      ];

  List<EducationalResourceModel> get filteredResources {
    return _resources.where((resource) {
      final matchesCategory = _selectedCategory == 'Todas' ||
          resource.category == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          resource.title.toLowerCase().contains(query) ||
          resource.summary.toLowerCase().contains(query) ||
          resource.author.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
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
      final data = await _api.get('/resources/');
      final list = _extractList(data);
      _resources = list
          .map(
            (item) => EducationalResourceModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      _loaded = true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar los recursos.';
    } finally {
      _isLoading = false;
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

  void reset() {
    _resources = [];
    _selectedCategory = 'Todas';
    _searchQuery = '';
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
