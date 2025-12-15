import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import '../../services/fcm_service.dart'; // <--- Import Service FCM

// ================= EVENTS =================
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

// ================= STATES =================
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final int userId;
  Authenticated(this.userId);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// ================= BLOC =================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient api = ApiClient();
  
  // PERBAIKAN: Mendeklarasikan variable fcmService disini agar dikenali
  final FcmService fcmService = FcmService(); 

  AuthBloc() : super(AuthInitial()) {
    
    // 1. Cek Login Saat App Dibuka
    on<CheckAuthStatus>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        emit(Authenticated(prefs.getInt('user_id') ?? 0)); 
      } else {
        emit(Unauthenticated());
      }
    });

    // 2. Proses Login
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Hit API Login
        final response = await api.dio.post('/login', data: {
          'email': event.email,
          'password': event.password,
        });

        final token = response.data['token'];
        final user = response.data['user'];

        // Simpan ke HP
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setInt('user_id', user['id']);
        // Simpan data tambahan jika perlu
        if (user['name'] != null) await prefs.setString('user_name', user['name']);
        if (user['unique_code'] != null) await prefs.setString('unique_code', user['unique_code']);

        // --- BAGIAN LOGIC FCM ---
        // Ambil Token HP & Kirim ke Backend
        try {
          String? fcmToken = await fcmService.getToken();
          if (fcmToken != null) {
            print("FCM Token: $fcmToken");
            // Kirim ke API Laravel
            await api.dio.post('/fcm-token', data: {'fcm_token': fcmToken});
          }
        } catch (e) {
          // Error FCM jangan sampai menggagalkan login user
          print("Gagal update FCM Token: $e");
        }
        // ------------------------

        emit(Authenticated(user['id']));
      } on DioException catch (e) {
        emit(AuthError(e.response?.data['message'] ?? 'Login Gagal'));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // 3. Logout
    on<LogoutRequested>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Hapus semua data
      emit(Unauthenticated());
    });
  }
}