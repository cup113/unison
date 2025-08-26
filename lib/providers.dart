import 'package:flutter_riverpod/flutter_riverpod.dart';
import './services/timer_manager.dart';
import './services/todo_manager.dart';
import './services/account_service.dart';
import './api/unison_api_service.dart';
import './app_state_manager.dart';

final timerManagerProvider = ChangeNotifierProvider<TimerManager>((ref) {
  return TimerManager();
});

final todoManagerProvider = ChangeNotifierProvider<TodoManager>((ref) {
  return TodoManager();
});

final apiServiceProvider = Provider<UnisonApiService>((ref) {
  return UnisonApiService();
});

final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService();
});

final appStateManagerProvider = ChangeNotifierProvider<AppStateManager>((ref) {
  return AppStateManager(
    timerManager: ref.read(timerManagerProvider),
    todoManager: ref.read(todoManagerProvider),
    apiService: ref.read(apiServiceProvider),
  );
});

final isLoadingProvider = StateProvider<bool>((ref) => true);

final authStateProvider = FutureProvider<void>((ref) async {
  final accountService = AccountService();
  await accountService.getUserData();
  ref.read(isLoadingProvider.notifier).state = false;
});
