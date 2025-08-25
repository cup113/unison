class AppConstants {
  static const List<int> presetDurations = [
    2,
    5,
    10,
    15,
    20,
    25,
    30,
    40,
    50,
    60,
    75,
    90,
    105,
    120,
  ]; // in minutes
  static const List<int> restDurations = [
    2,
    5,
    10,
    15,
    20,
    25,
    30,
    45,
    60,
    90,
    120
  ]; // in minutes

  static const String todoListKey = 'todo_list_v2';
  static const String timerStateKey = 'timer_state_v2';
  static const String focusRecordsKey = 'focus_records_v4';

  // Network timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Error messages
  static const String networkUnavailable = '网络连接不可用，请检查网络设置';
  static const String loginFailed = '登录失败';
  static const String registrationFailed = '注册失败';
  static const String tokenRefreshFailed = '令牌刷新失败';
  static const String noAuthToken = '没有找到有效的认证令牌';
}
