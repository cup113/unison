import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './services/logging_service.dart';
import './main_tabbed_page.dart';

Future<void> main() async {
  // 初始化日志服务
  WidgetsFlutterBinding.ensureInitialized();
  final loggingService = LoggingService();
  await loggingService.initialize();
  
  // 设置全局错误处理
  FlutterError.onError = (details) {
    loggingService.error(
      'Flutter error: ${details.exception}',
      stackTrace: details.stack,
      context: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );
  };
  
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    loggingService.error(
      'Platform error: $error',
      stackTrace: stackTrace,
    );
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Unison',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const MainTabbedPage(),
      ),
    );
  }
}
