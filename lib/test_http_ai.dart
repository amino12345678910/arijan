import 'dart:convert';
import 'package:http/http.dart' as http;
import 'core/constants.dart';

void main() async {
  final apiKey = AppConstants.geminiApiKey;
  if (apiKey == 'YOUR_API_KEY_HERE') {
    print("Error: API Key is not set.");
    return;
  }
  
  // List Models Endpoint
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  final url = Uri.parse('$baseUrl?key=$apiKey');

  print("Listing Models via: $url");

  try {
    final response = await http.get(url);

    print("Response Status Code: ${response.statusCode}");
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("SUCCESS! API is working. Found models:");
      if (data['models'] != null) {
        for (var m in data['models']) {
          print(" - ${m['name']}"); 
        }
      } else {
        print("No models found.");
      }
    } else {
      print("FAILURE: API returned an error: ${response.body}");
    }
  } catch (e) {
    print("EXCEPTION: $e");
  }
}
