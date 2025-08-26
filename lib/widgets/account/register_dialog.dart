import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';

class RegisterDialog extends ConsumerStatefulWidget {
  final bool isLoggedIn;
  final void Function() onRegisterSuccess;

  const RegisterDialog(
      {super.key, required this.isLoggedIn, required this.onRegisterSuccess});

  @override
  ConsumerState<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends ConsumerState<RegisterDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  bool _isAuthLoading = false;
  String? _passwordError;
  String? _registerError;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('注册'),
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
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
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
                onChanged: (_) => _clearErrors(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordConfirmController,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  border: const OutlineInputBorder(),
                  errorText: _passwordError,
                ),
                obscureText: true,
                onChanged: (_) => _clearErrors(),
              ),
              if (_registerError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _registerError!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
              const SizedBox(height: 24),
              if (_isAuthLoading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text('注册'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearErrors() {
    if (_passwordError != null || _registerError != null) {
      setState(() {
        _passwordError = null;
        _registerError = null;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() {
        _passwordError = '密码不匹配';
      });
      return;
    }

    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      return;
    }

    setState(() {
      _isAuthLoading = true;
      _registerError = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.register(
        name: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      ref.read(accountServiceProvider).storeUserInfo(response.user);
      ref.read(accountServiceProvider).storeToken(response.token);
      widget.onRegisterSuccess();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注册成功')),
        );
      }
    } catch (e) {
      setState(() {
        _registerError = e.toString();
      });
    } finally {
      setState(() {
        _isAuthLoading = false;
      });
    }
  }
}
