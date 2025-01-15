import 'package:flutter/material.dart';
import 'package:daily_notes/database/db_helper.dart';
import 'package:daily_notes/models/note.dart';
import 'package:daily_notes/models/user.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user; // Tambahkan field untuk pengguna yang sedang login

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Note> notes = [];
  int _selectedIndex = 0; // Indeks tab yang dipilih

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  // Memuat catatan dari database
  void loadNotes() async {
    final data = await dbHelper.getNotes();
    setState(() {
      notes = data;
    });
  }

  // Menampilkan dialog untuk menambahkan catatan baru
  void showAddNoteDialog() {
    String title = '';
    String content = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Catatan Baru"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Judul"),
                  onChanged: (val) {
                    title = val;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Konten"),
                  maxLines: null, // Membuat teks area bisa memanjang
                  keyboardType:
                      TextInputType.multiline, // Mengaktifkan multiline
                  onChanged: (val) {
                    content = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (title.trim().isNotEmpty && content.trim().isNotEmpty) {
                  Note newNote = Note(title: title, content: content);
                  await dbHelper.insertNote(newNote);
                  loadNotes();
                  Navigator.of(context).pop();
                } else {
                  // Opsional: Tampilkan pesan peringatan
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Judul dan Konten tidak boleh kosong')),
                  );
                }
              },
              child: Text("Tambah"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Batal"),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan dialog untuk mengedit catatan yang ada
  void showEditNoteDialog(Note note) {
    String title = note.title;
    String content = note.content;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Catatan"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Judul"),
                  controller: TextEditingController(text: title),
                  onChanged: (val) {
                    title = val;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Konten"),
                  controller: TextEditingController(text: content),
                  maxLines: null, // Membuat teks area bisa memanjang
                  keyboardType:
                      TextInputType.multiline, // Mengaktifkan multiline
                  onChanged: (val) {
                    content = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (title.trim().isNotEmpty && content.trim().isNotEmpty) {
                  Note updatedNote = Note(
                    id: note.id,
                    title: title,
                    content: content,
                  );
                  await dbHelper.updateNote(updatedNote);
                  loadNotes();
                  Navigator.of(context).pop();
                } else {
                  // Opsional: Tampilkan pesan peringatan
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Judul dan Konten tidak boleh kosong')),
                  );
                }
              },
              child: Text("Simpan"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Batal"),
            ),
          ],
        );
      },
    );
  }

  // Mengonfirmasi penghapusan catatan
  void confirmDeleteNote(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Hapus Catatan"),
          content: Text("Apakah Anda yakin ingin menghapus catatan ini?"),
          actions: [
            TextButton(
              onPressed: () async {
                await dbHelper.deleteNote(id);
                loadNotes();
                Navigator.of(context).pop();
              },
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Batal"),
            ),
          ],
        );
      },
    );
  }

  // Membangun setiap item catatan
  Widget buildNoteItem(Note note) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.note, color: Colors.white),
          backgroundColor: Colors.blue,
        ),
        title: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => showEditNoteDialog(note),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => confirmDeleteNote(note.id!),
            ),
          ],
        ),
      ),
    );
  }

  // Daftar widget untuk setiap tab
  List<Widget> _widgetOptions() => [
        // Tab Home
        Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Welcome, ${widget.user.username}!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: notes.isEmpty
                    ? Center(
                        child: Text("Tidak ada catatan. Tambahkan beberapa!"))
                    : ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return buildNoteItem(note);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: showAddNoteDialog,
            child: Icon(Icons.add),
          ),
        ),
        // Tab Profile
        ProfileScreen(user: widget.user),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Notes'),
      ),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Warna ikon yang dipilih
        onTap: _onItemTapped,
      ),
    );
  }
}
