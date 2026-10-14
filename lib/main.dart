import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Chuẩn bị Flutter trước khi gọi plugin Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (error) {
    // Hiển thị lỗi cấu hình thay vì để ứng dụng trắng màn hình.
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Không thể khởi tạo Firebase. Kiểm tra cấu hình và khởi động lại.',
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFFFF7FF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý Ghi chú',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20),
        ),
        dialogTheme: const DialogThemeData(backgroundColor: background),
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Dữ liệu được lưu tại /notes/<id> gồm title và content như ảnh.
  final DatabaseReference _notesRef = FirebaseDatabase.instance.ref('notes');
  late final Stream<DatabaseEvent> _notesStream;
  final Set<String> _deletingIds = {};

  @override
  void initState() {
    super.initState();
    // Đăng ký stream một lần; Firebase gửi sự kiện khi dữ liệu thay đổi.
    _notesStream = _notesRef.orderByKey().onValue;
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
      await _notesRef.child(id).remove();
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
      builder: (_) => AddNoteDialog(
        onSave: (title, content) async {
          // push() tạo ID riêng; set() gửi dữ liệu lên Firebase.
          await _notesRef.push().set({'title': title, 'content': content});
        },
      ),
    );
    if (saved == true) _showMessage('Đã lưu ghi chú lên Firebase');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Ghi chú')),
      // StreamBuilder tự vẽ lại danh sách khi nhận dữ liệu realtime.
      body: StreamBuilder<DatabaseEvent>(
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
          // Đảo thứ tự để ghi chú mới nhất nằm trên cùng.
          final notes = snapshot.data!.snapshot.children
              .where((child) => child.key != null && child.value is Map)
              .toList()
              .reversed
              .toList();
          if (notes.isEmpty) {
            return const Center(child: Text('Chưa có ghi chú nào'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final data = Map<Object?, Object?>.from(note.value as Map);
              return ListTile(
                title: Text(data['title']?.toString() ?? ''),
                subtitle: Text(data['content']?.toString() ?? ''),
                trailing: _deletingIds.contains(note.key)
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        tooltip: 'Xóa ghi chú',
                        color: Colors.red,
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteNote(note.key!),
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

// Tách dialog để quản lý ô nhập và trạng thái lưu độc lập với danh sách.
class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key, required this.onSave});
  final Future<void> Function(String title, String content) onSave;

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    // Giải phóng controller khi đóng dialog.
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // trim() bỏ khoảng trắng; chỉ đóng sau khi Firebase xác nhận đã lưu.
      await widget.onSave(
        _titleController.text.trim(),
        _contentController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Không thể lưu. Kiểm tra kết nối và quyền ghi Firebase.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Chặn Back và vô hiệu hóa các nút khi đang gửi để tránh lưu trùng.
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: const Text('Thêm ghi chú mới'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Vui lòng nhập tiêu đề'
                      : null,
                ),
                TextFormField(
                  controller: _contentController,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Nội dung'),
                  minLines: 1,
                  maxLines: 5,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Vui lòng nhập nội dung'
                      : null,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Đang lưu...' : 'Lưu'),
          ),
        ],
      ),
    );
  }
}
