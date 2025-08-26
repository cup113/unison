import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../widgets/account/account_header.dart';
import '../widgets/account/account_actions.dart';
import '../widgets/account/app_info.dart';

class AccountTab extends ConsumerStatefulWidget {
  const AccountTab({super.key});

  @override
  ConsumerState<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends ConsumerState<AccountTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccountStatus();
  }

  Future<void> _loadAccountStatus() async {
    // TODO
    try {
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountService = ref.watch(accountServiceProvider);
    accountService.getUserData();
    final isLoggedIn = accountService.userData != null;
    final username = accountService.userData?.name ?? '未登录';
    final email = accountService.userData?.email ?? '---';
    final id = accountService.userData?.id ?? '---';

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
            AccountHeader(
              isLoggedIn: isLoggedIn,
              username: username,
              email: email,
              id: id,
            ),
            const SizedBox(height: 24),
            AccountActions(
              isLoggedIn: isLoggedIn,
              username: username,
              email: email,
              onRefresh: () {
                setState(() {});
              },
            ),
            const SizedBox(height: 24),
            const AppInfo(),
          ],
        ),
      ),
    );
  }
}
