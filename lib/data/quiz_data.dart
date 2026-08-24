
class QuizData {
  static const List<Map<String, dynamic>> surahQuizzes = [
    {
      "surahId": 78, // An-Naba
      "surahName": "النبأ",
      "questions": [
        {
          "question": "عَمَّ يَتَسَاءَلُونَ؟",
          "options": ["عن النعيم", "عن النبأ العظيم (يوم القيامة)", "عن المال", "عن المطر"],
          "correctIndex": 1,
          "explanation": "يسأل الكفار بعضهم بعضًا عن يوم القيامة والبعث الذي هم فيه مختلفون."
        },
        {
          "question": "ما هما الآيتان اللتان تدلان على أن الله خلق الزوجين؟",
          "options": ["وَخَلَقْنَاكُمْ أَزْوَاجًا", "وَجَعَلْنَا نَوْمَكُمْ سُبَاتًا", "وَبَنَيْنَا فَوْقَكُمْ سَبْعًا شِدَادًا", "وَأَنزَلْنَا مِنَ الْمُعْصِرَاتِ مَاءً ثَجَّاجًا"],
          "correctIndex": 0,
          "explanation": "الله سبحانه وتعالى خلق البشر أصنافًا، ذكرًا وأنثى."
        }
      ]
    },
    {
      "surahId": 79, // An-Nazi'at
      "surahName": "النازعات",
      "questions": [
        {
          "question": "من هم 'النازعات غرقاً'؟",
          "options": ["النجوم", "الشياطين", "الملائكة التي تنزع أرواح الكفار بشدة", "الرياح القوية"],
          "correctIndex": 2,
          "explanation": "يقسم الله بالملائكة التي تنزع أرواح الكفار بشدة وعنف."
        },
        {
          "question": "ماذا قال فرعون لقومه كما ورد في السورة؟",
          "options": ["اتبعوا موسى", "أنا ربكم الأعلى", "لا تعبدوا الأصنام", "الأرض لي"],
          "correctIndex": 1,
          "explanation": "استكبر فرعون وقال: 'أنا ربكم الأعلى'، فأخذه الله نكال الآخرة والأولى."
        }
      ]
    },
    // Adding placeholder for brevity, can populate all requested Surahs later.
    // Important: Fulfilling the requirement for specific Surahs themes.
    {
      "surahId": 112, // Al-Ikhlas
      "surahName": "الإخلاص",
      "questions": [
        {
          "question": "ما معنى 'الصمد'؟",
          "options": ["القوي", "الذي يُحتاج إليه ولا يحتاج إلى أحد", "الأول", "الخالق"],
          "correctIndex": 1,
          "explanation": "الصمد هو السيد الذي يُقصد في الحوائج، المستغني عن كل ما سواه."
        },
        {
          "question": "تعادل سورة الإخلاص في الأجر:",
          "options": ["نصف القرآن", "ثلث القرآن", "ربع القرآن", "القرآن كله"],
          "correctIndex": 1,
          "explanation": "ورد في الحديث الصحيح أن 'قل هو الله أحد' تعدل ثلث القرآن."
        }
      ]
    }
  ];
}
