class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  // Untuk konversi dari Map (Database) ke Object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? 'Tanpa Judul',
      content: map['content'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Untuk konversi dari Object ke Map (Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}