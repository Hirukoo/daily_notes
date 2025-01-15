// lib/models/user.dart

class User {
  final int? id;
  String username;
  String password;
  String? photoPath; // Tambahkan field photoPath

  User({
    this.id,
    required this.username,
    required this.password,
    this.photoPath, // Inisialisasi photoPath
  });

  // Mengubah User menjadi Map
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'username': username,
      'password': password, // Pastikan sudah di-hash
      'photoPath': photoPath, // Tambahkan photoPath
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Mengubah Map menjadi User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      photoPath: map['photoPath'], // Ambil photoPath
    );
  }
}
