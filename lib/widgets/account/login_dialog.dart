import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';

class LoginDialog extends ConsumerStatefulWidget {
  final bool isLoggedIn;

  const LoginDialog({super.key, required this.isLoggedIn});

  @override
  ConsumerState<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends ConsumerState<LoginDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAuthLoading = false;
  String? _loginError;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('登录'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_isAuthLoading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('登录'),
                  ),
                ),
              if (_loginError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _loginError!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    setState(() {
      _isAuthLoading = true;
      _loginError = null;
    });

    try {
      await ref.read(apiServiceProvider).login(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录成功')),
        );
      }
    } catch (e) {
      setState(() {
        _loginError = e.toString();
      });
    } finally {
      setState(() {
        _isAuthLoading = false;
      });
    }
  }
}
