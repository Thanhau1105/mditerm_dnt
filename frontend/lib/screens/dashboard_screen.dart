import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/user_card.dart';
import 'user_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.auth});
  final AuthService auth;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _listKey = GlobalKey<UserListScreenState>();

  Widget _sidebar() {
    final user = widget.auth.currentUser!;
    return Container(
      width: 248,
      color: AppColors.navy,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VkuBrand(light: true),
              const SizedBox(height: 46),
              const Text(
                'KHÔNG GIAN QUẢN TRỊ',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8FAACB),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.groups_2_outlined,
                      size: 22,
                      color: Colors.white,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Quản lý sinh viên',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: Color(0xFF9BC2FF),
                      size: 24,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'VKU Student Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Quản lý hồ sơ sinh viên\ntrong một không gian chung.',
                      style: TextStyle(
                        color: Color(0xFF9BB5D6),
                        height: 1.6,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  StudentAvatar(user: user, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.hoten,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Quản trị viên',
                          style: TextStyle(
                            color: Color(0xFF9BB5D6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: widget.auth.logout,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFBDD1EB),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workspace(bool desktop) => Column(
    children: [
      if (desktop)
        Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Icon(Icons.home_outlined, size: 19, color: AppColors.muted),
              const SizedBox(width: 12),
              const Text(
                'Quản trị',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.muted,
                ),
              ),
              const Text(
                'Sinh viên',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              const Text(
                'VKU Student Management',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: widget.auth.logout,
                tooltip: 'Đăng xuất',
                icon: const Icon(
                  Icons.logout,
                  size: 20,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            desktop ? 32 : 16,
            desktop ? 30 : 22,
            desktop ? 32 : 16,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản lý sinh viên',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: desktop ? 28 : 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Xin chào, ${widget.auth.currentUser!.hoten}. Chúc bạn một ngày làm việc hiệu quả!',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.6,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: UserListScreen(key: _listKey, auth: widget.auth),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if (!widget.auth.isAdmin) return _StudentProfile(auth: widget.auth);
    final desktop = MediaQuery.sizeOf(context).width >= 960;
    return Scaffold(
      appBar: desktop
          ? null
          : AppBar(
              title: const Text(
                'VKU Student Management',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              leading: const Padding(
                padding: EdgeInsets.all(10),
                child: VkuBrand(compact: true),
              ),
              actions: [
                IconButton(
                  onPressed: widget.auth.logout,
                  tooltip: 'Đăng xuất',
                  icon: const Icon(Icons.logout, size: 21),
                ),
                const SizedBox(width: 6),
              ],
            ),
      body: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sidebar(),
                Expanded(child: _workspace(true)),
              ],
            )
          : SafeArea(child: _workspace(false)),
      floatingActionButton: desktop
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _listKey.currentState?.openForm(),
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Thêm sinh viên'),
            ),
    );
  }
}

class _StudentProfile extends StatelessWidget {
  const _StudentProfile({required this.auth});
  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
        actions: [
          IconButton(
            onPressed: auth.logout,
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VkuBrand(),
                  const SizedBox(height: 36),
                  StudentAvatar(user: user, size: 96),
                  const SizedBox(height: 22),
                  Text(
                    user.hoten,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    user.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    'Tài khoản sinh viên',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Liên hệ quản trị viên khi cần cập nhật thông tin hồ sơ.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  OutlinedButton.icon(
                    onPressed: auth.logout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Đăng xuất'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
