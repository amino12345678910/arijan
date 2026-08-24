import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../data/mood_data.dart';
import 'chat_screen.dart';

class MoodDetailScreen extends StatelessWidget {
  final Mood mood;

  const MoodDetailScreen({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
               // Implement share logic later
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: Column(
          children: [
            // Hero Header
            Hero(
              tag: 'mood_${mood.id}',
              child: Material(
                elevation: 10,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: mood.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 80),
                        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 10),
                        Text(
                          "أنت تشعر بـ ${mood.label}",
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "والله يسمعك ويرعاك",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle("✨ رسالة من القرآن"),
                    const SizedBox(height: 10),
                    _buildQuranCard(context),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle("🤲 دعاء يريح قلبك"),
                    const SizedBox(height: 10),
                    _buildDuaCard(context),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle("🌱 خطوة عملية"),
                    const SizedBox(height: 10),
                     _buildActionCard(context),

                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              initialMessage: "أشعر بـ ${mood.label}، هل يمكنك نصحي؟",
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.emeraldPrimary,
                        foregroundColor: AppTheme.goldAccent,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(
                        "تحدث مع أريجان عن مشاعرك",
                        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ).animate().shimmer(delay: 1.seconds, duration: 2.seconds),
                     const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.arefRuqaa(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.goldAccent,
      ),
      textAlign: TextAlign.right,
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildQuranCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            "﷽",
            style: GoogleFonts.amiri(fontSize: 24, color: Colors.white60),
          ),
          const SizedBox(height: 10),
          Text(
            mood.remedy.quranVerse,
            style: GoogleFonts.amiri(
              fontSize: 26,
              height: 1.8,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            mood.remedy.quranRef,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppTheme.goldAccent,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

   Widget _buildDuaCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            mood.remedy.dua,
            style: GoogleFonts.cairo(
              fontSize: 18,
              height: 1.6,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
           const SizedBox(height: 10),
           GestureDetector(
             onTap: () {
               Clipboard.setData(ClipboardData(text: mood.remedy.dua));
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text("تم نسخ الدعاء", textAlign: TextAlign.right)),
               );
             },
             child: const Icon(Icons.copy, color: Colors.white38, size: 20),
           ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildActionCard(BuildContext context) {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
       decoration: BoxDecoration(
        color: AppTheme.emeraldPrimary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.goldLight),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              mood.remedy.action,
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
     ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }


}
