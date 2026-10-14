import 'package:demo_01_bai06_p2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Kiểm tra nhập trống và gửi nội dung đã trim', (tester) async {
    String? title;
    String? content;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddNoteDialog(
            onSave: (t, c) async {
              title = t;
              content = c;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập tiêu đề'), findsOneWidget);
    expect(find.text('Vui lòng nhập nội dung'), findsOneWidget);
    expect(title, isNull);
    await tester.enterText(find.byType(TextFormField).at(0), ' IT HUTECH ');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      ' Bui Phu Khuyen ',
    );
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(title, 'IT HUTECH');
    expect(content, 'Bui Phu Khuyen');
  });

  testWidgets('Lỗi lưu giữ lại dữ liệu để thử lại', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddNoteDialog(
            onSave: (_, _) async => throw Exception('permission-denied'),
          ),
        ),
      ),
    );
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Flutter Firebase',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Realtime Database',
    );
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(
      find.text('Không thể lưu. Kiểm tra kết nối và quyền ghi Firebase.'),
      findsOneWidget,
    );
    expect(find.text('Flutter Firebase'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Lưu'))
          .onPressed,
      isNotNull,
    );
  });
}
