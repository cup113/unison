import 'package:flutter_riverpod/flutter_riverpod.dart';
import './services/timer_manager.dart';
import './services/todo_manager.dart';
import './services/auth_service.dart';
import './app_state_manager.dart';

final timerManagerProvider = ChangeNotifierProvider<TimerManager>((ref) {
  return TimerManager();
});

final todoManagerProvider = ChangeNotifierProvider<TodoManager>((ref) {
  return TodoManager();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final appStateManagerProvider = ChangeNotifierProvider<AppStateManager>((ref) {
  return AppStateManager(
    timerManager: ref.read(timerManagerProvider),
    todoManager: ref.read(todoManagerProvider),
    authService: ref.read(authServiceProvider),
  );
});

final isLoadingProvider = StateProvider<bool>((ref) => true);

final authStateProvider = FutureProvider<void>((ref) async {
  final appStateManager = ref.read(appStateManagerProvider);
  await appStateManager.initializeAuth();
  ref.read(isLoadingProvider.notifier).state = false;
});
