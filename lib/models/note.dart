// Một ghi chú tương ứng với dữ liệu tại /notes/<id> trên Firebase.
class Note {
  const Note({required this.id, required this.title, required this.content});

  final String id;
  final String title;
  final String content;

  // Chuyển dữ liệu Firebase thành đối tượng dễ dùng trong giao diện.
  factory Note.fromMap(String id, Map<dynamic, dynamic> data) {
    return Note(
      id: id,
      title: data['title']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
    );
  }
}
