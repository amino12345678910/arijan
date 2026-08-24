
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_theme.dart';
import 'adhkar_flow_screen.dart';

class AdhkarHomeScreen extends StatelessWidget {
  const AdhkarHomeScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'id': 'morning', 'title': 'أذكار الصباح', 'icon': Icons.wb_sunny_outlined, 'color': Color(0xFFFDB813)},
    {'id': 'evening', 'title': 'أذكار المساء', 'icon': Icons.nights_stay_outlined, 'color': Color(0xFF3F51B5)},
    {'id': 'sleep', 'title': 'أذكار النوم', 'icon': Icons.bed_outlined, 'color': Color(0xFF673AB7)},
    {'id': 'waking', 'title': 'أذكار الاستيقاظ', 'icon': Icons.alarm, 'color': Color(0xFF009688)},
    {'id': 'post_prayer', 'title': 'أذكار بعد الصلاة', 'icon': Icons.mosque_outlined, 'color': AppTheme.goldAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الأذكار', style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
        backgroundColor: AppTheme.emeraldPrimary,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdhkarFlowScreen(
                      categoryId: cat['id'],
                      title: cat['title'],
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat['icon'], size: 40, color: cat['color']),
                    const SizedBox(height: 12),
                    Text(
                      cat['title'],
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().scale(delay: (index * 100).ms, duration: 400.ms),
            );
          },
        ),
      ),
    );
  }
}
