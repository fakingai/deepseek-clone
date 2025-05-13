import 'package:deepseek/core/di/injection_container.dart';
import 'package:deepseek/presentation/bloc/settings/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Added import

class SettingsPage extends StatefulWidget { // Changed to StatefulWidget
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState(); // Create state
}

class _SettingsPageState extends State<SettingsPage> { // State class
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dispatch event to load settings, including API key
    // BlocProvider.of<SettingsBloc>(context) can't be used in initState directly
    // if create is in the same build method.
    // The LoadSettingsEvent is already added in the BlocProvider.create.
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsBloc>()..add(LoadSettingsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
        ),
        body: BlocConsumer<SettingsBloc, SettingsState>( // Changed to BlocConsumer
          listener: (context, state) {
            if (state is SettingsLoaded) {
              _apiKeyController.text = state.apiKey ?? '';
            } else if (state is ApiKeySaved) {
              _apiKeyController.text = state.apiKey ?? '';
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API Key已保存')),
              );
            } else if (state is SettingsError && state.message.contains('API Key')) {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('API Key操作失败: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            if (state is SettingsInitial || (state is SettingsLoading && state.apiKey == null)) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SettingsError && !state.message.contains('API Key')) { // Only show full page error for non-API key errors initially
              return Center(child: Text('加载设置失败: ${state.message}'));
            }
            
            // Set API key to controller if not yet set and state has it
            if (_apiKeyController.text.isEmpty && state.apiKey != null) {
              _apiKeyController.text = state.apiKey!;
            }

            return ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.vpn_key),
                  title: const Text('API Key'),
                  subtitle: Text(state.apiKey?.isNotEmpty ?? false ? '已设置' : '未设置'),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    _showApiKeyDialog(context, state.apiKey ?? '');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.data_usage),
                  title: const Text('数据管理'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: BlocProvider.of<SettingsBloc>(context),
                          child: const DataManagementPage(),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('外观'),
                  subtitle: Text(_themeToString(state.currentTheme)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showThemeDialog(context, state.currentTheme);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _themeToString(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return '浅色';
      case AppTheme.dark:
        return '深色';
      case AppTheme.system:
      default:
        return '跟随系统';
    }
  }

  void _showThemeDialog(BuildContext context, AppTheme currentTheme) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('选择主题'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppTheme.values.map((theme) {
              return RadioListTile<AppTheme>(
                title: Text(_themeToString(theme)),
                value: theme,
                groupValue: currentTheme,
                onChanged: (AppTheme? value) {
                  if (value != null) {
                    BlocProvider.of<SettingsBloc>(context)
                        .add(ChangeThemeEvent(value));
                    Navigator.of(dialogContext).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showApiKeyDialog(BuildContext context, String currentApiKey) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a local controller for the dialog to avoid issues with the main page controller
        final TextEditingController dialogApiKeyController = TextEditingController(text: currentApiKey);
        return AlertDialog(
          title: const Text('设置 API Key'),
          content: TextField(
            controller: dialogApiKeyController,
            decoration: const InputDecoration(hintText: '请输入您的 API Key'),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('保存'),
              onPressed: () {
                BlocProvider.of<SettingsBloc>(context)
                    .add(SaveApiKeyEvent(dialogApiKeyController.text));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class DataManagementPage extends StatelessWidget {
  const DataManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据管理'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('删除所有历史会话'),
            onTap: () {
              _confirmDeleteDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('此操作将永久删除所有会话记录，无法恢复。确定要继续吗？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                BlocProvider.of<SettingsBloc>(context)
                    .add(DeleteAllConversationsEvent());
                Navigator.of(dialogContext).pop();
                // Optionally, show a snackbar or some feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('所有会话已删除')),
                );
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}
