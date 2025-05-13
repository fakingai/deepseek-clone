import 'package:bloc/bloc.dart';
import 'package:deepseek/core/usecases/usecase.dart';
import 'package:deepseek/domain/usecases/delete_all_conversations.dart';
import 'package:deepseek/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:deepseek/presentation/bloc/conversation/conversation_event.dart';
import 'package:equatable/equatable.dart';
import 'package:deepseek/core/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deepseek/data/datasources/local_data_source.dart'; // Import LocalDataSource

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ThemeProvider themeProvider;
  final DeleteAllConversations deleteAllConversations;
  final ConversationBloc conversationBloc; // To refresh conversation list
  final LocalDataSource localDataSource; // Added localDataSource

  SettingsBloc({
    required this.themeProvider,
    required this.deleteAllConversations,
    required this.conversationBloc,
    required this.localDataSource, // Added localDataSource
  }) : super(const SettingsInitial(AppTheme.system)) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<DeleteAllConversationsEvent>(_onDeleteAllConversations);
    on<LoadApiKeyEvent>(_onLoadApiKey); // Register new event handler
    on<SaveApiKeyEvent>(_onSaveApiKey); // Register new event handler
  }

  Future<void> _onLoadSettings(LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading(state.currentTheme, apiKey: state.apiKey)); // Emit loading state
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme') ?? 'system';
    AppTheme theme = AppTheme.values.firstWhere((e) => e.toString().split('.').last == themeName, orElse: () => AppTheme.system);
    
    if (themeProvider.appTheme != theme) {
      themeProvider.setTheme(theme);
    }
    
    final apiKey = await localDataSource.getApiKey();
    emit(SettingsLoaded(theme, apiKey: apiKey));
  }

  Future<void> _onChangeTheme(ChangeThemeEvent event, Emitter<SettingsState> emit) async {
    themeProvider.setTheme(event.theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', event.theme.toString().split('.').last);
    emit(SettingsLoaded(event.theme, apiKey: state.apiKey)); // Preserve apiKey
  }

  Future<void> _onDeleteAllConversations(
      DeleteAllConversationsEvent event, Emitter<SettingsState> emit) async {
    final result = await deleteAllConversations(const NoParams());
    result.fold(
      (failure) => emit(SettingsError(state.currentTheme, 'Failed to delete conversations', apiKey: state.apiKey)),
      (_) {
        emit(SettingsLoaded(state.currentTheme, apiKey: state.apiKey)); 
        conversationBloc.add(GetConversationsEvent());
      },
    );
  }

  // New event handler for loading API key
  Future<void> _onLoadApiKey(LoadApiKeyEvent event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading(state.currentTheme, apiKey: state.apiKey));
    try {
      final apiKey = await localDataSource.getApiKey();
      emit(SettingsLoaded(state.currentTheme, apiKey: apiKey));
    } catch (e) {
      emit(SettingsError(state.currentTheme, 'Failed to load API Key: $e', apiKey: state.apiKey));
    }
  }

  // New event handler for saving API key
  Future<void> _onSaveApiKey(SaveApiKeyEvent event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading(state.currentTheme, apiKey: state.apiKey));
    try {
      await localDataSource.saveApiKey(event.apiKey);
      emit(ApiKeySaved(state.currentTheme, event.apiKey)); // Emit ApiKeySaved state
      // Optionally, reload all settings to ensure consistency or just update the key
      // For now, just update the key in the state.
      // emit(SettingsLoaded(state.currentTheme, apiKey: event.apiKey));
    } catch (e) {
      emit(SettingsError(state.currentTheme, 'Failed to save API Key: $e', apiKey: state.apiKey));
    }
  }
}