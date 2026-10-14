import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'app.dart';

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
