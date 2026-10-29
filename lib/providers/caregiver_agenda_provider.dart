import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../core/network/api_client.dart';
import '../models/caregiver_agenda_model.dart';

class CaregiverAgendaProvider extends ChangeNotifier {
  CaregiverAgendaProvider({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  CaregiverAgendaModel? _agenda;
  bool _isLoading = false;
  bool _loaded = false;
  String? _errorMessage;

  CaregiverAgendaModel? get agenda => _agenda;
  CaregiverAgendaStats get stats =>
      _agenda?.stats ?? const CaregiverAgendaStats();
  bool get isLoading => _isLoading;
  bool get hasLoaded => _loaded;
  String? get errorMessage => _errorMessage;

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
      final data = await _api.get('/caregiver/agenda/');
      _agenda = CaregiverAgendaModel.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
      _loaded = true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No se pudo cargar tu agenda.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CaregiverScheduleModel> addSchedule({
    required DateTime date,
    required String start,
    required String end,
  }) async {
    final data = await _api.post(
      '/caregiver/schedules/',
      body: {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'start': start,
        'end': end,
      },
    );
    final horario = CaregiverScheduleModel.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
    await load();
    return horario;
  }

  Future<void> deleteSchedule(String id) async {
    await _api.delete('/caregiver/schedules/$id/');
    await load();
  }

  Future<CaregiverBlockModel> addBlock({
    required DateTime date,
    required String hour,
  }) async {
    final data = await _api.post(
      '/caregiver/blocks/',
      body: {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'hour': hour,
      },
    );
    final bloqueo = CaregiverBlockModel.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
    await load();
    return bloqueo;
  }

  Future<void> deleteBlock(String id) async {
    await _api.delete('/caregiver/blocks/$id/');
    await load();
  }

  void reset() {
    _agenda = null;
    _isLoading = false;
    _loaded = false;
    _errorMessage = null;
    notifyListeners();
  }
}
