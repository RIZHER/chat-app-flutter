class MessageModel {
  final int id;
  final int chatId;
  final int userId;
  final String content;
  final String createdAt;
  final bool isMe; // Helper untuk UI (pesan sendiri/orang lain)

  MessageModel({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.isMe = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, int myUserId) {
    return MessageModel(
      id: json['id'],
      chatId: int.tryParse(json['chat_id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      isMe: (json['user_id'] == myUserId),
    );
  }
}