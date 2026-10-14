import 'package:flutter/material.dart';

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
