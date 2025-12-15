class ChatModel {
  final int id;
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;

  ChatModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      avatar: json['avatar'] ?? '',
      lastMessage: json['last_message'] ?? '',
      time: json['time'] ?? '',
    );
  }
}