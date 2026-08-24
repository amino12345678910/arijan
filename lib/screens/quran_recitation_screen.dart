import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/app_theme.dart';
import '../core/quran_utils.dart';

class QuranRecitationScreen extends StatefulWidget {
  final int surahNumber;
  final int startAyahNumber;

  const QuranRecitationScreen({
    super.key,
    required this.surahNumber,
    this.startAyahNumber = 1,
  });

  @override
  State<QuranRecitationScreen> createState() => _QuranRecitationScreenState();
}

class _QuranRecitationScreenState extends State<QuranRecitationScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcribedText = '';
  // List of booleans corresponding to each word in the reference Ayah.
  // true = correct (green), false = incorrect/missed (red).
  List<bool>? _verificationResults;
  
  late int _currentAyah;
  bool _isRevealed = false;
  bool _hasPermission = false;
  String _lastError = "";
  String _lastStatus = "";
  String _usedLocaleId = "";
  List<String> _debugEvents = [];

  @override
  void initState() {
    super.initState();
    _currentAyah = widget.startAyahNumber;
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool granted = false;
    
    // Check permission first (Skip on Web, browser handles it via Speech API)
    if (!kIsWeb) {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }
      granted = status.isGranted;
      
      if (!granted) {
         setState(() {
           _hasPermission = false;
         });
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission is required.')));
         }
         return;
      }
    } else {
      granted = true; // On Web, we proceed to initialize
    }
    
    if (granted) {
      try {
        bool available = await _speech.initialize(
          onStatus: (status) => setState(() => _lastStatus = status),
          onError: (errorNotification) => setState(() => _lastError = errorNotification.errorMsg),
          debugLogging: true,
        );
        setState(() {
          _hasPermission = available; 
          if (!available) _lastError = "Speech init failed (available=false)";
        });
      } catch (e) {
        setState(() => _lastError = "Init Exception: $e");
      }
    }
  }

  void _listen({bool forceArabic = true}) async {
    if (!_isListening) {
      if (!_hasPermission) {
         await _initSpeech();
         if (!_hasPermission) return;
      }

      // Re-init can sometimes help on web if first one failed due to no user interaction
      bool available = _speech.isAvailable;
      if (!available) {
         available = await _speech.initialize(
            onStatus: (s) {
               setState(() => _lastStatus = s);
               // Handle "done" or "notListening" -> Auto Advance regardless of result
               if (s == 'done' || s == 'notListening') {
                  if (_isListening && !_isRevealed) {
                     // Only auto-advance if we actually heard something or it's been a while?
                     // If we advance immediately on 0 text, it might skip if initialization flickers.
                     // IMPORTANT: Check if we have transcribed text. 
                     // If NO text, maybe user didn't speak? Do we skip?
                     // User said "don't stop only if correct... move automatically".
                     // Ideally we verify what we have (even if empty).
                     
                     // Adding a small safety check: Don't auto-advance if it happens INSTANTLY (< 500ms).
                     // But we don't track time here easily.
                     // Let's just verify.
                     _verifyAndAutoAdvance(immediate: false);
                  } else {
                     setState(() => _isListening = false);
                  }
               }
            },
            onError: (e) => setState(() => _lastError = e.errorMsg),
            debugLogging: true,
         );
      }
      
      if (available) {
        setState(() {
            _isListening = true;
            _transcribedText = "";
            _verificationResults = null;
            _isRevealed = false;
        });

        
        String? localeId;
        if (forceArabic) {
            try {
              var locales = await _speech.locales();
              if (locales.isNotEmpty) {
                 try {
                    var arLocale = locales.firstWhere(
                       (element) => element.localeId.toLowerCase().contains("ar"), 
                    );
                    localeId = arLocale.localeId;
                 } catch (e) {}
              } else {
                 localeId = "ar-SA"; 
              }
            } catch (e) {
               localeId = "ar-SA";
            }
        }
        
        setState(() => _usedLocaleId = localeId ?? "Default");

        _speech.listen(
          onResult: (val) {
             setState(() {
                _transcribedText = val.recognizedWords;
             });
             // Real-time Check
             _checkRealTime(val.recognizedWords);
          },
          localeId: localeId,
          cancelOnError: false,
          partialResults: true,
          pauseFor: const Duration(seconds: 4), // Increased to 4s to avoid premature cut-off
          listenFor: const Duration(seconds: 60),
        );
      } else {
          setState(() => _lastError = "Speech not available");
      }
    } else {
       _stopAndNext();
    }
  }

  void _checkRealTime(String spoken) {
      if (_isRevealed) return; // Already verified/done
      
      final referenceAyah = quran.getVerse(widget.surahNumber, _currentAyah, verseEndSymbol: false);
      final results = QuranUtils.compareRecitation(referenceAyah, spoken);
      
      int correctCount = results.where((b) => b).length;
      int totalWords = results.length;
      final normalizedRef = QuranUtils.normalizeArabic(referenceAyah);
      final refWordCount = normalizedRef.split(RegExp(r'\s+')).length;

      // Relaxed Check: If we have > 80% words and accuracy is high?
      // Or if we matched the LAST word of the Ayah?
      
      // Check if we matched the last word?
      bool matchedLast = results.isNotEmpty && results.last;
      
      if ( matchedLast && totalWords >= (refWordCount * 0.7).floor() ) {
          // Likely finished
           _speech.stop();
           _verifyAndAutoAdvance(immediate: true);
           return;
      }

      // Regular high accuracy check
      if ( spoken.split(' ').length >= (refWordCount * 0.8).floor() ) {
         double accuracy = totalWords == 0 ? 0 : correctCount / totalWords;
         if (accuracy >= 0.85) {
             _speech.stop();
             _verifyAndAutoAdvance(immediate: true);
         }
      }
  }

  void _finishAyah(List<bool> results, bool isSuccess) {
      // Deprecated in favor of _verifyAndAutoAdvance
  }

  void _stopListening({bool autoCheck = false}) {
     // Deprecated in favor of _stopAndNext
  }

  void _verifyRecitation() {
     // Deprecated in favor of _verifyAndAutoAdvance
  }

  void _nextAyah({bool autoStart = false}) {
    setState(() {
      _currentAyah++;
      _transcribedText = "";
      _verificationResults = null;
      _isRevealed = false;
    });
    
    if (autoStart) {
       // Small delay to let UI settle
       Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _listen(forceArabic: true);
       });
    }
  }
  // Session Tracking
  final Map<int, List<bool>> _sessionResults = {};
  
  @override
  Widget build(BuildContext context) {
    // Show Summary if finished
    if (_verificationResults == null && _sessionResults.isNotEmpty && _currentAyah > quran.getVerseCount(widget.surahNumber)) {
       return _buildSummaryScreen();
    }

    // Normal Recitation UI
    final referenceAyah = quran.getVerse(widget.surahNumber, _currentAyah, verseEndSymbol: false);
    final normalizedRef = QuranUtils.normalizeArabic(referenceAyah);
    final refWords = normalizedRef.split(RegExp(r'\s+'));

    return Scaffold(
      appBar: AppBar(
        title: Text(
           '${quran.getSurahNameArabic(widget.surahNumber)} - آية $_currentAyah',
           style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
        ),
        backgroundColor: AppTheme.emeraldPrimary,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: Column(
          children: [
            const Spacer(),
            
            // Display Area
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
              ),
              child: _buildAyahText(refWords),
            ),
            
            const SizedBox(height: 20),
            
            if (_isRevealed) ...[
               Text(
                 'سمعنا: $_transcribedText',
                 textAlign: TextAlign.center,
                 style: const TextStyle(color: Colors.white70, fontSize: 14),
               ),
            ],

            // Debug Status (Restored for troubleshooting)
            if (_isListening || _lastStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Status: $_lastStatus ${ _isListening ? "(Listening)" : "" }',
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ),
            
            const Spacer(),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  onPressed: _isListening ? _stopAndNext : () => _listen(forceArabic: true),
                  backgroundColor: _isListening ? Colors.redAccent : AppTheme.goldAccent,
                  child: Icon(_isListening ? Icons.stop : Icons.mic, size: 40, color: _isListening ? Colors.white : AppTheme.emeraldPrimary),
                ).animate(target: _isListening ? 1 : 0).scale(end: const Offset(1.1, 1.1), duration: 500.ms)
                 .then(delay: 500.ms).shake(hz: 2, curve: Curves.easeInOut),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryScreen() {
      return Scaffold(
        appBar: AppBar(
          title: Text(
             'نتائج التلاوة - ${quran.getSurahNameArabic(widget.surahNumber)}',
             style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
          ),
          backgroundColor: AppTheme.emeraldPrimary,
          centerTitle: true,
        ),
        body: Container(
           decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
           child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sessionResults.length,
              itemBuilder: (context, index) {
                  int ayahNum = widget.startAyahNumber + index;
                  List<bool> results = _sessionResults[ayahNum] ?? [];
                  String text = quran.getVerse(widget.surahNumber, ayahNum, verseEndSymbol: false);
                  List<String> words = QuranUtils.normalizeArabic(text).split(' ');
                  
                  return Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                           Text('آية $ayahNum', style: const TextStyle(color: AppTheme.goldAccent, fontSize: 12)),
                           const SizedBox(height: 8),
                           Directionality(
                              textDirection: TextDirection.rtl,
                              child: Wrap(
                                spacing: 4,
                                children: List.generate(words.length, (i) {
                                   bool correct = i < results.length ? results[i] : false;
                                   return Text(
                                      words[i],
                                      style: GoogleFonts.arefRuqaa(
                                         color: correct ? Colors.greenAccent : Colors.redAccent.withOpacity(0.8),
                                         fontSize: 20,
                                      ),
                                   );
                                }),
                              ),
                           )
                        ],
                      ),
                    ),
                  );
              },
           ),
        ),
      );
  }

  void _stopAndNext() {
      // Manual stop -> Assume finished -> Verify & Move
      _speech.stop();
      setState(() => _isListening = false);
      _verifyAndAutoAdvance(immediate: true);
  }

  void _verifyAndAutoAdvance({bool immediate = false}) {
      final referenceAyah = quran.getVerse(widget.surahNumber, _currentAyah, verseEndSymbol: false);
      final results = QuranUtils.compareRecitation(referenceAyah, _transcribedText);
      
      setState(() {
         _verificationResults = results;
         _isRevealed = true;
         _sessionResults[_currentAyah] = results;
      });
      
      // Auto-Advance ALWAYS (User requested "don't stop only if correct")
      // Unless it's completely empty/silent? No, user said "move automatically... don't wait".
      
      if (_currentAyah < quran.getVerseCount(widget.surahNumber)) {
          Future.delayed(Duration(milliseconds: immediate ? 500 : 1500), () {
             if (mounted) _nextAyah(autoStart: true);
          });
      } else {
         // End of Surah
         Future.delayed(const Duration(milliseconds: 1000), () {
             if (mounted) setState(() { _currentAyah++; _verificationResults = null; }); // Trigger Summary
         });
      }
  }

  Widget _buildAyahText(List<String> refWords) {
    // ALWAYS show text, colored if verified
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 12,
          children: List.generate(refWords.length, (index) {
             bool? isCorrect;
             if (_isRevealed && _verificationResults != null && index < _verificationResults!.length) {
                isCorrect = _verificationResults![index];
             }
             
             Color color = Colors.white;
             if (isCorrect == true) color = const Color(0xFF4CAF50);
             if (isCorrect == false) color = const Color(0xFFEF5350);

             return Text(
                refWords[index],
                style: GoogleFonts.arefRuqaa(
                  fontSize: 28,
                  color: color,
                  height: 1.5,
                  shadows: isCorrect == true ? [const Shadow(color: Color(0xFF4CAF50), blurRadius: 10)] : [],
                ),
             ).animate(target: isCorrect == true ? 1 : 0).shimmer(duration: 1200.ms, color: Colors.white54);
          }),
        ),
      );
  }
}
