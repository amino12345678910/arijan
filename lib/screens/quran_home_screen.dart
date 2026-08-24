import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../data/quran_qaloon_data.dart';
import 'quran_pdf_screen.dart';

class QuranHomeScreen extends StatelessWidget {
  const QuranHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('القرآن الكريم'),
         backgroundColor: AppTheme.emeraldPrimary,
         foregroundColor: AppTheme.goldAccent,
       ),
       body: Container(
         decoration: const BoxDecoration(
            gradient: AppTheme.mainGradient,
         ),
         child: ListView.builder(
           padding: const EdgeInsets.all(16),
           itemCount: 114,
           itemBuilder: (context, index) {
             final surahNumber = index + 1;
             return Card(
               margin: const EdgeInsets.only(bottom: 12),
               color: Colors.white.withValues(alpha:0.08),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(16),
                 side: BorderSide(color: Colors.white.withValues(alpha:0.1)),
               ),
               child: ListTile(
                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 leading: Container(
                   width: 44,
                   height: 44,
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     gradient: const LinearGradient(
                       colors: [AppTheme.goldLight, AppTheme.goldAccent],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     boxShadow: const [
                       BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                     ],
                     border: Border.all(color: Colors.white, width: 1.5),
                   ),
                   child: Center(
                     child: Text(
                       '$surahNumber',
                       style: const TextStyle(
                         color: Color(0xFF1A4D2E), // Emerald dark
                         fontWeight: FontWeight.w900,
                         fontSize: 16,
                       ),
                     ),
                   ),
                 ),
                 title: Text(
                   quran.getSurahNameArabic(surahNumber),
                   style: GoogleFonts.amiri(
                     fontSize: 22,
                     fontWeight: FontWeight.bold,
                     color: Colors.white,
                   ),
                 ),
                 subtitle: Text(
                   '${quran.getPlaceOfRevelation(surahNumber)} • ${QuranQaloonData.getVerseCount(surahNumber)} آية',
                   style: TextStyle(
                     color: Colors.white.withValues(alpha:0.6),
                     fontSize: 12,
                   ),
                 ),
                 trailing: Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha:0.3), size: 16),
                 onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => QuranPdfScreen(surahNumber: surahNumber)),
                   );
                 },
               ),
             ).animate().fadeIn(delay: (20 * (index % 10)).ms).slideX(begin: 0.1, duration: 300.ms);
           },
         ),
       ),
     );
  }
}
