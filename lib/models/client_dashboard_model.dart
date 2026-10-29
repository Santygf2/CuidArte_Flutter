import 'visit_model.dart';

class ClientDashboardStats {
  final int visits;
  final int pendingVisits;
  final int workshops;
  final int orders;
  final int contacts;
  final int unreadMessages;

  const ClientDashboardStats({
    required this.visits,
    required this.pendingVisits,
    required this.workshops,
    required this.orders,
    this.contacts = 0,
    required this.unreadMessages,
  });

  factory ClientDashboardStats.fromJson(Map<String, dynamic> json) {
    return ClientDashboardStats(
      visits: (json['visits'] as num?)?.toInt() ?? 0,
      pendingVisits: (json['pending_visits'] as num?)?.toInt() ?? 0,
      workshops: (json['workshops'] as num?)?.toInt() ?? 0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
      contacts: (json['contacts'] as num?)?.toInt() ?? 0,
      unreadMessages: (json['unread_messages'] as num?)?.toInt() ?? 0,
    );
  }
}

class UpcomingWorkshopModel {
  final String sessionId;
  final String workshopId;
  final String title;
  final DateTime date;
  final String time;
  final String location;
  final String modality;
  final String imageUrl;

  const UpcomingWorkshopModel({
    required this.sessionId,
    required this.workshopId,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.modality,
    required this.imageUrl,
  });

  factory UpcomingWorkshopModel.fromJson(Map<String, dynamic> json) {
    return UpcomingWorkshopModel(
      sessionId: (json['session_id'] ?? '').toString(),
      workshopId: (json['workshop_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ??
          DateTime.now(),
      time: (json['time'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      modality: (json['modality'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
    );
  }
}

class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final String url;
  final bool read;
  final DateTime date;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.url,
    required this.read,
    required this.date,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: (json['id'] ?? '').toString(),
      title: (json['titulo'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      read: json['read'] == true,
      date: DateTime.tryParse((json['fecha'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class ClientDashboardModel {
  final ClientDashboardStats stats;
  final List<VisitModel> upcomingVisits;
  final List<UpcomingWorkshopModel> upcomingWorkshops;
  final List<AppNotificationModel> notifications;

  const ClientDashboardModel({
    required this.stats,
    required this.upcomingVisits,
    required this.upcomingWorkshops,
    required this.notifications,
  });

  factory ClientDashboardModel.fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'];
    final visitsRaw = json['upcoming_visits'];
    final workshopsRaw = json['upcoming_workshops'];
    final notificationsRaw = json['notifications'];

    return ClientDashboardModel(
      stats: ClientDashboardStats.fromJson(
        statsRaw is Map
            ? Map<String, dynamic>.from(statsRaw)
            : const <String, dynamic>{},
      ),
      upcomingVisits: visitsRaw is List
          ? visitsRaw
                .whereType<Map>()
                .map(
                  (item) =>
                      VisitModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : <VisitModel>[],
      upcomingWorkshops: workshopsRaw is List
          ? workshopsRaw
                .whereType<Map>()
                .map(
                  (item) => UpcomingWorkshopModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : <UpcomingWorkshopModel>[],
      notifications: notificationsRaw is List
          ? notificationsRaw
                .whereType<Map>()
                .map(
                  (item) => AppNotificationModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : <AppNotificationModel>[],
    );
  }
}
