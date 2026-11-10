import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vku_student_management/main.dart';
import 'package:vku_student_management/services/api_service.dart';
import 'package:vku_student_management/services/auth_service.dart';

const _admin = {
  '_id': '507f1f77bcf86cd799439011',
  'email': 'hautt.23it@vku.udn.vn',
  'hoten': 'Trần Thành Hậu',
  'hinhanh': '',
};
const _student = {
  '_id': '507f1f77bcf86cd799439012',
  'email': 'chau@vku.udn.vn',
  'hoten': 'Nguyễn Minh Châu',
  'hinhanh': '',
};

http.Response _json(Object body, [int status = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), status);

Future<AuthService> _pumpDashboard(
  WidgetTester tester, {
  double width = 1440,
  Future<http.Response> Function(http.Request request)? handle,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final api = ApiService(
    client: MockClient((request) async {
      if (request.url.path.endsWith('/auth/login')) {
        return _json({
          'token': 'widget-admin-token',
          'user': _admin,
          'isAdmin': true,
        });
      }
      if (handle != null) return handle(request);
      return _json({
        'users': [_admin, _student],
        'total': 2,
      });
    }),
  );
  final auth = AuthService(api);
  await auth.login('hautt.23it@vku.udn.vn', 'Vku@123456');
  await tester.pumpWidget(VkuApp(auth: auth));
  await tester.pumpAndSettle();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
    api.close();
  });
  return auth;
}

void main() {
  for (final width in [320.0, 390.0, 960.0, 1440.0]) {
    testWidgets(
      'Authenticated dashboard loads without overflow at ${width.toInt()}px',
      (tester) async {
        await _pumpDashboard(tester, width: width);
        expect(find.text('Tổng số sinh viên'), findsOneWidget);
        expect(find.text('Nguyễn Minh Châu'), findsOneWidget);
        await tester.ensureVisible(find.text('Nguyễn Minh Châu'));
        await tester.pumpAndSettle();
        expect(find.text('chau@vku.udn.vn'), findsOneWidget);
      },
    );
  }

  testWidgets('Dashboard retries a failed request and searches the backend', (
    tester,
  ) async {
    var attempts = 0;
    final queries = <String>[];
    await _pumpDashboard(
      tester,
      width: 390,
      handle: (request) async {
        attempts++;
        if (attempts == 1) {
          return _json({'message': 'Kết nối tạm thời gián đoạn.'}, 503);
        }
        final search = request.url.queryParameters['search'] ?? '';
        queries.add(search);
        return _json({
          'users': search.isEmpty ? [_admin, _student] : [],
          'total': 2,
        });
      },
    );
    expect(find.text('Kết nối tạm thời gián đoạn.'), findsOneWidget);
    final retry = find.widgetWithText(OutlinedButton, 'Thử lại');
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(find.text('Nguyễn Minh Châu'), findsOneWidget);
    final search = find.byType(TextField);
    await tester.ensureVisible(search);
    await tester.pumpAndSettle();
    await tester.enterText(search, 'không tìm thấy');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(queries.last, 'không tìm thấy');
    expect(find.text('Không có kết quả phù hợp'), findsOneWidget);
    expect(find.text('Nguyễn Minh Châu'), findsNothing);
  });

  testWidgets(
    'Canceling deletion leaves the record and sends no DELETE request',
    (tester) async {
      var deleteCalls = 0;
      await _pumpDashboard(
        tester,
        handle: (request) async {
          if (request.method == 'DELETE') deleteCalls++;
          return _json({
            'users': [_admin, _student],
            'total': 2,
          });
        },
      );
      await tester.tap(find.byTooltip('Xóa Nguyễn Minh Châu'));
      await tester.pumpAndSettle();
      expect(find.text('Xóa sinh viên?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Hủy'));
      await tester.pumpAndSettle();
      expect(deleteCalls, 0);
      expect(find.text('Nguyễn Minh Châu'), findsOneWidget);
      expect(find.text('Xóa sinh viên?'), findsNothing);
    },
  );

  testWidgets('Expired admin session returns to login', (tester) async {
    final auth = await _pumpDashboard(
      tester,
      handle: (_) async =>
          _json({'message': 'Phiên đăng nhập đã hết hạn.'}, 401),
    );
    expect(auth.isAuthenticated, isFalse);
    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Danh sách sinh viên'), findsNothing);
  });
}
