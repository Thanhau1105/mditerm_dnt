import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_theme.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key, required this.auth, this.user});
  final AuthService auth;
  final UserModel? user;

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _password = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  bool _picking = false;
  String? _error;
  late String _image;
  Uint8List? _preview;

  bool get _editing => widget.user != null;
  bool get _ownAccount =>
      _editing && widget.user?.id == widget.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user?.hoten ?? '');
    _email = TextEditingController(text: widget.user?.email ?? '');
    _image = widget.user?.hinhanh ?? '';
    _preview = widget.user?.imageBytes;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _supportedImage(Uint8List bytes) {
    final jpeg =
        bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255;
    final png =
        bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71 &&
        bytes[4] == 13 &&
        bytes[5] == 10 &&
        bytes[6] == 26 &&
        bytes[7] == 10;
    final webp =
        bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
    return jpeg || png || webp;
  }

  Future<void> _pickImage() async {
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 2 * 1024 * 1024) {
        setState(
          () => _error = 'Ảnh tối đa 2 MB. Hãy chọn ảnh có kích thước nhỏ hơn.',
        );
      } else if (!_supportedImage(bytes)) {
        setState(() => _error = 'Vui lòng chọn ảnh JPG, PNG hoặc WebP.');
      } else {
        setState(() {
          _preview = bytes;
          _image = base64Encode(bytes);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Không thể mở ảnh. Vui lòng thử lại hoặc chọn ảnh khác.',
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_editing) {
        final updated = await widget.auth.api.updateUser(
          widget.user!.id,
          hoten: _name.text.trim(),
          email: _email.text.trim(),
          matkhau: _password.text,
          hinhanh: _image,
        );
        if (!mounted) return;
        if (_ownAccount) {
          widget.auth.updateCurrentUser(updated);
          if (_password.text.isNotEmpty) {
            showAppMessage(context, 'Đã đổi mật khẩu. Vui lòng đăng nhập lại.');
            Navigator.of(context).pop(false);
            widget.auth.logout();
            return;
          }
        }
      } else {
        await widget.auth.api.createUser(
          hoten: _name.text.trim(),
          email: _email.text.trim(),
          matkhau: _password.text,
          hinhanh: _image,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        showAppMessage(
          context,
          'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          error: true,
        );
        Navigator.of(context).pop(false);
        widget.auth.logout();
      } else {
        setState(() => _error = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Không thể lưu sinh viên. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 580,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editing ? 'Chỉnh sửa sinh viên' : 'Thêm sinh viên',
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _editing
                                ? 'Cập nhật thông tin trong hồ sơ.'
                                : 'Tạo một hồ sơ mới trong hệ thống.',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.pop(context, false),
                      tooltip: 'Đóng',
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0FF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _preview == null
                          ? const Icon(
                              Icons.person_outline,
                              color: AppColors.blue,
                              size: 36,
                            )
                          : Image.memory(
                              _preview!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.muted,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _saving || _picking
                                    ? null
                                    : _pickImage,
                                icon: const Icon(
                                  Icons.upload_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  _picking ? 'Đang mở...' : 'Chọn ảnh',
                                ),
                              ),
                              if (_image.isNotEmpty)
                                TextButton(
                                  onPressed: _saving
                                      ? null
                                      : () {
                                          setState(() {
                                            _image = '';
                                            _preview = null;
                                          });
                                        },
                                  child: const Text('Gỡ ảnh'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'JPG, PNG, WebP · Tối đa 2 MB',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _name,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 2
                      ? 'Họ tên cần ít nhất 2 ký tự.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  enabled: !_saving && !_ownAccount,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: 'Email',
                    helperText: _ownAccount
                        ? 'Email quản trị được cấu hình trên server.'
                        : null,
                    prefixIcon: const Icon(Icons.alternate_email),
                  ),
                  validator: (value) =>
                      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch(value?.trim() ?? '')
                      ? 'Vui lòng nhập email hợp lệ.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  enabled: !_saving,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: _editing ? 'Mật khẩu mới' : 'Mật khẩu',
                    helperText: _editing
                        ? 'Để trống để giữ mật khẩu hiện tại.'
                        : 'Ít nhất 6 ký tự, tối đa 72 byte UTF-8.',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      tooltip: _obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (_editing && (value?.isEmpty ?? true)) return null;
                    if ((value?.length ?? 0) < 6) {
                      return 'Mật khẩu cần ít nhất 6 ký tự.';
                    }
                    if (utf8.encode(value!).length > 72) {
                      return 'Mật khẩu vượt quá 72 byte UTF-8.';
                    }
                    return null;
                  },
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFFB42318)),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _saving || _picking ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check, size: 18),
                        label: Text(_saving ? 'Đang lưu...' : 'Lưu thông tin'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
