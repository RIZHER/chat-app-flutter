import '../../models/message_model.dart';

abstract class ChatEvent {}

// Event saat pertama kali buka layar chat (Load History)
class LoadMessages extends ChatEvent {
  final int chatId;
  LoadMessages(this.chatId);
}

// Event saat tombol kirim ditekan
class SendMessage extends ChatEvent {
  final int chatId;
  final String content;
  SendMessage(this.chatId, this.content);
}

// Event saat ada pesan masuk dari WebSocket
class ReceiveMessage extends ChatEvent {
  final MessageModel message;
  ReceiveMessage(this.message);
}