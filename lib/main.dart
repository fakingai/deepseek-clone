import 'package:deepseek/core/di/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:deepseek/core/services/logger_service.dart';
import 'package:deepseek/core/themes/theme_provider.dart';
import 'package:deepseek/presentation/pages/home_page.dart';
import 'package:deepseek/presentation/pages/settings_page.dart';
import 'presentation/bloc/conversation/conversation_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LoggerService.initialize();
  await di.init();

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    LoggerService().logError(
      'Flutter error caught by global handler',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Initialize blocs
  final conversationBloc = di.sl<ConversationBloc>();

  // Create a properly structured provider tree
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ConversationBloc>.value(
          value: conversationBloc,
        ),
        // Add other BlocProviders here if needed
      ],
      child: ChangeNotifierProvider(
        create: (_) => di.sl<ThemeProvider>(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'DeepSeek',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const HomePage(),
          routes: {
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
