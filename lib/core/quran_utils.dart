class QuranUtils {
  /// Normalizes Arabic text by removing diacritics (Tashkeel) and unifying Alef forms.
  static String normalizeArabic(String text) {
    String normalized = text;

    // Remove Diacritics (Tashkeel)
    // Range of Arabic Tashkeel: 0x064B - 0x065F
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F]'), '');
    
    // Remove Tatweel (Kashida)
    normalized = normalized.replaceAll('\u0640', '');

    // Unify Alef forms
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');
    
    // Unify Ya/Alef Maqsura (Optional, depending on strictness)
    // normalized = normalized.replaceAll('ى', 'ي'); 
    
    // Unify Ta Marbuta (Optional)
    // normalized = normalized.replaceAll('ة', 'ه');

    return normalized.trim();
  }

  /// Compares the recited text with the reference Ayah text.
  /// Returns a list of booleans where true indicates the word at that index was matched.
  /// This is a simple word-by-word comparison. 
  /// 
  /// [referenceAyah] The correct text from Quran package.
  /// [recitedText] The text recognized by speech-to-text.
  static List<bool> compareRecitation(String referenceAyah, String recitedText) {
    // 1. Normalize both texts
    final normalizedRef = normalizeArabic(referenceAyah);
    final normalizedRecited = normalizeArabic(recitedText);

    // 2. Split into words
    final refWords = normalizedRef.split(RegExp(r'\s+'));
    final recitedWords = normalizedRecited.split(RegExp(r'\s+'));

    List<bool> results = [];

    // Simple matching strategy:
    // We try to find if the reference word exists reasonably close in the recited text?
    // OR simpler: Just 1-to-1 match for now as MVP.
    // If the reciter skips a word, everything shifting might be an issue.
    // Let's do a slightly smarter check: check if the word exists in the recited text.
    // Ideally we want sequence alignment, but for MVP let's stick to:
    // Is this reference word present in the recited string? 
    // BUT we need to color code the REFERENCE text. So we need a status for each REFERENCE word.
    
    // Better MVP strategy:
    // Check if the word at index i matches the word at index i in recited?
    // If mismatch, check if it matches i+1 (maybe extra word inserted?)
    // If match, mark green.
    
    // Let's implement a "LCS" style or just simple inclusion for now.
    // If the reference word appears in the recited text, we mark it Green? 
    // That's too lenient (order matters).
    
    // Revised Strategy:
    // We treat the recited text as "attempts".
    // We iterate through Reference Words.
    // We maintain a "cursor" in Recited Words.
    // If refWords[i] matches recitedWords[cursor], we mark match and increment cursor.
    // If not, we check if refWords[i] matches recitedWords[cursor+1]? (maybe user said an extra word).
    // If yes, we match and increment cursor by 2.
    // If no, we assume user Missed the word, so it's Red. We DON'T increment cursor (hope next ref word matches current recited word).
    
    int recitedCursor = 0;
    
    for (int i = 0; i < refWords.length; i++) {
        if (recitedCursor >= recitedWords.length) {
          results.add(false);
          continue;
        }

        final refWord = refWords[i];
        final recWord = recitedWords[recitedCursor];

        // Direct Match
        if (refWord == recWord) {
            results.add(true);
            recitedCursor++;
        } else {
            // Fuzzy Match Check (Allow ~20-30% difference)
            if (isFuzzyMatch(refWord, recWord)) {
               results.add(true);
               recitedCursor++;
               continue;
            }

            // Extra Word Check (Check next recited word)
            if (recitedCursor + 1 < recitedWords.length) {
               final nextRecWord = recitedWords[recitedCursor + 1];
               if (refWord == nextRecWord || isFuzzyMatch(refWord, nextRecWord)) {
                   results.add(true);
                   recitedCursor += 2; 
                   continue;
               }
            }
            
            // Lookahead for Ref Word (Maybe user skipped this ref word?)
            // If the CURRENT recited word matches the NEXT ref word, then this ref word was skipped.
            // But we handle that by just marking current Red and NOT moving recitedCursor.
            results.add(false);
        }
    }
    
    return results;
  }

  static bool isFuzzyMatch(String word1, String word2) {
     if (word1 == word2) return true;
     if (word1.length < 2 || word2.length < 2) return false;

     int dist = levenshtein(word1, word2);
     int maxLength = word1.length > word2.length ? word1.length : word2.length;
     
     // Allow distance of 1 for words <= 4 chars
     // Allow distance of 2 for longer words
     if (maxLength <= 4) return dist <= 1;
     return dist <= 2; 
  }

  static int levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s.codeUnitAt(i) == t.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((min, val) => val < min ? val : min);
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }
}
