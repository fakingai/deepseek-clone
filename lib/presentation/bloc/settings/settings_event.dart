part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class ChangeThemeEvent extends SettingsEvent {
  final AppTheme theme;

  const ChangeThemeEvent(this.theme);

  @override
  List<Object> get props => [theme];
}

class DeleteAllConversationsEvent extends SettingsEvent {}

class LoadApiKeyEvent extends SettingsEvent {}

class SaveApiKeyEvent extends SettingsEvent {
  final String apiKey;

  const SaveApiKeyEvent(this.apiKey);

  @override
  List<Object> get props => [apiKey];
}