import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vku_student_management/services/api_service.dart';
import 'package:vku_student_management/services/auth_service.dart';

void main() {
  const publicUser = {
    '_id': '507f1f77bcf86cd799439011',
    'email': 'hautt.23it@vku.udn.vn',
    'hoten': 'Trần Thành Hậu',
    'hinhanh': '',
  };

  test('Authenticated session forwards JWT and logout clears access', () async {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/auth/login')) {
        expect(jsonDecode(request.body), {
          'email': 'hautt.23it@vku.udn.vn',
          'matkhau': 'mật khẩu có dấu',
        });
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'token': 'test-jwt',
              'user': publicUser,
              'isAdmin': true,
            }),
          ),
          200,
        );
      }
      expect(request.headers['Authorization'], 'Bearer test-jwt');
      expect(request.url.queryParameters['search'], 'Hậu + VKU');
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'users': [publicUser],
            'total': 5,
          }),
        ),
        200,
      );
    });
    final api = ApiService(
      client: client,
      baseUrl: 'http://localhost:3000/api/',
    );
    final auth = AuthService(api);
    await auth.login(' HAUTT.23IT@VKU.UDN.VN ', 'mật khẩu có dấu');
    expect(auth.isAuthenticated, isTrue);
    expect(auth.isAdmin, isTrue);
    final result = await api.getUsers(search: 'Hậu + VKU');
    expect(result.users.single.hoten, 'Trần Thành Hậu');
    expect(result.total, 5);
    auth.logout();
    expect(api.token, isNull);
    expect(auth.currentUser, isNull);
    expect(auth.isAuthenticated, isFalse);
    auth.dispose();
    api.close();
  });

  test('Duplicate email message and 409 survive API boundary', () async {
    final api = ApiService(
      client: MockClient(
        (request) async => http.Response.bytes(
          utf8.encode(jsonEncode({'message': 'Email đã tồn tại.'})),
          409,
        ),
      ),
    );
    await expectLater(
      api.createUser(
        hoten: 'Sinh viên',
        email: 'a@vku.udn.vn',
        matkhau: 'Vku@123456',
        hinhanh: '',
      ),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 409)
            .having((e) => e.message, 'message', 'Email đã tồn tại.'),
      ),
    );
    api.close();
  });

  test('Connection failure is translated into an actionable error', () async {
    final api = ApiService(
      client: MockClient((request) async {
        throw http.ClientException('Connection refused');
      }),
    );
    await expectLater(
      api.getUsers(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Không kết nối'),
        ),
      ),
    );
    api.close();
  });

  test(
    'Editing sends an empty password without fetching an old hash',
    () async {
      final api = ApiService(
        client: MockClient((request) async {
          expect(request.method, 'PUT');
          expect((jsonDecode(request.body) as Map)['matkhau'], '');
          return http.Response.bytes(
            utf8.encode(jsonEncode({'user': publicUser})),
            200,
          );
        }),
      );
      final user = await api.updateUser(
        publicUser['_id']!,
        hoten: 'Trần Thành Hậu',
        email: publicUser['email']!,
        matkhau: '',
        hinhanh: '',
      );
      expect(user.toJson().containsKey('matkhau'), isFalse);
      api.close();
    },
  );
}
