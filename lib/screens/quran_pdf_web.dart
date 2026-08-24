// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import '../core/app_theme.dart';
import '../data/surah_pages.dart';

Widget buildPdfViewer(BuildContext context, int surahNumber) {
  final page = SurahPages.getPageForSurah(surahNumber);
  final viewId = 'pdf-viewer-$surahNumber';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final iframe = html.IFrameElement()
      ..src = 'assets/assets/data/quran_qaloon.pdf#page=$page'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    return iframe;
  });

  return Scaffold(
    backgroundColor: const Color(0xFF1a1a1a),
    appBar: AppBar(
      title: Text(
        quran.getSurahNameArabic(surahNumber),
        style: GoogleFonts.amiri(
          fontWeight: FontWeight.bold,
          color: AppTheme.goldAccent,
          fontSize: 24,
        ),
      ),
      backgroundColor: AppTheme.emeraldPrimary,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppTheme.goldAccent),
    ),
    body: HtmlElementView(viewType: viewId),
  );
}
