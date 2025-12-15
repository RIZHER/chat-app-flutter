import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'logic/auth_bloc/auth_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/fcm_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. GUNAKAN OPSI DARI FILE GENERATE
  // Ini bikin aplikasi tahu dia jalan di Android atau iOS secara otomatis
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  ); 
  
  await FcmService().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(CheckAuthStatus()),
      child: MaterialApp(
        title: 'RH Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return HomeScreen();
            }
            return LoginScreen(); // Default ke Login kalau belum auth
          },
        ),
      ),
    );
  }
}