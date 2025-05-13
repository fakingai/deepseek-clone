part of 'settings_bloc.dart';

enum AppTheme { system, light, dark }

abstract class SettingsState extends Equatable {
  final AppTheme currentTheme;
  final String? apiKey; // Added apiKey

  const SettingsState(this.currentTheme, {this.apiKey});

  @override
  List<Object?> get props => [currentTheme, apiKey];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial(AppTheme currentTheme, {String? apiKey}) : super(currentTheme, apiKey: apiKey); // Updated
}

class SettingsLoading extends SettingsState { // Optional: if loading takes time
  const SettingsLoading(AppTheme currentTheme, {String? apiKey}) : super(currentTheme, apiKey: apiKey);
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded(AppTheme currentTheme, {String? apiKey}) : super(currentTheme, apiKey: apiKey); // Updated
}

class ApiKeySaved extends SettingsState { // New State for confirmation
  const ApiKeySaved(AppTheme currentTheme, String apiKey) : super(currentTheme, apiKey: apiKey);
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(AppTheme currentTheme, this.message, {String? apiKey}) : super(currentTheme, apiKey: apiKey); // Updated

  @override
  List<Object?> get props => [currentTheme, message, apiKey];
}
