import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/api_client.dart';
import '../logic/auth_bloc/auth_bloc.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient api = ApiClient();
  List<dynamic> chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  // Tarik data chat dari Laravel
  Future<void> _loadChats() async {
    try {
      final res = await api.dio.get('/chats');
      setState(() {
        chats = res.data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading chats: $e");
      setState(() => isLoading = false);
    }
  }

  // Fungsi Tambah Teman
  void _addFriend() {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Tambah Teman"),
        content: TextField(
          controller: codeCtrl,
          decoration: InputDecoration(hintText: "Masukkan Kode Unik (misal: U-00005)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await api.dio.post('/chats', data: {'unique_code': codeCtrl.text});
                _loadChats(); // Refresh list
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User tidak ditemukan")));
              }
            },
            child: Text("Chat"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RH Chat"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        onPressed: _addFriend,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (ctx, i) {
                final chat = chats[i];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(chat['avatar'])),
                  title: Text(chat['name']),
                  subtitle: Text(chat['last_message'], maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(chat['time'], style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    // Masuk ke Chat Room
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId: chat['id'],
                          chatName: chat['name'],
                        ),
                      ),
                    ).then((_) => _loadChats()); // Refresh pas kembali
                  },
                );
              },
            ),
    );
  }
}