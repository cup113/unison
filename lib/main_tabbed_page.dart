import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tabs/focus_tab.dart';
import 'tabs/social_tab.dart';
import 'tabs/account_tab.dart';
import 'tabs/statistics_tab.dart';
import 'providers.dart';

class MainTabbedPage extends ConsumerStatefulWidget {
  const MainTabbedPage({super.key});

  @override
  ConsumerState<MainTabbedPage> createState() => _MainTabbedPageState();
}

class _MainTabbedPageState extends ConsumerState<MainTabbedPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeManagers();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initializeManagers() async {
    final timerManager = ref.read(timerManagerProvider);
    final todoManager = ref.read(todoManagerProvider);

    await todoManager.loadFromStorage();
    await timerManager.loadFromStorage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      final timerManager = ref.read(timerManagerProvider);
      if (timerManager.remainingSeconds != null &&
          timerManager.remainingSeconds! > 0) {
        timerManager.handleAppExit();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('初始化失败'),
              Text(error.toString()),
              ElevatedButton(
                onPressed: () => ref.refresh(authStateProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
      data: (_) {
        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) return;
            SystemNavigator.pop();
          },
          child: Scaffold(
            body: TabBarView(
              controller: _tabController,
              physics:
                  const NeverScrollableScrollPhysics(), // Prevent swiping between tabs
              children: [
                const FocusTab(),
                const SocialTab(),
                const AccountTab(),
                const StatisticsTab(),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.timer),
                    text: '专注',
                  ),
                  Tab(
                    icon: Icon(Icons.people),
                    text: '社交',
                  ),
                  Tab(
                    icon: Icon(Icons.person),
                    text: '账户',
                  ),
                  Tab(
                    icon: Icon(Icons.bar_chart),
                    text: '统计',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
