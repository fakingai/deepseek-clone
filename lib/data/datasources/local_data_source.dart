import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataSource {
  Future<String?> getApiKey();
  Future<void> saveApiKey(String apiKey);
  Future<void> deleteApiKey();
}

class LocalDataSourceImpl implements LocalDataSource {
  static const String _apiKeyKey = 'api_key';
  static const String _defaultApiKeyFromEnv = String.fromEnvironment('DEEPSEEK_API_KEY');
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String?> getApiKey() async {
    final storedApiKey = sharedPreferences.getString(_apiKeyKey);
    if (storedApiKey != null && storedApiKey.isNotEmpty) {
      return storedApiKey;
    }
    if (_defaultApiKeyFromEnv.isNotEmpty) {
      return _defaultApiKeyFromEnv;
    }
    return null;
  }

  @override
  Future<void> saveApiKey(String apiKey) async {
    await sharedPreferences.setString(_apiKeyKey, apiKey);
  }

  @override
  Future<void> deleteApiKey() async {
    await sharedPreferences.remove(_apiKeyKey);
  }
}
