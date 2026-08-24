import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../data/quran_qaloon_data.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final loadDataFuture = QuranQaloonData.load();
    final delayFuture = Future.delayed(const Duration(seconds: 4));
    
    await Future.wait([loadDataFuture, delayFuture]);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(seconds: 1),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo Container
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.goldAccent.withValues(alpha:0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldAccent.withValues(alpha:0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: Icon(
                  Icons.mosque_rounded,
                  size: 80,
                  color: AppTheme.goldAccent,
                ),
              )
              .animate()
              .scale(duration: 1.seconds, curve: Curves.elasticOut)
              .shimmer(delay: 1.seconds, duration: 1.5.seconds, color: Colors.white),
              
              const SizedBox(height: 30),
              
              Text(
                'أريجان',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              )
              .animate()
              .fadeIn(delay: 500.ms, duration: 800.ms)
              .moveY(begin: 30, end: 0, curve: Curves.easeOutBack),
              
              const SizedBox(height: 10),
              
              Text(
                 'رفيقكم الداتي للعبادة والذكر',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              )
              .animate()
              .fadeIn(delay: 1000.ms, duration: 800.ms),
              
              const SizedBox(height: 50),
              
              const CircularProgressIndicator(
                color: AppTheme.goldAccent,
              ).animate().fadeIn(delay: 1500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
