import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataSource {
  Future<String?> getApiKey();
  Future<void> saveApiKey(String apiKey);
  Future<void> deleteApiKey();
}

class LocalDataSourceImpl implements LocalDataSource {
  static const String _apiKeyKey = 'api_key';
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String?> getApiKey() async {
    return sharedPreferences.getString(_apiKeyKey);
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
