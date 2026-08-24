import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../data/adhkar_data.dart';
import '../providers/prayer_provider.dart';
import 'adhkar_list_screen.dart';
import 'quran_home_screen.dart';
import 'settings_screen.dart';
import 'chat_screen.dart';
import 'mood_selector_screen.dart';
import 'quiz/quiz_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
  }

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriCalendar.now();
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const SizedBox(height: 60),
                       // Digital Clock
                       Text(
                         DateFormat('hh:mm a', 'ar').format(prayerProvider.currentTime),
                         style: theme.textTheme.displayLarge?.copyWith(
                           color: AppTheme.goldAccent,
                           fontSize: 50,
                           shadows: [
                             const Shadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 10)
                           ]
                         ),
                       ).animate().fadeIn().scale(),
                       
                       const SizedBox(height: 10),
                       
                      Text(
                        hijriDate.toFormat('dd MMMM yyyy'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      
                      Text(
                        '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                title: const Text('أريجان'),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: AppTheme.goldAccent),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildPrayerCard(context, prayerProvider),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildMoodEntryCard(context),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuranHomeScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.goldAccent, AppTheme.goldLight]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 40, color: AppTheme.emeraldPrimary),
                        const SizedBox(width: 16),
                        Text(
                          "القرآن الكريم",
                          style: GoogleFonts.amiri(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.emeraldPrimary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().shimmer(duration: 2.seconds, delay: 1.seconds),
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = AdhkarData.categories[index];
                    return _buildCategoryCard(context, category, index);
                  },
                  childCount: AdhkarData.categories.length,
                ),
              ),
            ),
            
            // Quiz Section
             SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => QuizSelectionScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                          child: const Icon(Icons.quiz, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "اختبر معلوماتك",
                              style: GoogleFonts.amiri(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                             Text(
                              "مسابقات في معاني السور",
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                      ],
                    ),
                  ).animate().slideX(begin: 0.1, duration: 800.ms).fadeIn(),
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldAccent.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          },
          backgroundColor: AppTheme.goldAccent,
          child: const Icon(Icons.auto_awesome, color: Colors.black, size: 28),
        ),
      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildPrayerCard(BuildContext context, PrayerProvider provider) {
    final nextPrayer = provider.nextPrayer;
    final nextPrayerName = provider.getPrayerName(nextPrayer);
    final theme = Theme.of(context);
    final timeLeft = provider.timeUntilNextPrayer;

    String timeLeftString = "--:--:--";
    if (timeLeft != null) {
        timeLeftString = "${timeLeft.inHours.toString().padLeft(2, '0')}:${(timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:${(timeLeft.inSeconds % 60).toString().padLeft(2, '0')}";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Glass effect
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, 
            blurRadius: 15, 
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الصلاة القادمة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.goldLight,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      nextPrayerName.isNotEmpty ? nextPrayerName : '...',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (provider.isPlayingAdhan)
                  GestureDetector(
                    onTap: () => provider.stopAdhan(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: const Icon(Icons.volume_off_rounded, size: 35, color: Colors.white)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
                    ),
                  )
                else
                  Icon(Icons.mosque, size: 45, color: AppTheme.goldAccent)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 2.seconds, color: Colors.white54),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    timeLeftString,
                    style: GoogleFonts.robotoMono(
                      color: AppTheme.goldAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
             Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      provider.coordinates == null ? Icons.location_off : Icons.location_on,
                      color: Colors.white60,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        provider.locationStatus,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppTheme.goldAccent, size: 20),
                      onPressed: () => provider.refreshLocation(),
                      tooltip: 'تحديث الموقع',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, duration: 600.ms).fadeIn();
  }

  Widget _buildCategoryCard(BuildContext context, category, int index) {
     return InkWell(
       onTap: () {
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => AdhkarListScreen(category: category),
           ),
         );
       },
       borderRadius: BorderRadius.circular(24),
       child: Container(
         decoration: BoxDecoration(
           gradient: LinearGradient(
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: [
               Colors.white.withOpacity(0.15),
               Colors.white.withOpacity(0.05),
             ],
           ),
           borderRadius: BorderRadius.circular(24),
           border: Border.all(color: Colors.white.withOpacity(0.1)),
           boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
           ],
         ),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book_rounded, size: 32, color: AppTheme.goldAccent),
              ),
              const SizedBox(height: 16),
              Text(
                category.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
         ),
       ).animate().scale(delay: (100 * index).ms, duration: 400.ms).moveY(begin: 20, end: 0, delay: (50 * index).ms),
     );
  }

  Widget _buildMoodEntryCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MoodSelectorScreen()),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF134E5E), Color(0xFF71B280)], // Mystic Teal - Healing & Calming
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
             BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مورد الروح",
                  style: GoogleFonts.arefRuqaa(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "كيف تشعر اليوم؟",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.white.withOpacity(0.2),
                 shape: BoxShape.circle,
               ),
               child: const Text("🌿", style: TextStyle(fontSize: 30))
               .animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
             ),
          ],
        ),
      ).animate().slideX(begin: 0.1, duration: 800.ms).fadeIn(),
    );
  }


}
