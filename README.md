# Quản lý ghi chú Flutter + Firebase

Giao diện theo ảnh: nền tím nhạt, tiêu đề ở giữa, danh sách ghi chú, nút +,
hộp thoại Tiêu đề/Nội dung với Hủy/Lưu và nút xóa đỏ.

## Đọc code

`lib/main.dart` có comment tiếng Việt theo từng phần:
- `main`: khởi tạo Flutter và Firebase.
- `MyApp`: cấu hình giao diện.
- `NotesPage`: đọc realtime, hiển thị, thêm và xóa dữ liệu.
- `AddNoteDialog`: kiểm tra nhập trống, gửi dữ liệu và xử lý lỗi.

## Chạy

```sh
flutter pub get
flutter run
```

Dùng Firebase đã cấu hình trong dự án: `fir-ct5`, không dùng project trong ảnh.
Database: https://fir-ct5-default-rtdb.firebaseio.com
Hiện hỗ trợ Android và Web; iOS chưa có cấu hình Firebase.

Mở Firebase Console → project fir-ct5 → Realtime Database → Data.
Trong app, nhấn +, nhập Tiêu đề/Nội dung rồi Lưu. Kiểm tra nhánh `notes`:

```json
{
  "notes": {
    "id_do_push_tao": {
      "title": "IT HUTECH",
      "content": "Bui Phu Khuyen"
    }
  }
}
```

`push()` tạo ID; `set()` ghi dữ liệu; `onValue` cập nhật danh sách;
`remove()` xóa theo ID. Ghi chú mới hiển thị trước.
Không tự gửi dữ liệu mẫu khi khởi động.

## Quyền truy cập

Ứng dụng chưa có đăng nhập. Nếu gặp permission-denied, kiểm tra Rules của
Realtime Database: client bài thực hành cần quyền đọc/ghi nhánh notes.
Code không tự đổi rules trên server. Với app dùng thật, cần bổ sung đăng nhập
và quyền theo người dùng, không mở công khai dữ liệu riêng tư.

## Kiểm tra

```sh
flutter analyze
flutter test
```

Test kiểm tra nhập trống, trim dữ liệu và giữ nội dung sau lỗi lưu.
Test không ghi dữ liệu lên Firebase thật và không kiểm tra quyền server.
Tài liệu: https://firebase.google.com/docs/database/flutter/read-and-write
