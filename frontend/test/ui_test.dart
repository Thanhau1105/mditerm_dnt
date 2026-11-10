import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vku_student_management/models/user_model.dart';
import 'package:vku_student_management/screens/login_screen.dart';
import 'package:vku_student_management/screens/user_form_screen.dart';
import 'package:vku_student_management/services/api_service.dart';
import 'package:vku_student_management/services/auth_service.dart';
import 'package:vku_student_management/widgets/app_theme.dart';
import 'package:vku_student_management/widgets/user_card.dart';

void main() {
  for (final width in [320.0, 390.0, 1440.0]) {
    testWidgets('Login remains usable at ${width.toInt()}px', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = ApiService(
        client: MockClient((_) async => http.Response('{}', 401)),
      );
      final auth = AuthService(api);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: LoginScreen(auth: auth),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(2));
      final submit = find.widgetWithText(FilledButton, 'Đăng nhập');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng nhập email hợp lệ.'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
      api.close();
    });
  }

  testWidgets('Rejected login shows backend message without losing the form', (
    tester,
  ) async {
    final api = ApiService(
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode({'message': 'Email hoặc mật khẩu không đúng.'}),
          ),
          401,
        ),
      ),
    );
    final auth = AuthService(api);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: LoginScreen(auth: auth),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'a@vku.udn.vn');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    final submit = find.widgetWithText(FilledButton, 'Đăng nhập');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Email hoặc mật khẩu không đúng.'), findsOneWidget);
    expect(auth.isAuthenticated, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
    api.close();
  });

  testWidgets('Create form submits actual user input on a narrow display', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Map<String, dynamic>? submitted;
    final api = ApiService(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/auth/login')) {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'token': 'test-admin-token',
                'isAdmin': true,
                'user': {
                  '_id': '507f1f77bcf86cd799439011',
                  'email': 'hautt.23it@vku.udn.vn',
                  'hoten': 'Trần Thành Hậu',
                  'hinhanh': '',
                },
              }),
            ),
            200,
          );
        }
        submitted = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'user': {'_id': '507f1f77bcf86cd799439012', ...submitted!},
            }),
          ),
          201,
        );
      }),
    );
    final auth = AuthService(api);
    await auth.login('hautt.23it@vku.udn.vn', 'Vku@123456');
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (_) => UserFormScreen(auth: auth),
              ),
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Nguyễn Minh Châu',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'chau@vku.udn.vn');
    await tester.enterText(find.byType(TextFormField).at(2), 'Vku@123456');
    final save = find.widgetWithText(FilledButton, 'Lưu thông tin');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(submitted?['hoten'], 'Nguyễn Minh Châu');
    expect(submitted?['email'], 'chau@vku.udn.vn');
    expect(submitted?['hinhanh'], '');
    expect(find.byType(UserFormScreen), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
    api.close();
  });

  testWidgets('Student card handles long names and emails at 320px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: UserCard(
            user: const UserModel(
              id: '1',
              email: 'student.with.a.very.long.email.address@vku.udn.vn',
              hoten: 'Nguyễn Trần Hoàng Anh Thư có họ tên dài',
              hinhanh: '',
            ),
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(UserCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
