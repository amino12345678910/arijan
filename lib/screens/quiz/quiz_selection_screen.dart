
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_theme.dart';
import '../../data/quiz_data.dart';
import 'quiz_screen.dart';

class QuizSelectionScreen extends StatelessWidget {
  const QuizSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبارات السور', style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
        backgroundColor: AppTheme.emeraldPrimary,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: QuizData.surahQuizzes.length,
          itemBuilder: (context, index) {
            final quiz = QuizData.surahQuizzes[index];
            return Card(
              color: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(15),
                 side: BorderSide(color: Colors.white12)
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  "سورة ${quiz['surahName']}",
                  style: GoogleFonts.amiri(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${quiz['questions'].length} أسئلة",
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.goldAccent),
                onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => QuizScreen(quizData: quiz)),
                   );
                },
              ),
            ).animate().fadeIn(delay: (index * 100).ms).slideX();
          },
        ),
      ),
    );
  }
}
