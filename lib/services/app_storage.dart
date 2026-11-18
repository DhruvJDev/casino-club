import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  const AppUser({
    required this.name,
    required this.username,
    required this.password,
  });

  final String name;
  final String username;
  final String password;

  Map<String, dynamic> toJson() => {
        'name': name,
        'username': username,
        'password': password,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        name: json['name'] as String,
        username: json['username'] as String,
        password: json['password'] as String,
      );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String sender;
  final String text;
  final int createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender,
        'text': text,
        'createdAt': createdAt,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        sender: json['sender'] as String,
        text: json['text'] as String,
        createdAt: json['createdAt'] as int,
      );
}

class AppStorage {
  static const _accountsKey = 'casino_accounts';
  static const _chatKey = 'casino_chat_messages';
  static const _sessionKey = 'casino_logged_in_username';

  static Future<List<AppUser>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null) {
      await prefs.setString(
        _accountsKey,
        jsonEncode([
          const AppUser(
            name: 'Demo User',
            username: 'test1',
            password: 'test123',
          ).toJson(),
        ]),
      );
      return const [
        AppUser(name: 'Demo User', username: 'test1', password: 'test123'),
      ];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => AppUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<AppUser?> authenticate(
    String username,
    String password,
  ) async {
    final accounts = await getAccounts();
    for (final account in accounts) {
      if (account.username.toLowerCase() == username.trim().toLowerCase() &&
          account.password == password) {
        return account;
      }
    }
    return null;
  }

  static Future<bool> register(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await getAccounts();
    final exists = accounts.any(
      (account) =>
          account.username.toLowerCase() == user.username.toLowerCase(),
    );
    if (exists) return false;

    accounts.add(user);
    await prefs.setString(
      _accountsKey,
      jsonEncode(accounts.map((account) => account.toJson()).toList()),
    );
    return true;
  }

  static Future<void> setSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, username);
  }

  static Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  static Future<List<ChatMessage>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> sendMessage(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final messages = await getMessages();
    messages.add(message);
    await prefs.setString(
      _chatKey,
      jsonEncode(messages.map((item) => item.toJson()).toList()),
    );
  }

  static String directConversationKey(String firstUser, String secondUser) {
    final users = [firstUser.toLowerCase(), secondUser.toLowerCase()]..sort();
    return '${users[0]}:${users[1]}';
  }

  static Future<List<ChatMessage>> getConversation(
    String firstUser,
    String secondUser,
  ) async {
    final key = directConversationKey(firstUser, secondUser);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('casino_chat_$key');
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> sendDirectMessage(
    String firstUser,
    String secondUser,
    ChatMessage message,
  ) async {
    final key = directConversationKey(firstUser, secondUser);
    final prefs = await SharedPreferences.getInstance();
    final messages = await getConversation(firstUser, secondUser);
    messages.add(message);
    await prefs.setString(
      'casino_chat_$key',
      jsonEncode(messages.map((item) => item.toJson()).toList()),
    );
  }
}
