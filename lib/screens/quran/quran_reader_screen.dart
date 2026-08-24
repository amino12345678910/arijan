
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_theme.dart';
import '../../providers/quran_provider.dart';
import 'quran_settings_sheet.dart';

class QuranReaderScreen extends StatefulWidget {
  final int surahNumber;
  final int? startAtAyah;

  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    this.startAtAyah,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    if (widget.startAtAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _itemScrollController.jumpTo(index: widget.startAtAyah! - 1);
      });
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuranSettingsSheet(),
    );
  }

  void _handleAyahTap(int ayahNumber) {
     // Show context menu or play
     final quranProvider = Provider.of<QuranProvider>(context, listen: false);
     quranProvider.playAudio(widget.surahNumber, ayahNumber);
  }
  
  void _handleAyahLongPress(int ayahNumber, String text) {
     showModalBottomSheet(
        context: context,
        builder: (context) {
           return Container(
             padding: const EdgeInsets.all(16),
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 ListTile(
                   leading: const Icon(Icons.copy),
                   title: const Text('نسخ الآية'),
                   onTap: () {
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
                   },
                 ),
                 ListTile(
                   leading: const Icon(Icons.share),
                   title: const Text('مشاركة'),
                   onTap: () {
                      Share.share(text); // Need share_plus, adding to pubspec next step if missing or use basic share
                      Navigator.pop(context);
                   },
                 ),
                 ListTile(
                   leading: const Icon(Icons.bookmark),
                   title: const Text('إضافة للمفضلة'),
                   onTap: () {
                      Provider.of<QuranProvider>(context, listen: false).toggleFavorite(widget.surahNumber, ayahNumber);
                      Navigator.pop(context);
                   },
                 ),
               ],
             ),
           );
        }
     );
  }

  @override
  Widget build(BuildContext context) {
    // Need access to provider values
    return Consumer<QuranProvider>(
      builder: (context, quranProvider, _) {
        final verseCount = quran.getVerseCount(widget.surahNumber);
        
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              quran.getSurahNameArabic(widget.surahNumber),
              style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppTheme.goldAccent),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showSettings,
              ),
            ],
          ),
          body: Container(
             decoration: const BoxDecoration(
                gradient: AppTheme.mainGradient,
             ),
             child: SafeArea(
               child: Column(
                 children: [
                    // Audio Bar (if playing)
                    if (quranProvider.isPlaying || quranProvider.currentPlayingSurah == widget.surahNumber)
                       Container(
                         color: Colors.black26,
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                         child: Row(
                           children: [
                              IconButton(
                                icon: Icon(quranProvider.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                                onPressed: () {
                                   if (quranProvider.isPlaying) {
                                      quranProvider.pauseAudio();
                                   } else {
                                      quranProvider.playAudio(quranProvider.currentPlayingSurah, quranProvider.currentPlayingAyah);
                                   }
                                },
                              ),
                              Expanded(
                                child: Text(
                                   "الآية ${quranProvider.currentPlayingAyah} - ${quranProvider.selectedReciter.arabicName}",
                                   style: const TextStyle(color: Colors.white),
                                   textAlign: TextAlign.center,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.stop, color: Colors.redAccent),
                                onPressed: () => quranProvider.stopAudio(),
                              )
                           ],
                         ),
                       ),
                         
                    Expanded(
                      child: ScrollablePositionedList.builder(
                         itemScrollController: _itemScrollController,
                         itemPositionsListener: _itemPositionsListener,
                         itemCount: verseCount + (widget.surahNumber == 9 ? 0 : 1), // Be careful with index
                         itemBuilder: (context, index) {
                            // Basmala Logic
                            if (widget.surahNumber != 9 && index == 0) {
                               return Padding(
                                 padding: const EdgeInsets.symmetric(vertical: 20),
                                 child: Center(
                                   child: Text(
                                      quran.basmala,
                                      style: GoogleFonts.amiri(
                                        fontSize: 30,
                                        color: AppTheme.goldAccent,
                                      ),
                                   ),
                                 ),
                               );
                            }
                            
                            int ayahNum = (widget.surahNumber == 9) ? index + 1 : index;
                            
                            bool isPlayingThis = (quranProvider.currentPlayingSurah == widget.surahNumber && quranProvider.currentPlayingAyah == ayahNum);
                            bool isFavorite = quranProvider.isFavorite(widget.surahNumber, ayahNum);
                            
                            String text = quran.getVerse(widget.surahNumber, ayahNum, verseEndSymbol: true);
                            
                            return GestureDetector(
                              onTap: () => _handleAyahTap(ayahNum),
                              onLongPress: () => _handleAyahLongPress(ayahNum, text),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isPlayingThis ? AppTheme.goldAccent.withOpacity(0.2) : Colors.transparent,
                                  border: Border(bottom: BorderSide(color: Colors.white12)),
                                ),
                                child: Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.getFont(
                                    quranProvider.fontFamily,
                                    fontSize: quranProvider.fontSize,
                                    color: isFavorite ? Colors.yellowAccent : Colors.white,
                                    height: 2.0,
                                  ),
                                ),
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
      },
    );
  }
}
