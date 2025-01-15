import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'daily_notes.db'),
      onCreate: (db, version) async {
        // Membuat tabel notes
        await db.execute(
          "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT)",
        );
        // Membuat tabel users dengan kolom photoPath
        await db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT, photoPath TEXT)",
        );
      },
      version: 1,
    );
  }

  // --- Metode untuk Notes (sudah ada sebelumnya) ---
  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('notes', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Metode untuk Users ---

  // Hash password menggunakan SHA-256
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Registrasi pengguna baru dengan hashing password
  Future<int> registerUser(User user) async {
    final db = await database;
    try {
      // Hash password sebelum disimpan
      String hashedPassword = hashPassword(user.password);
      User hashedUser = User(
          username: user.username,
          password: hashedPassword,
          photoPath: user.photoPath);
      return await db.insert(
        'users',
        hashedUser.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      // Username sudah ada
      return -1;
    }
  }

  // Autentikasi pengguna dengan hashing password
  Future<User?> authenticateUser(String username, String password) async {
    final db = await database;
    String hashedPassword = hashPassword(password);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Perbarui pengguna di database
  Future<bool> updateUser(User user) async {
    final db = await database;
    try {
      String hashedPassword = hashPassword(user.password);
      User updatedUser = User(
          id: user.id,
          username: user.username,
          password: hashedPassword,
          photoPath: user.photoPath);
      int count = await db.update(
        'users',
        updatedUser.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}
