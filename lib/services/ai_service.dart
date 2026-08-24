import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class AiService {
  // On web, use Netlify Function to avoid CORS. On mobile, call Groq directly.
  String get _baseUrl => kIsWeb
      ? '/.netlify/functions/ai-chat'
      : 'https://api.groq.com/openai/v1/chat/completions';

  final List<Map<String, String>> _conversationHistory = [];

  AiService();

  void clearHistory() {
    _conversationHistory.clear();
  }

  Stream<String> sendMessageStream(String message) async* {
    _conversationHistory.add({'role': 'user', 'content': message});

    try {
      final url = Uri.parse(_baseUrl);

      final messages = [
        {'role': 'system', 'content': 'You are a helpful and polite Islamic Adviser named Arijan. Answer concisely in Arabic unless requested otherwise. Use Quran and Hadith references when appropriate.'},
        ..._conversationHistory,
      ];

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['choices'] != null &&
            data['choices'].isNotEmpty &&
            data['choices'][0]['message'] != null &&
            data['choices'][0]['message']['content'] != null) {
          final fullText = data['choices'][0]['message']['content'].toString();

          _conversationHistory.add({'role': 'assistant', 'content': fullText});

          final words = fullText.split(' ');
          for (var word in words) {
            yield '$word ';
            await Future.delayed(const Duration(milliseconds: 30));
          }
        } else {
          yield 'عذراً، لم أتمكن من توليد إجابة. حاول مرة أخرى.';
        }
      } else {
        debugPrint('AI Error: ${response.statusCode} - ${response.body}');
        yield 'عذراً، حدث خطأ في الاتصال. حاول مرة أخرى لاحقاً.';
      }
    } on Exception catch (e) {
      debugPrint('Network Error: $e');
      if (e.toString().contains('TimeoutException')) {
        yield 'انتهت مهلة الاتصال. تأكد من اتصالك بالإنترنت وحاول مجدداً.';
      } else {
        yield 'تعذر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.';
      }
    }
  }
}
