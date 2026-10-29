import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/client_dashboard_model.dart';
import '../models/visit_model.dart';

class ClientDashboardProvider extends ChangeNotifier {
  ClientDashboardProvider({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  static const _emptyStats = ClientDashboardStats(
    visits: 0,
    pendingVisits: 0,
    workshops: 0,
    orders: 0,
    contacts: 0,
    unreadMessages: 0,
  );

  final ApiClient _api;

  ClientDashboardModel? _dashboard;
  bool _isLoading = false;
  bool _loaded = false;
  String? _errorMessage;

  ClientDashboardModel? get dashboard => _dashboard;
  ClientDashboardStats get stats => _dashboard?.stats ?? _emptyStats;
  List<VisitModel> get upcomingVisits =>
      _dashboard?.upcomingVisits ?? const <VisitModel>[];
  List<UpcomingWorkshopModel> get upcomingWorkshops =>
      _dashboard?.upcomingWorkshops ?? const [];
  List<AppNotificationModel> get notifications =>
      _dashboard?.notifications ?? const [];
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
      final data = await _api.get('/client/dashboard/');
      _dashboard = ClientDashboardModel.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
      _loaded = true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No se pudo cargar tu panel.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationsRead() async {
    try {
      await _api.post(
        '/notifications/read-all/',
        body: const <String, dynamic>{},
      );
      await load();
    } catch (_) {}
  }

  void reset() {
    _dashboard = null;
    _isLoading = false;
    _loaded = false;
    _errorMessage = null;
    notifyListeners();
  }
}
