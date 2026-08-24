import 'package:quran/quran.dart' as quran;
import 'core/constants.dart';

void main() {
  String verse = quran.getVerse(2, 1);
  String basmala = quran.basmala;
  
  print("Verse 1 of Surah 2: '$verse'");
  print("Basmala constant:   '$basmala'");
  
  bool startsWithAny = AppConstants.basmalaVariations.any((b) => verse.startsWith(b));
  print("Does it start with ANY Basmala variation? $startsWithAny");
  
  // Also print pure strings to compare widely
  print("Verse CodeUnits: ${verse.substring(0, basmala.length + 5).codeUnits}");
  print("Basmala CodeUnits: ${basmala.codeUnits}");
}
