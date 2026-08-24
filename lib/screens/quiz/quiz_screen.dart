
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_theme.dart';
import 'package:confetti/confetti.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const QuizScreen({super.key, required this.quizData});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedOptionIndex;
  late List<dynamic> _questions;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _questions = widget.quizData['questions'];
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleAnswer(int index) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = index;
      if (index == _questions[_currentQuestionIndex]['correctIndex']) {
        _score++;
        _confettiController.play();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedOptionIndex = null;
      });
    } else {
       // Finish
       _showResults();
    }
  }
  
  void _showResults() {
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (_) => AlertDialog(
         backgroundColor: AppTheme.emeraldPrimary,
         title: const Text('النتيجة', style: TextStyle(color: Colors.white)),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Text(
               '$_score / ${_questions.length}',
               style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
             ),
             const SizedBox(height: 10),
             Text(
               _score == _questions.length ? 'ما شاء الله! ممتاز' : 'أحسنت محاولة جيدة',
               style: const TextStyle(color: Colors.white70),
             ),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); 
             },
             child: const Text('عودة', style: TextStyle(color: Colors.white)),
           )
         ],
       )
     );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final options = question['options'] as List;
    final correctIndex = question['correctIndex'];
    final explanation = question['explanation'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
           "سورة ${widget.quizData['surahName']}",
           style: GoogleFonts.amiri(color: AppTheme.goldAccent),
        ),
        backgroundColor: AppTheme.emeraldPrimary,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  color: AppTheme.goldAccent,
                  backgroundColor: Colors.white10,
                ),
                const SizedBox(height: 30),
                
                // Question
                Text(
                  question['question'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ).animate(key: ValueKey(_currentQuestionIndex)).fadeIn().slideY(begin: -0.2),
                
                const SizedBox(height: 40),
                
                // Options
                ...List.generate(options.length, (index) {
                   Color color = Colors.white.withOpacity(0.1);
                   IconData? icon;
                   
                   if (_isAnswered) {
                      if (index == correctIndex) {
                         color = Colors.green.withOpacity(0.6);
                         icon = Icons.check_circle;
                      } else if (index == _selectedOptionIndex) {
                         color = Colors.red.withOpacity(0.6);
                         icon = Icons.cancel;
                      }
                   }
                   
                   return Padding(
                     padding: const EdgeInsets.only(bottom: 12),
                     child: InkWell(
                       onTap: () => _handleAnswer(index),
                       borderRadius: BorderRadius.circular(10),
                       child: AnimatedContainer(
                         duration: const Duration(milliseconds: 300),
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           color: color,
                           borderRadius: BorderRadius.circular(10),
                           border: Border.all(
                             color: (_isAnswered && index == correctIndex) ? Colors.green : Colors.transparent
                           ),
                         ),
                         child: Row(
                           children: [
                             Expanded(
                               child: Text(
                                 options[index],
                                 style: const TextStyle(color: Colors.white, fontSize: 18),
                               ),
                             ),
                             if (icon != null) Icon(icon, color: Colors.white),
                           ],
                         ),
                       ),
                     ),
                   );
                }),
                
                const Spacer(),
                
                // Explanation
                if (_isAnswered)
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                     child: Text(
                       "💡 $explanation",
                       style: const TextStyle(color: Colors.white70),
                       textAlign: TextAlign.center,
                     ),
                   ).animate().fadeIn(),
                   
                const SizedBox(height: 20),
                
                if (_isAnswered)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentQuestionIndex == _questions.length - 1 ? 'إنهاء' : 'التالي',
                      style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ).animate().scale(),
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }
}
