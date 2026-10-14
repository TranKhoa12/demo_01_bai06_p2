import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../widgets/add_note_dialog.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Dữ liệu được lưu tại /notes/<id> gồm title và content như ảnh.
  final NoteService _noteService = NoteService();
  late final Stream<List<Note>> _notesStream;
  final Set<String> _deletingIds = {};

  @override
  void initState() {
    super.initState();
    // Đăng ký stream một lần; Firebase gửi sự kiện khi dữ liệu thay đổi.
    _notesStream = _noteService.watchNotes();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteNote(String id) async {
    setState(() => _deletingIds.add(id));
    try {
      // remove() chỉ xóa ghi chú có ID được chọn.
      await _noteService.deleteNote(id);
      _showMessage('Đã xóa ghi chú');
    } catch (error) {
      _showMessage('Không thể xóa. Kiểm tra kết nối và quyền Firebase.');
    } finally {
      if (mounted) setState(() => _deletingIds.remove(id));
    }
  }

  Future<void> _showAddDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddNoteDialog(onSave: _noteService.addNote),
    );
    if (saved == true) _showMessage('Đã lưu ghi chú lên Firebase');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Ghi chú')),
      // StreamBuilder tự vẽ lại danh sách khi nhận dữ liệu realtime.
      body: StreamBuilder<List<Note>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Không thể tải ghi chú. Kiểm tra kết nối và quyền đọc Firebase.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;
          if (notes.isEmpty) {
            return const Center(child: Text('Chưa có ghi chú nào'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.content),
                trailing: _deletingIds.contains(note.id)
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        tooltip: 'Xóa ghi chú',
                        color: Colors.red,
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteNote(note.id),
                      ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: 'Thêm ghi chú',
        backgroundColor: const Color(0xFFEADDFF),
        child: const Icon(Icons.add),
      ),
    );
  }
}
