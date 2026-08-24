import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class AiService {
  // Groq API Endpoint (OpenAI-compatible)
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  AiService();

  Stream<String> sendMessageStream(String message) async* {
    if (AppConstants.groqApiKey == 'YOUR_API_KEY_HERE') {
      yield "Please configure your Groq API Key in lib/core/constants.dart to use the AI Adviser.";
      return;
    }

    try {
      final url = Uri.parse(_baseUrl);
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {"role": "system", "content": "You are a helpful and polite Islamic Adviser named Arijan. Answer concisely in Arabic unless requested otherwise."},
            {"role": "user", "content": message}
          ],
          "temperature": 0.7,
          "max_tokens": 1000, 
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Extract text from Mistral JSON structure
        if (data['choices'] != null && 
            data['choices'].isNotEmpty && 
            data['choices'][0]['message'] != null &&
            data['choices'][0]['message']['content'] != null) {
              
          final fullText = data['choices'][0]['message']['content'].toString();
          
          // Simulate streaming/typing effect for the user since Mistral API (via simple HTTP) returns full response
          // Ideally we would use SSE for real streaming, but to keep it simple and consistent with previous architecture:
          final words = fullText.split(' ');
          for (var word in words) {
            yield "$word ";
            await Future.delayed(const Duration(milliseconds: 50));
          }
        } else {
           yield "No response generated.";
        }
      } else {
        debugPrint("AI Error: ${response.statusCode} - ${response.body}");
        yield "Error: Unable to connect (${response.statusCode}).\nDetails: ${response.body}";
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      yield "Error: Connection failed.\nDetails: $e";
    }
  }
}
