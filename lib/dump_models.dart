import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'core/constants.dart';

void main() async {
  final apiKey = AppConstants.geminiApiKey;
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final File file = File('models_dump.txt');
      await file.writeAsString(response.body);
      print("Dumped models to models_dump.txt");
    } else {
      print("Failed: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
