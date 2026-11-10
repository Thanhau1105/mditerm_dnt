import 'package:flutter/material.dart';

import '../models/user_model.dart';
import 'app_theme.dart';

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({super.key, required this.user, this.size = 46});
  final UserModel user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bytes = user.imageBytes;
    final fallback = Center(
      child: Text(
        user.initials,
        style: TextStyle(
          color: AppColors.blue,
          fontWeight: FontWeight.w700,
          fontSize: size * .32,
        ),
      ),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes == null
          ? fallback
          : Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    this.busy = false,
    this.isCurrentUser = false,
  });
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool busy;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        StudentAvatar(user: user, size: 48),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.hoten,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user.email,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              if (isCurrentUser)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Tài khoản của bạn',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blue,
                    ),
                  ),
                ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Thao tác sinh viên',
          enabled: !busy,
          onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              enabled: !isCurrentUser,
              child: const Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Color(0xFFB42318),
                  ),
                  SizedBox(width: 10),
                  Text('Xóa'),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
