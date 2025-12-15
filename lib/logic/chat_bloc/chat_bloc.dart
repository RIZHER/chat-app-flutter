import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../core/api_client.dart';
import '../../models/message_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ApiClient api = ApiClient();
  int myUserId = 0;
  
  // Kita pakai Pusher Channels langsung (Tanpa Laravel Echo)
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  ChatBloc() : super(ChatInitial()) {
    
    // 1. Load Messages & Connect Socket
    on<LoadMessages>((event, emit) async {
      emit(ChatLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        myUserId = prefs.getInt('user_id') ?? 0;

        // A. Ambil History Chat dari API
        final response = await api.dio.get('/chats/${event.chatId}');
        List<MessageModel> messages = (response.data as List)
            .map((json) => MessageModel.fromJson(json, myUserId))
            .toList();

        emit(ChatLoaded(messages));

        // B. Connect WebSocket (Reverb)
        await _initPusher(event.chatId);

      } catch (e) {
        emit(ChatError("Gagal memuat chat: $e"));
      }
    });

    // 2. Send Message
    on<SendMessage>((event, emit) async {
      try {
        // Kirim ke API
        final response = await api.dio.post('/chats/${event.chatId}/messages', data: {
          'content': event.content,
        });

        // Masukkan pesan kita sendiri ke list (Optimistic Update)
        final newMessage = MessageModel.fromJson(response.data, myUserId);
        add(ReceiveMessage(newMessage)); 
        
      } catch (e) {
        // emit(ChatError("Gagal mengirim pesan")); // Opsional: Tampilkan error
      }
    });

    // 3. Receive Message
    on<ReceiveMessage>((event, emit) {
      if (state is ChatLoaded) {
        final currentMessages = (state as ChatLoaded).messages;
        
        // Cek duplicate ID
        final isExist = currentMessages.any((msg) => msg.id == event.message.id);
        
        if (!isExist) {
          final updatedMessages = List<MessageModel>.from(currentMessages)..add(event.message);
          emit(ChatLoaded(updatedMessages));
        }
      }
    });
  }

  // --- LOGIC WEBSOCKET (DIRECT PUSHER) ---
  Future<void> _initPusher(int chatId) async {
    try {
      // 1. Setup Konfigurasi
      await pusher.init(
        apiKey: "c8ma5xnlvwiwwmudt9yh", // App Key default Reverb (biasanya ini, atau cek .env laravel)
        cluster: "mt1",
        useTLS: false, // Wajib false untuk HTTP lokal
        onEvent: (PusherEvent event) {
          print("EVENT MASUK: ${event.eventName} => ${event.data}");
          
          // Filter Event: Hanya ambil event 'MessageSent'
          if (event.eventName.contains('MessageSent')) {
            // Data dari Pusher berupa String JSON, harus di-decode
            final data = jsonDecode(event.data);
            
            // Reverb membungkus data dalam key 'message' (sesuai Event di Laravel)
            if (data['message'] != null) {
              final msg = MessageModel.fromJson(data['message'], myUserId);
              add(ReceiveMessage(msg));
            }
          }
        },
        onAuthorizer: (String channelName, String socketId, options) async {
          // 2. MANUAL AUTH (Pengganti Laravel Echo)
          // Kita hit endpoint auth laravel secara manual
          try {
            print("Authorizing channel: $channelName with socket: $socketId");
            final response = await api.dio.post('/broadcasting/auth', data: {
              'socket_id': socketId,
              'channel_name': channelName,
            });
            // Kembalikan data JSON auth ke Pusher
            return response.data;
          } catch (e) {
            print("Auth Error: $e");
            return null;
          }
        },
      );

      // 3. Connect ke Host Lokal (Laptop)
      await pusher.connect();

      // 4. Subscribe ke Private Channel
      // Format Channel Laravel biasanya: private-chat.{id}
      await pusher.subscribe(channelName: "private-chat.$chatId");

    } catch (e) {
      print("Pusher Error: $e");
    }
  }

  @override
  Future<void> close() async {
    await pusher.disconnect(); // Matikan socket saat keluar chat
    return super.close();
  }
}