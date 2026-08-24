import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/data/quran_qaloon.json');
  final jsonStr = file.readAsStringSync();
  final data = jsonDecode(jsonStr);
  
  print('--- Fatiha ---');
  final fatiha = data['data']['surahs'][0]['ayahs'];
  for(var a in fatiha) { 
    final number = a['numberInSurah'];
    final text = a['text'];
    print('\$number: \$text'); 
  }

  print('\n--- Baqarah (First 5) ---');
  final baqarah = data['data']['surahs'][1]['ayahs'];
  for(var i=0; i<5; i++) { 
    final number = baqarah[i]['numberInSurah'];
    final text = baqarah[i]['text'];
    print('\$number: \$text'); 
  }
}
