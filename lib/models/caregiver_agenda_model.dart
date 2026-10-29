import 'client_dashboard_model.dart';
import 'visit_model.dart';

class CaregiverScheduleModel {
  final String id;
  final DateTime date;
  final String start;
  final String end;

  const CaregiverScheduleModel({
    required this.id,
    required this.date,
    required this.start,
    required this.end,
  });

  factory CaregiverScheduleModel.fromJson(Map<String, dynamic> json) {
    return CaregiverScheduleModel(
      id: (json['id'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ??
          DateTime.now(),
      start: (json['start'] ?? '').toString(),
      end: (json['end'] ?? '').toString(),
    );
  }
}

class CaregiverBlockModel {
  final String id;
  final DateTime date;
  final String hour;
  final String reason;
  final String reasonLabel;

  const CaregiverBlockModel({
    required this.id,
    required this.date,
    required this.hour,
    required this.reason,
    required this.reasonLabel,
  });

  factory CaregiverBlockModel.fromJson(Map<String, dynamic> json) {
    return CaregiverBlockModel(
      id: (json['id'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ??
          DateTime.now(),
      hour: (json['hour'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      reasonLabel: (json['reason_label'] ?? '').toString(),
    );
  }

  bool get isAppointment => reason == 'cita';
}

class CaregiverAgendaStats {
  final int solicitudes;
  final int pendientes;
  final int proximas;
  final int horarios;
  final int bloqueos;
  final int clientes;
  final int visitas;
  final int mensajes;

  const CaregiverAgendaStats({
    this.solicitudes = 0,
    this.pendientes = 0,
    this.proximas = 0,
    this.horarios = 0,
    this.bloqueos = 0,
    this.clientes = 0,
    this.visitas = 0,
    this.mensajes = 0,
  });

  factory CaregiverAgendaStats.fromJson(Map<String, dynamic> json) {
    return CaregiverAgendaStats(
      solicitudes: (json['solicitudes'] as num?)?.toInt() ?? 0,
      pendientes: (json['pendientes'] as num?)?.toInt() ?? 0,
      proximas: (json['proximas'] as num?)?.toInt() ?? 0,
      horarios: (json['horarios'] as num?)?.toInt() ?? 0,
      bloqueos: (json['bloqueos'] as num?)?.toInt() ?? 0,
      clientes: (json['clientes'] as num?)?.toInt() ?? 0,
      visitas: (json['visitas'] as num?)?.toInt() ?? 0,
      mensajes: (json['mensajes'] as num?)?.toInt() ?? 0,
    );
  }
}

class CaregiverAgendaModel {
  final CaregiverAgendaStats stats;
  final VisitModel? nextVisit;
  final List<VisitModel> pending;
  final List<VisitModel> upcoming;
  final List<VisitModel> history;
  final List<CaregiverScheduleModel> schedules;
  final List<CaregiverBlockModel> blocks;
  final List<AppNotificationModel> notifications;

  const CaregiverAgendaModel({
    required this.stats,
    required this.nextVisit,
    required this.pending,
    required this.upcoming,
    required this.history,
    required this.schedules,
    required this.blocks,
    required this.notifications,
  });

  factory CaregiverAgendaModel.fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'];
    final nextRaw = json['next_visit'];
    return CaregiverAgendaModel(
      stats: CaregiverAgendaStats.fromJson(
        statsRaw is Map
            ? Map<String, dynamic>.from(statsRaw)
            : const <String, dynamic>{},
      ),
      nextVisit: nextRaw is Map
          ? VisitModel.fromJson(Map<String, dynamic>.from(nextRaw))
          : null,
      pending: _visits(json['pending']),
      upcoming: _visits(json['upcoming']),
      history: _visits(json['history']),
      schedules: _list(json['schedules'])
          .map(
            (item) => CaregiverScheduleModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      blocks: _list(json['blocks'])
          .map(
            (item) => CaregiverBlockModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      notifications: _list(json['notifications'])
          .map(
            (item) => AppNotificationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  static List<VisitModel> _visits(dynamic data) {
    return _list(data)
        .map((item) => VisitModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<Map> _list(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((item) => item).toList();
    }
    return const [];
  }
}
