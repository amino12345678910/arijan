import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../data/quran_qaloon_data.dart';
import 'quran_recitation_screen.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final verseCount = QuranQaloonData.getVerseCount(widget.surahNumber);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          quran.getSurahNameArabic(widget.surahNumber),
          style: GoogleFonts.amiri(
            fontWeight: FontWeight.bold, 
            color: AppTheme.goldAccent, 
            fontSize: 28,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 2))
            ]
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppTheme.goldAccent),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                // Surah Header
                if (widget.surahNumber != 9)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        'assets/svgs/basmala_frame.png',
                        height: 80,
                        color: AppTheme.goldAccent, 
                        errorBuilder: (context, error, stackTrace) => Text(
                          quran.basmala,
                          style: GoogleFonts.amiri(
                            fontSize: 36,
                            color: AppTheme.goldAccent, 
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 1.seconds).scale(),
                
                // Verses Text Area
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.goldAccent.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      children: [
                        for (int i = 1; i <= verseCount; i++) ...[
                          TextSpan(
                            text: (() {
                              String verseText = QuranQaloonData.getVerse(widget.surahNumber, i);
                              
                              // Remove duplicated Basmalah logic
                              if (i == 1 && widget.surahNumber != 1 && widget.surahNumber != 9) {
                                final basmalaVariations = AppConstants.basmalaVariations;
                                for (final prefix in basmalaVariations) {
                                  if (verseText.startsWith(prefix)) {
                                    return verseText.substring(prefix.length).trim() + " ";
                                  }
                                }
                              }
                              return verseText + " ";
                            })(),
                            style: GoogleFonts.amiri(
                              fontSize: 32,
                              color: Colors.white,
                              height: 1.8,
                              fontWeight: FontWeight.w400,
                              shadows: [
                                const Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1, 1))
                              ]
                            ),
                          ),
                          
                          // Verse End Symbol inline
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.5), width: 1.5),
                                color: Colors.black.withOpacity(0.2),
                              ),
                              child: Text(
                                quran.getVerseEndSymbol(i, arabicNumeral: true),
                                style: GoogleFonts.amiri(
                                  color: AppTheme.goldAccent,
                                  fontSize: 16,
                                  height: 1, // Reset line height for circle centering
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: "  "), // Spacing after Ayah circle
                        ],
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms),
                ),
                const SizedBox(height: 80), // Padding for floating action button
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuranRecitationScreen(
                surahNumber: widget.surahNumber,
                // Default to first verse or whatever logic
              ),
            ),
          );
        },
        backgroundColor: AppTheme.goldAccent,
        icon: const Icon(Icons.mic, color: AppTheme.emeraldPrimary),
        label: Text(
          'تسميع',
          style: GoogleFonts.amiri(
            color: AppTheme.emeraldPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
