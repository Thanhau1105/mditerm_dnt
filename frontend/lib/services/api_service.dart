import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class LoginResult {
  const LoginResult({
    required this.token,
    required this.user,
    required this.isAdmin,
  });
  final String token;
  final UserModel user;
  final bool isAdmin;
}

class UserListResult {
  const UserListResult({required this.users, required this.total});
  final List<UserModel> users;
  final int total;
}

/// Every production operation goes to the real Express API.
/// Override using `--dart-define=API_BASE_URL=http://server:3000/api`.
class ApiService {
  ApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = (baseUrl ?? _defaultBaseUrl).replaceFirst(RegExp(r'/+$'), '');

  final http.Client _client;
  final String baseUrl;
  String? token;

  static String get _defaultBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json; charset=utf-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    try {
      final encoded = body == null ? null : jsonEncode(body);
      final operation = switch (method) {
        'GET' => _client.get(uri, headers: headers),
        'POST' => _client.post(uri, headers: headers, body: encoded),
        'PUT' => _client.put(uri, headers: headers, body: encoded),
        'DELETE' => _client.delete(uri, headers: headers),
        _ => throw ArgumentError('Unsupported HTTP method: $method'),
      };
      final response = await operation.timeout(const Duration(seconds: 25));
      Map<String, dynamic> data = {};
      if (response.bodyBytes.isNotEmpty) {
        try {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is Map<String, dynamic>) data = decoded;
        } on FormatException {
          throw const ApiException(
            'Máy chủ trả về dữ liệu không hợp lệ. Kiểm tra địa chỉ API.',
          );
        }
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          data['message'] as String? ??
              'Không thể xử lý yêu cầu. Vui lòng thử lại.',
          statusCode: response.statusCode,
        );
      }
      return data;
    } on TimeoutException {
      throw const ApiException('Máy chủ phản hồi quá lâu. Vui lòng thử lại.');
    } on http.ClientException {
      throw const ApiException(
        'Không kết nối được máy chủ. Kiểm tra backend, mạng và địa chỉ API.',
      );
    }
  }

  Future<LoginResult> login(String email, String password) async {
    final data = await _request(
      'POST',
      '/auth/login',
      body: {'email': email.trim().toLowerCase(), 'matkhau': password},
    );
    return LoginResult(
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      isAdmin: data['isAdmin'] as bool,
    );
  }

  Future<UserListResult> getUsers({
    String search = '',
    String sort = 'asc',
  }) async {
    final data = await _request(
      'GET',
      '/users',
      query: {'search': search.trim(), 'sort': sort},
    );
    return UserListResult(
      users: (data['users'] as List<dynamic>)
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int,
    );
  }

  Future<UserModel> getUser(String id) async {
    final data = await _request('GET', '/users/${Uri.encodeComponent(id)}');
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> createUser({
    required String hoten,
    required String email,
    required String matkhau,
    required String hinhanh,
  }) async {
    final data = await _request(
      'POST',
      '/users',
      body: {
        'hoten': hoten.trim(),
        'email': email.trim().toLowerCase(),
        'matkhau': matkhau,
        'hinhanh': hinhanh,
      },
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateUser(
    String id, {
    required String hoten,
    required String email,
    required String matkhau,
    required String hinhanh,
  }) async {
    final data = await _request(
      'PUT',
      '/users/${Uri.encodeComponent(id)}',
      body: {
        'hoten': hoten.trim(),
        'email': email.trim().toLowerCase(),
        'matkhau': matkhau,
        'hinhanh': hinhanh,
      },
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> deleteUser(String id) async {
    await _request('DELETE', '/users/${Uri.encodeComponent(id)}');
  }

  void close() => _client.close();
}
