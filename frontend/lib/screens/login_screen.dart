import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});
  final AuthService auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.auth.login(_email.text.trim(), _password.text);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Không thể đăng nhập. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _formContent({required bool desktop}) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 420),
    child: AutofillGroup(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!desktop) ...[const VkuBrand(), const SizedBox(height: 48)],
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CỔNG QUẢN LÝ SINH VIÊN',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Chào mừng trở lại',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 30,
                height: 1.2,
                fontWeight: FontWeight.w800,
                letterSpacing: -.7,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Đăng nhập để truy cập VKU Student Management.',
              style: TextStyle(
                color: AppColors.muted,
                height: 1.6,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 36),
            TextFormField(
              controller: _email,
              enabled: !_loading,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Nhập email của bạn',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (value) =>
                  !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                      .hasMatch(value?.trim() ?? '')
                  ? 'Vui lòng nhập email hợp lệ.'
                  : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _password,
              enabled: !_loading,
              autofillHints: const [AutofillHints.password],
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                hintText: 'Nhập mật khẩu',
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
              validator: (value) =>
                  (value?.isEmpty ?? true) ? 'Vui lòng nhập mật khẩu.' : null,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFB42318),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFB42318),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _loading ? null : _login,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_loading) ...[
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      _loading ? 'Đang đăng nhập...' : 'Đăng nhập',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (!_loading) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 17,
                  color: AppColors.muted,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sử dụng tài khoản được cấp bởi quản trị viên.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
            if (!desktop) ...[
              const SizedBox(height: 52),
              const Text(
                'TRƯỜNG ĐẠI HỌC CNTT & TT VIỆT – HÀN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1000;
        if (!desktop) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                child: _formContent(desktop: false),
              ),
            ),
          );
        }
        return Row(
          children: [
            const Expanded(child: _BrandPanel()),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: _formContent(desktop: true),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0B2143), Color(0xFF143F78)],
      ),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const VkuBrand(light: true),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .08),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .15),
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'VKU · ĐẠI HỌC ĐÀ NẴNG',
                          style: TextStyle(
                            color: Color(0xFFB5D3FF),
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Kết nối tri thức.\nQuản lý dễ dàng.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.18,
                          fontSize: 43,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Một không gian tập trung để quản lý hồ sơ\nvà đồng hành cùng sinh viên VKU.',
                        style: TextStyle(
                          color: Color(0xFFB5C9E4),
                          fontSize: 15,
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 38),
                      _feature(
                        Icons.badge_outlined,
                        'Hồ sơ sinh viên',
                        'Thông tin rõ ràng, cập nhật dễ dàng',
                      ),
                      const SizedBox(height: 20),
                      _feature(
                        Icons.search_rounded,
                        'Tra cứu nhanh chóng',
                        'Tìm kiếm theo họ tên và email',
                      ),
                      const SizedBox(height: 20),
                      _feature(
                        Icons.devices_rounded,
                        'Linh hoạt mọi thiết bị',
                        'Trải nghiệm trên web và điện thoại',
                      ),
                    ],
                  ),
                ),
                const Text(
                  'TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN\nVÀ TRUYỀN THÔNG VIỆT – HÀN',
                  style: TextStyle(
                    color: Color(0xFF91ADCF),
                    fontSize: 10,
                    height: 1.7,
                    letterSpacing: .9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _feature(IconData icon, String title, String subtitle) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF9BC2FF), size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFFA4BDDB), fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );
}
