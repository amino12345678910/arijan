import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:quran/quran.dart' as quran;
import '../core/app_theme.dart';
import '../data/surah_pages.dart';

class QuranPdfScreen extends StatefulWidget {
  final int surahNumber;

  const QuranPdfScreen({super.key, required this.surahNumber});

  @override
  State<QuranPdfScreen> createState() => _QuranPdfScreenState();
}

class _QuranPdfScreenState extends State<QuranPdfScreen> {
  late PdfViewerController _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _goToSurah(int surahNumber) {
    final page = SurahPages.getPageForSurah(surahNumber);
    _pdfController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: Text(
          quran.getSurahNameArabic(widget.surahNumber),
          style: GoogleFonts.amiri(
            fontWeight: FontWeight.bold,
            color: AppTheme.goldAccent,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppTheme.emeraldPrimary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.goldAccent),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.asset(
            'assets/data/quran_qaloon.pdf',
            controller: _pdfController,
            initialZoomLevel: 1.0,
            pageSpacing: 4,
            canShowScrollHead: true,
            canShowPageLoadingIndicator: true,
            onDocumentLoaded: (details) {
              setState(() {
                _totalPages = details.document.pages.count;
                _isLoading = false;
              });
              _goToSurah(widget.surahNumber);
            },
            onPageChanged: (details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.goldAccent),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل المصحف...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppTheme.emeraldPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.skip_next, color: AppTheme.goldAccent),
              onPressed: widget.surahNumber > 1
                  ? () => _goToSurah(widget.surahNumber - 1)
                  : null,
              tooltip: 'السورة السابقة',
            ),
            Expanded(
              child: Center(
                child: Text(
                  'صفحة $_currentPage',
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous, color: AppTheme.goldAccent),
              onPressed: widget.surahNumber < 114
                  ? () => _goToSurah(widget.surahNumber + 1)
                  : null,
              tooltip: 'السورة التالية',
            ),
          ],
        ),
      ),
    );
  }
}
