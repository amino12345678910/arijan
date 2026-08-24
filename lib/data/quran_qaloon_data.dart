import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class QuranQaloonData {
  static Map<String, dynamic>? _quranData;

  /// Load the Qaloun data from assets (call this in main.dart or before accessing first time)
  static Future<void> load() async {
    if (_quranData != null) return;
    
    try {
      final jsonString = await rootBundle.loadString('assets/data/quran_qaloon.json');
      _quranData = jsonDecode(jsonString);
    } catch (e) {
      debugPrint('Error loading Qaloun data: \$e');
    }
  }

  /// Get total verses for a surah
  static int getVerseCount(int surahNumber) {
    if (_quranData == null) return 0;
    try {
      final surahs = _quranData!['data']['surahs'];
      if (surahs != null) {
         final targetSurah = surahs[surahNumber - 1];
         return targetSurah['ayahs'].length;
      }
    } catch (e) {
      debugPrint('Error getting verse count: \$e');
    }
    return 0; // Default or error
  }

  /// Get verse text by surah and ayah number.  
  /// Note: the JSON array might have a different indexing. It's safer to find by number.
  static String getVerse(int surahNumber, int verseNumber) {
    if (_quranData == null) {
      // Return a fallback or empty if not loaded yet
      return 'جار التحميل...';
    }

    try {
      final surahs = _quranData!['data']['surahs'];
      if (surahs != null) {
         final targetSurah = surahs[surahNumber - 1];
         final ayahs = targetSurah['ayahs'];
         final targetAyah = ayahs[verseNumber - 1];
         return targetAyah['text'];
      }
      return 'الآية غير موجودة';
    } catch (e) {
      debugPrint('Error parsing verse: \$e');
      return '';
    }
  }
}
