import 'dart:convert';
import 'dart:typed_data';

/// API responses deliberately never include the stored password hash.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.hoten,
    required this.hinhanh,
  });

  final String id;
  final String email;
  final String hoten;
  final String hinhanh;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['_id'] as String,
    email: json['email'] as String,
    hoten: json['hoten'] as String,
    hinhanh: json['hinhanh'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'hoten': hoten,
    'hinhanh': hinhanh,
  };

  Uint8List? get imageBytes {
    if (hinhanh.isEmpty) return null;
    try {
      return base64Decode(hinhanh);
    } on FormatException {
      return null;
    }
  }

  String get initials {
    final words = hoten.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    if (words.isEmpty) return 'SV';
    return words
        .toList()
        .reversed
        .take(2)
        .toList()
        .reversed
        .map((word) => String.fromCharCodes([word.runes.first]))
        .join()
        .toUpperCase();
  }
}
