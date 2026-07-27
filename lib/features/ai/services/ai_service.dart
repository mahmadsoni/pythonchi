import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AiServiceException implements Exception {
  final String message;
  AiServiceException(this.message);
  @override
  String toString() => message;
}

/// Thin client for Anthropic's Messages API, used to power the in-app
/// AI Assistant (code explanation, bug fixing, improvement suggestions,
/// and quiz generation). The user supplies their own API key in Settings;
/// it is stored only in on-device secure storage and never bundled with
/// the app or sent anywhere except https://api.anthropic.com.
class AiService {
  static const _secureStorage = FlutterSecureStorage();
  static const _apiKeyStorageKey = 'anthropic_api_key';
  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-6';

  Future<String?> _getApiKey() => _secureStorage.read(key: _apiKeyStorageKey);

  Future<bool> hasApiKey() async {
    final key = await _getApiKey();
    return key != null && key.isNotEmpty;
  }

  Future<String> _send(String systemPrompt, String userMessage) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw AiServiceException('AI API калид танзим нашудааст. Лутфан онро дар Танзимот ворид кунед.');
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1024,
        'system': systemPrompt,
        'messages': [
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw AiServiceException('Хатогии AI (${response.statusCode}). Калиди API-ро санҷед.');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final content = data['content'] as List;
    final buffer = StringBuffer();
    for (final block in content) {
      if (block['type'] == 'text') buffer.write(block['text']);
    }
    return buffer.toString().trim();
  }

  Future<String> explainCode(String code) {
    return _send(
      'Ту муаллими Python барои донишҷӯёни навкор ҳастӣ. Ба забони тоҷикӣ, содда ва мухтасар ҷавоб деҳ.',
      'Ин коди Python-ро қадам ба қадам, ба забони оддӣ шарҳ деҳ:\n\n```python\n$code\n```',
    );
  }

  Future<String> fixCode(String code, {String? errorMessage}) {
    final errorContext = errorMessage != null ? '\n\nХатогии рухдода:\n$errorMessage' : '';
    return _send(
      'Ту муҳандиси болотар Python ҳастӣ. Хатогиро ёбед, онро ислоҳ кунед ва ба забони тоҷикӣ фаҳмонед, ки чӣ буд хато.',
      'Ин коди Python-ро ислоҳ кунед:\n\n```python\n$code\n```$errorContext',
    );
  }

  Future<String> suggestImprovement(String code) {
    return _send(
      'Ту муҳандиси болотар Python ҳастӣ, ки коди тозаву самарабахш менависӣ. Ба забони тоҷикӣ ҷавоб деҳ.',
      'Ин коди Python-ро аз назар гузаронед ва пешниҳодҳо барои беҳтар кардани он диҳед (хониш, самаранокӣ, best practices):\n\n```python\n$code\n```',
    );
  }

  Future<String> generateQuiz(String topic) {
    return _send(
      'Ту эҷодкунандаи саволҳои санҷишии Python ҳастӣ. Ба забони тоҷикӣ 3 саволи intihoбӣ (multiple choice) бо ҷавобҳо созед.',
      'Барои мавзӯи "$topic" 3 саволи санҷишӣ созед.',
    );
  }
}
