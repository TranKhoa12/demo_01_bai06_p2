import 'package:firebase_database/firebase_database.dart';
import '../models/note.dart';

// Tập trung thao tác Firebase tại đây để màn hình chỉ xử lý giao diện.
class NoteService {
  final DatabaseReference _notesRef = FirebaseDatabase.instance.ref('notes');

  Stream<List<Note>> watchNotes() {
    // onValue gửi sự kiện mỗi khi nhánh notes thay đổi.
    return _notesRef.orderByKey().onValue.map((event) {
      final notes = <Note>[];
      for (final child in event.snapshot.children) {
        final data = child.value;
        if (child.key != null && data is Map) {
          notes.add(Note.fromMap(child.key!, data));
        }
      }
      // Khóa push() có thứ tự theo thời gian; ghi chú mới hiển thị trước.
      return notes.reversed.toList();
    });
  }

  Future<void> addNote(String title, String content) async {
    // push() tạo ID riêng, set() gửi hai trường lên Firebase.
    await _notesRef.push().set({'title': title, 'content': content});
  }

  Future<void> deleteNote(String id) async {
    // Chỉ xóa ghi chú có ID được chọn.
    await _notesRef.child(id).remove();
  }
}
