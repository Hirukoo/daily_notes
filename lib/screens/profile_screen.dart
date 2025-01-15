import 'package:flutter/material.dart';
import 'package:daily_notes/models/user.dart';
import 'package:daily_notes/database/db_helper.dart';
import 'package:daily_notes/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  late TextEditingController usernameController;
  late TextEditingController passwordController;

  bool isEditing = false;
  bool isLoading = false;

  File? _imageFile; // Untuk menyimpan file gambar yang dipilih

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user.username);
    passwordController = TextEditingController();
    if (widget.user.photoPath != null && widget.user.photoPath!.isNotEmpty) {
      _imageFile = File(widget.user.photoPath!);
    }
  }

  // Fungsi untuk memilih foto dari galeri
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengambil foto menggunakan kamera
  Future<void> _takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengedit profil
  void editProfile() {
    setState(() {
      isEditing = true;
    });
  }

  // Fungsi untuk menyimpan perubahan profil
  void saveProfile() async {
    String newUsername = usernameController.text.trim();
    String newPassword = passwordController.text.trim();

    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Update username dan password jika diubah
    widget.user.username = newUsername;
    if (newPassword.isNotEmpty) {
      widget.user.password = newPassword; // Pastikan hashing jika diperlukan
    }

    // Update photoPath jika ada perubahan
    if (_imageFile != null) {
      widget.user.photoPath = _imageFile!.path;
    } else {
      widget.user.photoPath = null;
    }

    // Perbarui pengguna di database
    bool success = await dbHelper.updateUser(widget.user);

    setState(() {
      isLoading = false;
      isEditing = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil')),
      );
    }
  }

  // Fungsi untuk logout
  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Anda'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // Menambahkan SingleChildScrollView untuk menghindari overflow
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: isEditing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : AssetImage('assets/default_profile.png')
                                    as ImageProvider, // Gunakan gambar default dari lokal
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: FloatingActionButton.small(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    height: 120,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.photo_library),
                                          title: Text('Pilih dari Galeri'),
                                          onTap: () {
                                            _pickImage();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.camera),
                                          title: Text('Ambil Foto'),
                                          onTap: () {
                                            _takePhoto();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Icon(Icons.camera_alt),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: saveProfile,
                                icon: Icon(Icons.save),
                                label: Text('Simpan'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isEditing = false;
                                  });
                                },
                                icon: Icon(Icons.cancel),
                                label: Text('Batal'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : AssetImage('assets/default_profile.png')
                                as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Username',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      widget.user.username,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: editProfile,
                      icon: Icon(Icons.edit),
                      label: Text('Edit Profil'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: logout,
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
