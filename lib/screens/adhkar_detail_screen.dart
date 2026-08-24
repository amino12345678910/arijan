import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/models.dart';
import '../core/app_theme.dart';
import 'dart:ui';

class AdhkarDetailScreen extends StatefulWidget {
  final AdhkarItem item;
  const AdhkarDetailScreen({super.key, required this.item});

  @override
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen> {
  late int _currentCount;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _currentCount = 0;
  }

  void _increment() {
    if (_currentCount < widget.item.count) {
      setState(() {
        _currentCount++;
      });
      HapticFeedback.lightImpact();
      
      if (_currentCount == widget.item.count) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isCompleted = true;
        });
        // Success Animation/Feedback
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             backgroundColor: AppTheme.emeraldPrimary,
             content: const Text(
               'تقبل الله منك', 
               textAlign: TextAlign.center,
               style: TextStyle(fontFamily: 'Amiri', fontSize: 18),
             ),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
           ),
         );
      }
    }
  }

  void _reset() {
    setState(() {
      _currentCount = 0;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.item.count > 0 ? _currentCount / widget.item.count : 0.0;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'إعادة',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF004D40), // Deep Emerald
              Color(0xFF000000), // Black
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern/Glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldAccent.withOpacity(0.2),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2), duration: 4.seconds),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Text Area
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.item.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 28,
                                height: 2.0,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 600.ms).moveY(begin: 20),
                            
                            if (widget.item.reference != null) ...[
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text(
                                  widget.item.reference!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ).animate().fadeIn(delay: 300.ms),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Interactive Counter
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50, top: 20),
                    child: GestureDetector(
                      onTap: _increment,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow Effect
                          if (_isCompleted)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.goldAccent.withOpacity(0.6),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  )
                                ],
                              ),
                            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                          // Progress Ring
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: 1.0, // Background ring
                              color: Colors.white.withOpacity(0.1),
                              strokeWidth: 8,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: widget.item.count > 0 ? progress : 1.0,
                              color: _isCompleted ? AppTheme.goldAccent : Colors.white,
                              backgroundColor: Colors.transparent,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                            ),
                          ),

                          // Inner Content (Count)
                          Container(
                            width: 84, // Slightly smaller than ring
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCompleted ? AppTheme.goldAccent : Colors.white.withOpacity(0.15),
                            ),
                            child: Center(
                              child: _isCompleted
                                  ? const Icon(Icons.check, size: 40, color: Colors.black)
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$_currentCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'من ${widget.item.count}',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.6),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
