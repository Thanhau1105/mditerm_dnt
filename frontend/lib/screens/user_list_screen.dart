import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/user_card.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key, required this.auth});
  final AuthService auth;

  @override
  State<UserListScreen> createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<UserModel> _users = [];
  int _total = 0;
  int _requestId = 0;
  bool _loading = true;
  String _sort = 'asc';
  String? _error;
  String? _deleting;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _requestId++;
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final request = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.auth.api.getUsers(
        search: _search.text.trim(),
        sort: _sort,
      );
      if (!mounted || request != _requestId) return;
      setState(() {
        _users = result.users;
        _total = result.total;
      });
    } on ApiException catch (error) {
      if (!mounted || request != _requestId) return;
      if (error.statusCode == 401) {
        showAppMessage(
          context,
          'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          error: true,
        );
        widget.auth.logout();
        return;
      }
      setState(() => _error = error.message);
    } catch (_) {
      if (mounted && request == _requestId) {
        setState(() => _error = 'Không thể tải danh sách. Vui lòng thử lại.');
      }
    } finally {
      if (mounted && request == _requestId) setState(() => _loading = false);
    }
  }

  void _searchChanged(String value) {
    _debounce?.cancel();
    _requestId++;
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  Future<void> openForm([UserModel? user]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserFormScreen(auth: widget.auth, user: user),
    );
    if (!mounted || saved != true) return;
    showAppMessage(
      context,
      user == null ? 'Đã thêm sinh viên.' : 'Đã cập nhật sinh viên.',
    );
    await _load();
  }

  Future<void> _delete(UserModel user) async {
    if (_deleting != null || user.id == widget.auth.currentUser?.id) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.delete_outline,
          color: Color(0xFFB42318),
          size: 32,
        ),
        title: const Text('Xóa sinh viên?'),
        content: Text(
          'Bạn muốn xóa hồ sơ của ${user.hoten}? Dữ liệu đã xóa không thể khôi phục.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa sinh viên'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _deleting = user.id);
    try {
      await widget.auth.api.deleteUser(user.id);
      if (!mounted) return;
      showAppMessage(context, 'Đã xóa hồ sơ sinh viên.');
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppMessage(context, error.message, error: true);
      if (error.statusCode == 401) widget.auth.logout();
    } catch (_) {
      if (mounted) {
        showAppMessage(
          context,
          'Không thể xóa sinh viên. Vui lòng thử lại.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = null);
    }
  }

  Widget _statistics(bool desktop) => Container(
    padding: EdgeInsets.all(desktop ? 24 : 18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.groups_2_outlined,
            color: AppColors.blue,
            size: 28,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng số sinh viên',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                _loading && _total == 0 ? '—' : '$_total',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
        if (desktop)
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Hồ sơ tập trung',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tra cứu và cập nhật tại một nơi',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _searchField() => TextField(
    controller: _search,
    onChanged: _searchChanged,
    decoration: InputDecoration(
      hintText: 'Tìm theo họ tên hoặc email...',
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: _search.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Xóa tìm kiếm',
              icon: const Icon(Icons.close, size: 19),
              onPressed: () {
                _search.clear();
                _searchChanged('');
              },
            ),
    ),
  );

  Widget _sortField() => DropdownButtonFormField<String>(
    initialValue: _sort,
    isExpanded: true,
    decoration: const InputDecoration(
      labelText: 'Sắp xếp theo tên',
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    items: const [
      DropdownMenuItem(value: 'asc', child: Text('Tên A → Z')),
      DropdownMenuItem(value: 'desc', child: Text('Tên Z → A')),
    ],
    onChanged: (value) {
      if (value == null) return;
      _debounce?.cancel();
      setState(() => _sort = value);
      _load();
    },
  );

  Widget _toolbar(bool desktop) => Column(
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Danh sách sinh viên',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _load,
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.muted),
          ),
          if (desktop) ...[
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => openForm(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Thêm sinh viên'),
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
      if (desktop)
        Row(
          children: [
            Expanded(child: _searchField()),
            const SizedBox(width: 14),
            SizedBox(width: 190, child: _sortField()),
          ],
        )
      else ...[
        _searchField(),
        const SizedBox(height: 14),
        _sortField(),
      ],
    ],
  );

  Widget _empty({required bool isError}) {
    final searching = _search.text.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                isError
                    ? Icons.cloud_off_outlined
                    : searching
                    ? Icons.search_off_rounded
                    : Icons.people_outline,
                size: 34,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isError
                  ? 'Chưa thể tải dữ liệu'
                  : searching
                  ? 'Không có kết quả phù hợp'
                  : 'Chưa có sinh viên',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isError
                  ? _error!
                  : searching
                  ? 'Thử tìm bằng họ tên hoặc email khác.'
                  : 'Thêm sinh viên đầu tiên để bắt đầu quản lý.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            if (isError)
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              )
            else if (searching)
              OutlinedButton(
                onPressed: () {
                  _search.clear();
                  _searchChanged('');
                },
                child: const Text('Xóa tìm kiếm'),
              )
            else
              FilledButton.icon(
                onPressed: () => openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Thêm sinh viên'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _table() => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            headingRowColor: const WidgetStatePropertyAll(Color(0xFFF8FAFD)),
            headingRowHeight: 48,
            dataRowMinHeight: 76,
            dataRowMaxHeight: 76,
            columnSpacing: 24,
            horizontalMargin: 24,
            dividerThickness: .6,
            headingTextStyle: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            columns: const [
              DataColumn(label: Text('STT')),
              DataColumn(label: Text('SINH VIÊN')),
              DataColumn(label: Text('EMAIL')),
              DataColumn(label: Text('THAO TÁC')),
            ],
            rows: _users.indexed.map((entry) {
              final (index, user) = entry;
              final own = user.id == widget.auth.currentUser?.id;
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        StudentAvatar(user: user, size: 42),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 210,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.hoten,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.navy,
                                ),
                              ),
                              if (own)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Tài khoản của bạn',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.blue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 240,
                      child: Text(
                        user.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _deleting == null
                              ? () => openForm(user)
                              : null,
                          tooltip: 'Chỉnh sửa ${user.hoten}',
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 19,
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: own || _deleting != null
                              ? null
                              : () => _delete(user),
                          tooltip: own
                              ? 'Không thể xóa tài khoản đang đăng nhập'
                              : 'Xóa ${user.hoten}',
                          icon: _deleting == user.id
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: own
                                      ? Colors.grey.shade300
                                      : const Color(0xFFB42318),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 720;
      return RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _statistics(desktop)),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(child: _toolbar(desktop)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _empty(isError: true),
              )
            else if (_users.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _empty(isError: false),
              )
            else ...[
              if (desktop)
                SliverToBoxAdapter(child: _table())
              else
                SliverList.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) => UserCard(
                    user: _users[index],
                    busy: _deleting != null,
                    isCurrentUser:
                        _users[index].id == widget.auth.currentUser?.id,
                    onEdit: () => openForm(_users[index]),
                    onDelete: () => _delete(_users[index]),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Hiển thị ${_users.length} / $_total hồ sơ',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      );
    },
  );
}
