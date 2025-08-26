import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './login_dialog.dart';
import './register_dialog.dart';
import '../../providers.dart';

class AccountActions extends ConsumerWidget {
  final bool isLoggedIn;
  final String username;
  final String email;

  const AccountActions({
    super.key,
    required this.isLoggedIn,
    required this.username,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          if (!isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('登录'),
              onTap: () => _showLoginDialog(context),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('注册'),
              onTap: () => _showRegisterDialog(context),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑资料'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('编辑资料功能开发中')),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('退出登录'),
              onTap: () => _logout(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LoginDialog(isLoggedIn: isLoggedIn),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RegisterDialog(isLoggedIn: isLoggedIn),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => _handleLogout(context, ref),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(accountServiceProvider).logout();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已退出登录')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('退出登录失败: ${e.toString()}')),
        );
      }
    }
  }
}
