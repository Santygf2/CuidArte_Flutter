class ChatMessageModel {
  final String id;
  final String text;
  final bool mine;
  final String time;
  final String day;
  final String senderName;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.mine,
    required this.time,
    required this.day,
    required this.senderName,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      mine: json['mine'] == true,
      time: (json['time'] ?? '').toString(),
      day: (json['day'] ?? '').toString(),
      senderName: (json['sender_name'] ?? '').toString(),
    );
  }
}
