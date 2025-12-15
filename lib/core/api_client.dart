import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // PENTING:
  // - Jika pakai Emulator Android: Gunakan 'http://10.0.2.2:8000/api'
  // - Jika pakai HP Fisik: Gunakan IP LAN Laptop (misal 'http://192.168.1.10:8000/api')
  // - Jika pakai iOS Simulator: Gunakan 'http://127.0.0.1:8000/api'
  static const String baseUrl = 'http://10.218.187.128:8000/api';

  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {'Accept': 'application/json'}, // Biar gak kena HTML welcome page
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  ApiClient() {
    // Interceptor: Setiap request, cek apakah ada token di HP? Kalau ada, tempel.
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Bisa handle error 401 (Logout paksa) disini
        return handler.next(e);
      },
    ));
  }
}