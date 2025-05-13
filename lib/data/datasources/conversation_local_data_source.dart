import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deepseek/data/models/conversation_model.dart';

abstract class ConversationLocalDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<void> saveConversation(ConversationModel conversation);
  Future<void> deleteConversation(String id);
  Future<String> createNewConversation();
  Future<ConversationModel?> getConversation(String id);
  Future<void> deleteAllConversations(); // Add this line
}

class ConversationLocalDataSourceImpl implements ConversationLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CONVERSATIONS_KEY = 'conversations';
  static const String ACTIVE_CONVERSATION_KEY = 'active_conversation';

  ConversationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ConversationModel>> getConversations() async {
    final String? jsonString = sharedPreferences.getString(CONVERSATIONS_KEY);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((json) => ConversationModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> saveConversation(ConversationModel conversation) async {
    final List<ConversationModel> conversations = await getConversations();
    
    // Find and update existing conversation or add new one
    final int index = conversations.indexWhere((c) => c.id == conversation.id);
    if (index >= 0) {
      conversations[index] = conversation;
    } else {
      conversations.add(conversation);
    }

    // Save updated conversations list
    final String jsonString = json.encode(
        conversations.map((conversation) => conversation.toJson()).toList());
    await sharedPreferences.setString(CONVERSATIONS_KEY, jsonString);
  }

  @override
  Future<void> deleteConversation(String id) async {
    final List<ConversationModel> conversations = await getConversations();
    conversations.removeWhere((conversation) => conversation.id == id);
    
    final String jsonString = json.encode(
        conversations.map((conversation) => conversation.toJson()).toList());
    await sharedPreferences.setString(CONVERSATIONS_KEY, jsonString);
  }

  @override
  Future<String> createNewConversation() async {
    final ConversationModel newConversation = ConversationModel.createNew(); 
    await saveConversation(newConversation);
    await setActiveConversation(newConversation.id);
    return newConversation.id;
  }

  @override
  Future<ConversationModel?> getConversation(String id) async {
    final List<ConversationModel> conversations = await getConversations();
    final int index = conversations.indexWhere((c) => c.id == id);
    if (index >= 0) {
      return conversations[index];
    }
    return null;
  }

  Future<String?> getActiveConversation() async {
    return sharedPreferences.getString(ACTIVE_CONVERSATION_KEY);
  }

  Future<void> setActiveConversation(String id) async {
    await sharedPreferences.setString(ACTIVE_CONVERSATION_KEY, id);
  }

  @override
  Future<void> deleteAllConversations() async {
    await sharedPreferences.remove(CONVERSATIONS_KEY);
    // Optionally, also clear the active conversation ID if it makes sense for the app logic
    // await sharedPreferences.remove(ACTIVE_CONVERSATION_KEY);
  }
}
