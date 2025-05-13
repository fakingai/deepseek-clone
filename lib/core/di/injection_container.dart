import 'package:deepseek/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:deepseek/data/datasources/chat_remote_data_source.dart';
import 'package:deepseek/data/datasources/conversation_local_data_source.dart';
import 'package:deepseek/data/repositories/chat_repository_impl.dart';
import 'package:deepseek/domain/repositories/chat_repository.dart';
import 'package:deepseek/domain/usecases/send_message.dart';
import 'package:deepseek/presentation/bloc/chat/chat_bloc.dart';
import 'package:deepseek/core/network/network_info.dart';

import 'package:deepseek/data/repositories/conversation_repository_impl.dart';
import 'package:deepseek/domain/repositories/conversation_repository.dart';
import 'package:deepseek/domain/usecases/delete_conversation.dart';
import 'package:deepseek/domain/usecases/get_chat_sessions.dart';
import 'package:deepseek/domain/usecases/get_conversation_by_id.dart';
import 'package:deepseek/domain/usecases/rename_chat_session.dart';
import 'package:deepseek/domain/usecases/delete_all_conversations.dart';
import 'package:deepseek/presentation/bloc/settings/settings_bloc.dart';
import 'package:deepseek/core/themes/theme_provider.dart';
import 'package:deepseek/data/datasources/local_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Settings
  sl.registerFactory(() => SettingsBloc(
        themeProvider: sl(),
        deleteAllConversations: sl(),
        conversationBloc: sl(),
        localDataSource: sl(), // Injected LocalDataSource
      ));

  // Features - Chat
  // Bloc
  sl.registerFactory(
    () => ChatBloc(
      sendMessage: sl(),
      conversationLocalDataSource: sl(),
      conversationBloc: sl(),
    ),
  );

  sl.registerFactory(
    () => ConversationBloc(
      getConversations: sl(),
      getConversationById: sl(),
      renameConversation: sl(),
      deleteConversation: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetConversations(sl()));
  sl.registerLazySingleton(() => GetConversationById(sl()));
  sl.registerLazySingleton(() => RenameConversation(sl()));
  sl.registerLazySingleton(() => DeleteConversation(sl()));
  sl.registerLazySingleton(() => DeleteAllConversations(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(client: sl(), localDataSource: sl()),
  );
  
  sl.registerLazySingleton<ConversationLocalDataSource>(
    () => ConversationLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => ThemeProvider());
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl(sharedPreferences: sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // Setup Dio with interceptors for API calls
  final dio = Dio();
  dio.options.headers['Content-Type'] = 'application/json';
  
  sl.registerLazySingleton(() => dio);

}
