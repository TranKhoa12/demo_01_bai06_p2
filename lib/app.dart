import 'package:flutter/material.dart';
import 'screens/notes_page.dart';

// Cấu hình giao diện chung và màn hình đầu tiên của ứng dụng.
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
