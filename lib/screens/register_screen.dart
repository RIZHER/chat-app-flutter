import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final ApiClient api = ApiClient();
  bool isLoading = false;

  void _register() async {
    setState(() => isLoading = true);
    try {
      await api.dio.post('/register', data: {
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'password': _passCtrl.text,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil! Silakan Login")));
      Navigator.pop(context); // Kembali ke Login
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.response?.data['message'] ?? "Gagal")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Akun")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: "Nama")),
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _passCtrl, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            isLoading 
              ? CircularProgressIndicator()
              : ElevatedButton(onPressed: _register, child: Text("DAFTAR"))
          ],
        ),
      ),
    );
  }
}