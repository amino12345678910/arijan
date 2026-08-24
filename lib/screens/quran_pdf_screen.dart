import 'package:flutter/material.dart';

import 'quran_pdf_web.dart' if (dart.library.io) 'quran_pdf_mobile.dart' as platform_pdf;

class QuranPdfScreen extends StatelessWidget {
  final int surahNumber;

  const QuranPdfScreen({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    return platform_pdf.buildPdfViewer(context, surahNumber);
  }
}
