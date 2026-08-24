
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../data/reciters_data.dart';
import '../../core/app_theme.dart';

class QuranSettingsSheet extends StatelessWidget {
  const QuranSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إعدادات القراءة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
          ),
          const SizedBox(height: 20),
          
          // Font Size
          Row(
            children: [
              const Icon(Icons.format_size, color: AppTheme.emeraldPrimary),
              const SizedBox(width: 10),
              const Text('حجم الخط'),
              Expanded(
                child: Consumer<QuranProvider>(
                  builder: (context, quran, _) {
                    return Slider(
                      value: quran.fontSize,
                      min: 18,
                      max: 60,
                      activeColor: AppTheme.goldAccent,
                      onChanged: (val) => quran.setFontSize(val),
                    );
                  },
                ),
              ),
            ],
          ),
          
          const Divider(),
          
          // Reciter Selection
          const Text('القارئ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Consumer<QuranProvider>(
            builder: (context, quran, _) {
              return DropdownButton<Reciter>(
                isExpanded: true,
                value: quran.selectedReciter,
                dropdownColor: Theme.of(context).cardColor,
                items: RecitersData.reciters.map((reciter) {
                  return DropdownMenuItem(
                    value: reciter,
                    child: Text(reciter.arabicName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) quran.setReciter(val);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
