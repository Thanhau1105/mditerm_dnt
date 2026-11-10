import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vku_student_management/main.dart';
import 'package:vku_student_management/screens/user_form_screen.dart';
import 'package:vku_student_management/services/api_service.dart';
import 'package:vku_student_management/services/auth_service.dart';
import 'package:vku_student_management/widgets/user_card.dart';

/// Real Android -> Express -> Atlas verification. No HTTP mocks are used.
/// Only the uniquely named record created by this test may be deleted.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const adminEmail = String.fromEnvironment(
    'TEST_ADMIN_EMAIL',
    defaultValue: 'hautt.23it@vku.udn.vn',
  );
  const password = String.fromEnvironment(
    'TEST_ADMIN_PASSWORD',
    defaultValue: 'Vku@123456',
  );

  testWidgets('Android authenticates and manages real Atlas records', (
    tester,
  ) async {
    final api = ApiService();
    final cleanupApi = ApiService();
    final auth = AuthService(api);
    final testEmail =
        'android-qa-${DateTime.now().microsecondsSinceEpoch}@vku.udn.vn';
    const originalName = 'Sinh viên kiểm thử Android';
    const updatedName = 'Sinh viên Android đã cập nhật';
    int? originalCount;

    Future<void> waitFor(bool Function() condition, String label) async {
      final deadline = DateTime.now().add(const Duration(seconds: 35));
      while (!condition()) {
        if (DateTime.now().isAfter(deadline)) fail('Timed out: $label');
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pumpAndSettle();
    }

    Future<void> loginThroughForm(String email) async {
      await waitFor(
        () => find.byType(TextFormField).evaluate().length == 2,
        'login form',
      );
      await tester.enterText(find.byType(TextFormField).at(0), email);
      await tester.enterText(find.byType(TextFormField).at(1), password);
      final submit = find.widgetWithText(FilledButton, 'Đăng nhập');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
    }

    try {
      await tester.pumpWidget(VkuApp(auth: auth));
      await tester.pumpAndSettle();
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('android-login');

      await loginThroughForm(adminEmail);
      await waitFor(() => auth.isAuthenticated && auth.isAdmin, 'admin login');
      cleanupApi.token = api.token;
      originalCount = (await cleanupApi.getUsers()).total;
      await waitFor(
        () => find.byType(UserCard).evaluate().isNotEmpty,
        'student cards from Atlas',
      );
      expect(find.text('Tổng số sinh viên'), findsOneWidget);
      await binding.takeScreenshot('android-dashboard-atlas');

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(UserFormScreen), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), originalName);
      await tester.enterText(find.byType(TextFormField).at(1), testEmail);
      await tester.enterText(find.byType(TextFormField).at(2), password);
      final save = find.widgetWithText(FilledButton, 'Lưu thông tin');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await waitFor(
        () => find.byType(UserFormScreen).evaluate().isEmpty,
        'create student',
      );

      final created = (await cleanupApi.getUsers(search: testEmail))
          .users
          .single;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 32, 32),
        Paint()..color = const Color(0xFF245EEA),
      );
      canvas.drawCircle(const Offset(16, 16), 8, Paint()..color = Colors.white);
      final picture = recorder.endRecording();
      final bitmap = await picture.toImage(32, 32);
      final png = await bitmap.toByteData(format: ui.ImageByteFormat.png);
      final encodedImage = base64Encode(png!.buffer.asUint8List());
      bitmap.dispose();
      picture.dispose();
      // Seed a valid image via the real API, then verify Android reads/displays it.
      // The native gallery picker itself remains a separate manual check.
      await cleanupApi.updateUser(
        created.id,
        hoten: originalName,
        email: testEmail,
        matkhau: '',
        hinhanh: encodedImage,
      );

      await tester.enterText(find.byType(TextField).first, testEmail);
      await tester.pump(const Duration(milliseconds: 500));
      await waitFor(
        () => find.text(originalName).evaluate().isNotEmpty,
        'search result',
      );
      final card = find.byType(UserCard);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: card, matching: find.byType(Image)),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Thao tác sinh viên'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chỉnh sửa'));
      await tester.pumpAndSettle();
      expect(find.byType(UserFormScreen), findsOneWidget);
      expect(find.text('Gỡ ảnh'), findsOneWidget);
      await binding.takeScreenshot('android-edit-image-from-atlas');
      await tester.enterText(find.byType(TextFormField).at(0), updatedName);
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Lưu thông tin'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Lưu thông tin'));
      await waitFor(
        () => find.byType(UserFormScreen).evaluate().isEmpty,
        'edit student',
      );
      final edited = await cleanupApi.getUser(created.id);
      expect(edited.hoten, updatedName);
      expect(edited.hinhanh, encodedImage);

      final studentApi = ApiService();
      final studentLogin = await studentApi.login(testEmail, password);
      expect(studentLogin.isAdmin, isFalse);
      studentApi.close();

      await waitFor(
        () => find.text(updatedName).evaluate().isNotEmpty,
        'updated student card',
      );
      await tester.ensureVisible(find.byType(UserCard));
      await tester.tap(find.byTooltip('Thao tác sinh viên'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Hủy'));
      await tester.pumpAndSettle();
      expect(
        (await cleanupApi.getUsers(search: testEmail)).users,
        hasLength(1),
      );

      await tester.tap(find.byTooltip('Thao tác sinh viên'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Xóa sinh viên'));
      await waitFor(
        () => find.text('Không có kết quả phù hợp').evaluate().isNotEmpty,
        'delete student',
      );
      expect((await cleanupApi.getUsers(search: testEmail)).users, isEmpty);
      expect((await cleanupApi.getUsers()).total, originalCount);

      await tester.tap(find.byTooltip('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(auth.isAuthenticated, isFalse);
      await loginThroughForm('an.nguyen23@vku.udn.vn');
      await waitFor(
        () => find.text('Hồ sơ của tôi').evaluate().isNotEmpty,
        'ordinary student profile',
      );
      expect(find.byType(FloatingActionButton), findsNothing);
      await binding.takeScreenshot('android-student-profile');
      await tester.tap(find.byTooltip('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(auth.isAuthenticated, isFalse);
    } finally {
      if (cleanupApi.token != null) {
        final remaining = await cleanupApi.getUsers(search: testEmail);
        for (final user in remaining.users.where((u) => u.email == testEmail)) {
          await cleanupApi.deleteUser(user.id);
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
      api.close();
      cleanupApi.close();
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
