import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:quran/quran.dart' as quran;
import '../core/app_theme.dart';
import '../data/surah_pages.dart';

Widget buildPdfViewer(BuildContext context, int surahNumber) {
  return _MobilePdfViewer(surahNumber: surahNumber);
}

class _MobilePdfViewer extends StatefulWidget {
  final int surahNumber;
  const _MobilePdfViewer({required this.surahNumber});

  @override
  State<_MobilePdfViewer> createState() => _MobilePdfViewerState();
}

class _MobilePdfViewerState extends State<_MobilePdfViewer> {
  late PdfViewerController _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;

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
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: SfPdfViewer.asset(
        'assets/data/quran_qaloon.pdf',
        controller: _pdfController,
        initialZoomLevel: 1.5,
        pageSpacing: 4,
        onDocumentLoaded: (details) {
          setState(() => _totalPages = details.document.pages.count);
          final page = SurahPages.getPageForSurah(widget.surahNumber);
          Future.delayed(const Duration(milliseconds: 300), () {
            _pdfController.jumpToPage(page);
          });
        },
        onPageChanged: (details) {
          setState(() => _currentPage = details.newPageNumber);
        },
      ),
    );
  }
}
