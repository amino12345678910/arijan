import 'package:flutter/material.dart';

class Mood {
  final String id;
  final String label;
  final String emoji;
  final List<Color> gradientColors;
  final Remedy remedy;

  const Mood({
    required this.id,
    required this.label,
    required this.emoji,
    required this.gradientColors,
    required this.remedy,
  });
}

class Remedy {
  final String quranVerse;
  final String quranRef;
  final String dua;
  final String action;
  final String aiPrompt;

  const Remedy({
    required this.quranVerse,
    required this.quranRef,
    required this.dua,
    required this.action,
    required this.aiPrompt,
  });
}

class MoodData {
  static const List<Mood> moods = [
    Mood(
      id: 'anxious',
      label: 'قلق',
      emoji: '😰',
      gradientColors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)], // Deep Purple to Blue
      remedy: Remedy(
        quranVerse: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
        quranRef: "سورة الرعد - 28",
        dua: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ",
        action: "تنفس بعمق، واستغفر الله 100 مرة ببطء.",
        aiPrompt: "أشعر بقلق شديد وتوتر، ما هي النصيحة الإسلامية والآيات التي تهدئ روعي؟",
      ),
    ),
    Mood(
      id: 'sad',
      label: 'حزين',
      emoji: '😢',
      gradientColors: [Color(0xFF0F2027), Color(0xFF2C5364)], // Dark Blue/Grey
      remedy: Remedy(
        quranVerse: "لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا",
        quranRef: "سورة التوبة - 40",
        dua: "يا حَيُّ يا قَيّومُ بِرَحْمَتِكَ أَسْتَغِيثُ",
        action: "توضأ وصلِّ ركعتين، فإن الصلاة نور.",
        aiPrompt: "أشعر بحزن عميق وضيق في الصدر، كيف أتجاوز هذا الشعور بالقرآن؟",
      ),
    ),
    Mood(
      id: 'angry',
      label: 'غاضب',
      emoji: '😡',
      gradientColors: [Color(0xFFCB2D3E), Color(0xFFEF473A)], // Fiery Red
      remedy: Remedy(
        quranVerse: "وَالْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ عَنِ النَّاسِ",
        quranRef: "سورة آل عمران - 134",
        dua: "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
        action: "غير وضعيتك؛ إن كنت واقفاً فاجلس، وإن كنت جالساً فاضطجع.",
        aiPrompt: "أشعر بغضب شديد وأخاف أن أظلم أحداً، كيف أسيطر على غضبي كما أوصى النبي؟",
      ),
    ),
    Mood(
      id: 'happy',
      label: 'سعيد',
      emoji: '😊',
      gradientColors: [Color(0xFFF2994A), Color(0xFFF2C94C)], // Gold/Orange
      remedy: Remedy(
        quranVerse: "لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ",
        quranRef: "سورة إبراهيم - 7",
        dua: "الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ",
        action: "تصدق ولو بالقليل شكراً لله، وأدخل السرور على غيرك.",
        aiPrompt: "أشعر بسعادة غامرة، كيف أحافظ على هذه النعمة وأشكر الله حق شكره؟",
      ),
    ),
    Mood(
      id: 'lost',
      label: 'تائه',
      emoji: '🌫️',
      gradientColors: [Color(0xFF636363), Color(0xFFa2ab58)], // Olive Grey
      remedy: Remedy(
        quranVerse: "وَوَجَدَكَ ضَالًّا فَهَدَىٰ",
        quranRef: "سورة الضحى - 7",
        dua: "اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ",
        action: "اقرأ صفحة من القرآن، فهي بوصلة القلب.",
        aiPrompt: "أشعر بضياع ولا أعرف طريقي، أرشدني بآيات تعيد لي اليقين والهدف.",
      ),
    ),
    Mood(
      id: 'lonely',
      label: 'وحيد',
      emoji: '🍂',
      gradientColors: [Color(0xFF3E5151), Color(0xFFDECBA4)], // Muted Sand
      remedy: Remedy(
        quranVerse: "وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ",
        quranRef: "سورة ق - 16",
        dua: "رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنتَ خَيْرُ الْوَارِثِينَ",
        action: "ناجِ ربك في خلوة، فإنه جليسك حين يغيب الناس.",
        aiPrompt: "أشعر بوحدة قاتلة رغم وجود الناس حولي، كيف أستشعر معية الله؟",
      ),
    ),
    Mood(
      id: 'sinful',
      label: 'مذنب',
      emoji: '😔',
      gradientColors: [Color(0xFF141E30), Color(0xFF243B55)], // Dark Navy
      remedy: Remedy(
        quranVerse: "قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ",
        quranRef: "سورة الزمر - 53",
        dua: "اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي",
        action: "استغفر 70 مرة بقلب حاضر، واعزم على التوبة.",
        aiPrompt: "أثقلتني الذنوب وأشعر بالخجل من الله، كيف أبدأ صفحة جديدة؟",
      ),
    ),
     Mood(
      id: 'hopeful',
      label: 'متفائل',
      emoji: '🌱',
      gradientColors: [Color(0xFF11998e), Color(0xFF38ef7d)], // Fresh Green
      remedy: Remedy(
        quranVerse: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
        quranRef: "سورة الشرح - 5",
        dua: "حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ",
        action: "ابدأ خطوة صغيرة في مشروعك أو هدفك متوكلاً على الله.",
        aiPrompt: "لدي أمل كبير وطموح، كيف أستعين بالله لتحقيق أهدافي؟",
      ),
    ),
  ];
}
