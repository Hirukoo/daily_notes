import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:daily_notes/database/db_helper.dart';
import 'package:daily_notes/models/user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Fungsi untuk login
  void login(BuildContext context) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username dan Password tidak boleh kosong')),
      );
      return;
    }

    User? user = await dbHelper.authenticateUser(username, password);

    if (user != null) {
      // Login berhasil, navigasi ke HomeScreen dengan objek User
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
      );
    } else {
      // Login gagal, tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username atau Password salah')),
      );
    }
  }

  // Fungsi untuk registrasi
  void register(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return RegisterDialog(dbHelper: dbHelper);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                login(context);
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                register(context);
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterDialog extends StatefulWidget {
  final DatabaseHelper dbHelper;

  RegisterDialog({required this.dbHelper});

  @override
  _RegisterDialogState createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final TextEditingController regUsernameController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();
  final TextEditingController regConfirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  void register() async {
    String username = regUsernameController.text.trim();
    String password = regPasswordController.text.trim();
    String confirmPassword = regConfirmPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password dan Konfirmasi Password tidak cocok')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // **Catatan Keamanan:** Sebaiknya hash password sebelum disimpan
    User newUser = User(username: username, password: password);
    int result = await widget.dbHelper.registerUser(newUser);

    setState(() {
      isLoading = false;
    });

    if (result != -1) {
      // Registrasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
      );
      Navigator.of(context).pop();
    } else {
      // Registrasi gagal (username sudah ada)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username sudah digunakan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Register'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: regUsernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: regPasswordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: regConfirmPasswordController,
              decoration: InputDecoration(labelText: 'Konfirmasi Password'),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        isLoading
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            : TextButton(
                onPressed: () {
                  register();
                },
                child: Text('Register'),
              ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal'),
        ),
      ],
    );
  }
}
