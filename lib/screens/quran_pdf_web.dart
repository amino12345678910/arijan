// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import '../core/app_theme.dart';
import '../data/surah_pages.dart';

Widget buildPdfViewer(BuildContext context, int surahNumber) {
  return _WebPdfViewer(surahNumber: surahNumber);
}

class _WebPdfViewer extends StatefulWidget {
  final int surahNumber;
  const _WebPdfViewer({required this.surahNumber});

  @override
  State<_WebPdfViewer> createState() => _WebPdfViewerState();
}

class _WebPdfViewerState extends State<_WebPdfViewer> {
  late String _viewId;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = SurahPages.getPageForSurah(widget.surahNumber);
    _viewId = 'quran-pdf-${DateTime.now().millisecondsSinceEpoch}';
    _registerView();
  }

  void _registerView() {
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int id) {
      final embed = html.EmbedElement()
        ..src = 'assets/assets/data/quran_qaloon.pdf#page=$_currentPage&toolbar=0&navpanes=0&scrollbar=0&view=FitH'
        ..type = 'application/pdf'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#1a1a1a';
      return embed;
    });
  }

  void _navigateToPage(int page) {
    setState(() {
      _currentPage = page;
      _viewId = 'quran-pdf-${DateTime.now().millisecondsSinceEpoch}';
      _registerView();
    });
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
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'صفحة $_currentPage / 332',
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: HtmlElementView(viewType: _viewId),
      bottomNavigationBar: Container(
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFF0A261D),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_next, color: AppTheme.goldAccent),
              onPressed: _currentPage > 1
                  ? () => _navigateToPage(_currentPage - 1)
                  : null,
              tooltip: 'الصفحة السابقة',
            ),
            IconButton(
              icon: const Icon(Icons.first_page, color: AppTheme.goldAccent),
              onPressed: widget.surahNumber > 1
                  ? () => _navigateToPage(SurahPages.getPageForSurah(widget.surahNumber - 1))
                  : null,
              tooltip: 'السورة السابقة',
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${quran.getSurahNameArabic(widget.surahNumber)}',
                style: GoogleFonts.amiri(color: Colors.white, fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.last_page, color: AppTheme.goldAccent),
              onPressed: widget.surahNumber < 114
                  ? () => _navigateToPage(SurahPages.getPageForSurah(widget.surahNumber + 1))
                  : null,
              tooltip: 'السورة التالية',
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous, color: AppTheme.goldAccent),
              onPressed: _currentPage < 332
                  ? () => _navigateToPage(_currentPage + 1)
                  : null,
              tooltip: 'الصفحة التالية',
            ),
          ],
        ),
      ),
    );
  }
}
