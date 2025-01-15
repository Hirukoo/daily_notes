// lib/models/note.dart
class Note {
  final int? id;
  final String title;
  final String content;

  Note({this.id, required this.title, required this.content});

  // Mengubah Note menjadi Map. Kunci harus sesuai dengan nama kolom di database.
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'content': content,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Mengubah Map menjadi Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
    );
  }
}
