import 'package:google_generative_ai/google_generative_ai.dart';
import 'core/constants.dart';

void main() async {
  print("Checking Gemini API Key with upgraded package...");
  final apiKey = AppConstants.geminiApiKey;

  final modelsToTry = [
    'gemini-2.0-flash-lite-001',
    'gemini-2.5-flash-lite',
    'gemini-2.0-flash', // Retrying in case it was transient
  ];

  for (final modelName in modelsToTry) {
    print("\nTesting generation with model: $modelName");
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );

    try {
      print("Sending prompt 'Hello'...");
      final content = [Content.text('Hello')];
      final response = await model.generateContent(content);
      print("SUCCESS with $modelName!");
      print("Response: ${response.text}");
      break;
    } catch (e) {
      print("FAILED with $modelName.");
      print("Error: $e");
    }
  }
}
