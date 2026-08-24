
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/app_theme.dart';
import '../../data/adhkar_data.dart';
import 'package:share_plus/share_plus.dart';

class AdhkarFlowScreen extends StatefulWidget {
  final String categoryId;
  final String title;

  const AdhkarFlowScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  State<AdhkarFlowScreen> createState() => _AdhkarFlowScreenState();
}

class _AdhkarFlowScreenState extends State<AdhkarFlowScreen> {
  late List<Map<String, dynamic>> _adhkarList;
  late PageController _pageController;
  int _currentIndex = 0;
  
  // Track counts for each index
  late Map<int, int> _counts;

  @override
  void initState() {
    super.initState();
    _adhkarList = AdhkarData.allAdhkar[widget.categoryId] ?? [];
    _pageController = PageController();
    _counts = {
      for (var i = 0; i < _adhkarList.length; i++) i: 0
    };
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTapCounter(int requiredCount) {
    if (_counts[_currentIndex]! < requiredCount) {
      HapticFeedback.lightImpact();
      setState(() {
         _counts[_currentIndex] = _counts[_currentIndex]! + 1;
      });

      if (_counts[_currentIndex] == requiredCount) {
        HapticFeedback.heavyImpact();
        if (_currentIndex < _adhkarList.length - 1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
               _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
            }
          });
        } else {
           // Completed Show dialogue
           showDialog(
             context: context, 
             builder: (_) => AlertDialog(
               backgroundColor: AppTheme.emeraldPrimary,
               title: const Text('أحسنت!', style: TextStyle(color: Colors.white)),
               content: const Text('أتممت الأذكار بفضل الله', style: TextStyle(color: Colors.white70)),
               actions: [
                 TextButton(
                   onPressed: () { 
                     Navigator.pop(context); // Close dialog
                     Navigator.pop(context); // Close screen
                   },
                   child: const Text('تم', style: TextStyle(color: AppTheme.goldAccent)),
                 )
               ],
             )
           );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_adhkarList.isEmpty) {
       return Scaffold(
         appBar: AppBar(title: Text(widget.title)),
         body: const Center(child: Text('لا توجد أذكار مضافة حالياً')),
       );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.amiri(color: AppTheme.goldAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.goldAccent),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
               // Progress bar
               LinearPercentIndicator(
                  percent: (_currentIndex + 1) / _adhkarList.length,
                  lineHeight: 4,
                  backgroundColor: Colors.white10,
                  progressColor: AppTheme.goldAccent,
                  barRadius: const Radius.circular(2),
                  padding: EdgeInsets.zero,
                  animation: true,
                  animateFromLastPercent: true,
               ),
               
               Expanded(
                 child: PageView.builder(
                   controller: _pageController,
                   itemCount: _adhkarList.length,
                   onPageChanged: (idx) => setState(() => _currentIndex = idx),
                   itemBuilder: (context, index) {
                     final dhikr = _adhkarList[index];
                     final int requiredCount = dhikr['count'] ?? 1;
                     final int currentCount = _counts[index] ?? 0;
                     final double progress = currentCount / requiredCount;
                     final bool isCompleted = currentCount >= requiredCount;
                     
                     return Padding(
                       padding: const EdgeInsets.all(24.0),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           // Count display
                           Text(
                             "${index + 1} / ${_adhkarList.length}",
                             style: const TextStyle(color: Colors.white54),
                           ),
                           const Spacer(),
                           
                           // Arabic Text
                           Text(
                             dhikr['arabic'],
                             textAlign: TextAlign.center,
                             style: GoogleFonts.amiri(
                               fontSize: 28,
                               color: Colors.white,
                               height: 1.6,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           const SizedBox(height: 20),
                           
                           // Translation
                           if (dhikr['translation'] != null)
                             Text(
                               dhikr['translation'],
                               textAlign: TextAlign.center,
                               style: GoogleFonts.montserrat(
                                  color: Colors.white70,
                                  fontSize: 14,
                               ),
                             ),
                           
                           const SizedBox(height: 20),
                           // Reference
                           Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Text(
                                dhikr['reference'] ?? 'مصدر موثوق',
                                style: const TextStyle(color: AppTheme.goldAccent, fontSize: 12),
                              ),
                           ),
                           
                           if (dhikr['reward'] != null && dhikr['reward'].isNotEmpty) ...[
                               const SizedBox(height: 10),
                               Text("Fadilah: ${dhikr['reward']}", style: const TextStyle(color: Colors.greenAccent, fontSize: 12), textAlign: TextAlign.center,),
                           ],

                           const Spacer(),
                           
                           // Counter Button
                           GestureDetector(
                             onTap: () => _onTapCounter(requiredCount),
                             child: CircularPercentIndicator(
                               radius: 60.0,
                               lineWidth: 6.0,
                               percent: progress,
                               center: isCompleted 
                                 ? const Icon(Icons.check, size: 50, color: AppTheme.goldAccent)
                                 : Column(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Text(
                                         "${requiredCount - currentCount}",
                                         style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                       ),
                                       const Text("متبقي", style: TextStyle(color: Colors.white30, fontSize: 10)),
                                     ],
                                   ),
                               progressColor: AppTheme.goldAccent,
                               backgroundColor: Colors.white10,
                               animation: true,
                               animateFromLastPercent: true,
                               circularStrokeCap: CircularStrokeCap.round,
                             ),
                           ),
                           const SizedBox(height: 20),
                           // Actions
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               IconButton(icon: const Icon(Icons.share, color: Colors.white54), onPressed: () {
                                  final text = dhikr['translation'] != null
                                    ? "${dhikr['arabic']}\n\n${dhikr['translation']}"
                                    : "${dhikr['arabic']}";
                                  Share.share(text);
                               }),
                               // IconButton(icon: const Icon(Icons.refresh, color: Colors.white54), onPressed: () {}),
                             ],
                           ),
                           const SizedBox(height: 20),
                         ],
                       ),
                     );
                   },
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
