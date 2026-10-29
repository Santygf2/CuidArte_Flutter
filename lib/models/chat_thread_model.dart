class ChatThreadModel {
  final String id;
  final String otherName;
  final String otherAvatar;
  final String otherRole;
  final String lastMessage;
  final bool lastMine;
  final String lastTime;
  final int unread;
  final String status;
  final String caregiverId;

  const ChatThreadModel({
    required this.id,
    required this.otherName,
    required this.otherAvatar,
    required this.otherRole,
    required this.lastMessage,
    required this.lastMine,
    required this.lastTime,
    required this.unread,
    required this.status,
    required this.caregiverId,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    return ChatThreadModel(
      id: (json['id'] ?? '').toString(),
      otherName: (json['other_name'] ?? '').toString(),
      otherAvatar: (json['other_avatar'] ?? '').toString(),
      otherRole: (json['other_role'] ?? '').toString(),
      lastMessage: (json['last_message'] ?? '').toString(),
      lastMine: json['last_mine'] == true,
      lastTime: (json['last_time'] ?? '').toString(),
      unread: (json['unread'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
      caregiverId: (json['caregiver_id'] ?? '').toString(),
    );
  }

  String get preview => lastMine ? 'Tú: $lastMessage' : lastMessage;
}
