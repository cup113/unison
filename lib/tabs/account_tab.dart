import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers.dart';

class AccountTab extends ConsumerStatefulWidget {
  const AccountTab({super.key});

  @override
  ConsumerState<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends ConsumerState<AccountTab> {
  bool _isLoading = true;
  bool _syncEnabled = false;
  bool _isAuthLoading = false;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadAccountStatus();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  Future<void> _loadAccountStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _syncEnabled = prefs.getBool('sync_enabled') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _syncEnabled = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAccountStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sync_enabled', _syncEnabled);
  }

  void _showLoginDialog(bool isLoggedIn) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('登录'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              if (_isAuthLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: _isAuthLoading
                  ? null
                  : () => _handleLogin(
                        emailController,
                        passwordController,
                        context,
                        setState,
                      ),
              child: _isAuthLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(
    TextEditingController emailController,
    TextEditingController passwordController,
    BuildContext dialogContext,
    StateSetter dialogSetState,
  ) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return;
    }

    final currentContext = dialogContext;
    dialogSetState(() {
      _isAuthLoading = true;
    });

    try {
      await ref.read(appStateManagerProvider).login(
            emailController.text,
            passwordController.text,
          );

      if (currentContext.mounted) {
        Navigator.pop(currentContext);
      }
      await _loadAccountStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      dialogSetState(() {
        _isAuthLoading = false;
      });
    }
  }

  void _showRegisterDialog(bool isLoggedIn) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('注册'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              if (_isAuthLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: _isAuthLoading
                  ? null
                  : () => _handleRegister(
                        usernameController,
                        emailController,
                        passwordController,
                        context,
                        setState,
                      ),
              child: _isAuthLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('注册'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister(
    TextEditingController usernameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    BuildContext dialogContext,
    StateSetter dialogSetState,
  ) async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      return;
    }

    final currentContext = dialogContext;
    dialogSetState(() {
      _isAuthLoading = true;
    });

    try {
      await ref.read(appStateManagerProvider).register(
            usernameController.text,
            emailController.text,
            passwordController.text,
          );

      if (currentContext.mounted) {
        Navigator.pop(currentContext);
      }
      await _loadAccountStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注册成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      dialogSetState(() {
        _isAuthLoading = false;
      });
    }
  }

  void _logout(bool isLoggedIn) {
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
            onPressed: () => _handleLogout(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext dialogContext) async {
    final currentContext = dialogContext;
    try {
      await ref.read(appStateManagerProvider).logout();
      await _loadAccountStatus();
      _saveAccountStatus();
      if (currentContext.mounted) {
        Navigator.pop(currentContext);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已退出登录')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('退出登录失败: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStateManager = ref.watch(appStateManagerProvider);
    final isLoggedIn = appStateManager.isLoggedIn;
    final username = appStateManager.username;
    final email = appStateManager.email;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('账户'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountHeader(isLoggedIn, username, email),
            const SizedBox(height: 24),
            _buildAccountActions(isLoggedIn, username, email),
            const SizedBox(height: 24),
            _buildAppInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountHeader(bool isLoggedIn, String username, String email) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                isLoggedIn ? username[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoggedIn ? username : '未登录',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isLoggedIn) ...[
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '已登录',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '登录以同步数据',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions(bool isLoggedIn, String username, String email) {
    return Card(
      child: Column(
        children: [
          if (!isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('登录'),
              onTap: () => _showLoginDialog(isLoggedIn),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('注册'),
              onTap: () => _showRegisterDialog(isLoggedIn),
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('退出登录'),
              onTap: () => _logout(isLoggedIn),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '应用信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            subtitle: Text('Unison ${_packageInfo?.version}'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Unison',
                applicationVersion:
                    '${_packageInfo?.version} (${_packageInfo?.buildNumber})',
                applicationLegalese: '© 2025 Jason Li',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('帮助与反馈'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('帮助功能开发中')),
              );
            },
          ),
        ],
      ),
    );
  }
}
