import 'dart:convert';
import 'package:quran/quran.dart' as quran;

class AppConstants {
  static String get groqApiKey {
    const envKey = String.fromEnvironment('GROQ_API_KEY');
    if (envKey.isNotEmpty) return envKey;
    return utf8.decode(base64.decode('Z3NrX1pYeFBhUnRlQjNrQm9pOEJ5QnlCV0dkeWIzckZvVjRnTTg1Z3FvQmhBczR1VjBEV3dJZw=='));
  }

  static String get mistralApiKey => groqApiKey;
  static String get geminiApiKey => groqApiKey;

  static const List<String> basmalaVariations = [
    "بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ", // Found in getVerse
    quran.basmala, // Constant
    "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
  ];
}
