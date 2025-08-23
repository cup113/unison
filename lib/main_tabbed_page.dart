import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'focus_timer_page.dart';
import 'social_page.dart';
import 'account_page.dart';
import 'statistics_page.dart';
import 'app_state_manager.dart';
import 'timer_manager.dart';
import 'todo_manager.dart';
import 'auth_service.dart';

class MainTabbedPage extends StatefulWidget {
  const MainTabbedPage({super.key});

  @override
  State<MainTabbedPage> createState() => _MainTabbedPageState();
}

class _MainTabbedPageState extends State<MainTabbedPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late AppStateManager _appStateManager;
  late TimerManager _timerManager;
  late TodoManager _todoManager;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initManagers();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initManagers() async {
    _timerManager = TimerManager();
    _todoManager = TodoManager();
    final authService = AuthService();

    await _todoManager.loadFromStorage();
    await _timerManager.loadFromStorage();

    _appStateManager = AppStateManager(
      timerManager: _timerManager,
      todoManager: _todoManager,
      authService: authService,
    );

    await _appStateManager.initializeAuth();

    _tabController = TabController(
      length: 4,
      vsync: this,
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _appStateManager.dispose();
    _timerManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      if (_timerManager.remainingSeconds != null &&
          _timerManager.remainingSeconds! > 0) {
        // Use try-catch to handle potential disposed state
        try {
          _timerManager.handleAppExit();
        } catch (e) {
          // TimerManager might be disposed, ignore the error
          debugPrint('TimerManager disposed: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            FocusTab(appStateManager: _appStateManager),
            SocialTab(appStateManager: _appStateManager),
            AccountTab(appStateManager: _appStateManager),
            StatisticsTab(appStateManager: _appStateManager),
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
  }
}
