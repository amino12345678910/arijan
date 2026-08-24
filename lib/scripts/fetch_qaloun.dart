import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final url = Uri.parse('https://api.alquran.cloud/v1/quran/quran-qaloon');
  print('Fetching Qaloun data from \$url...');
  
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    print('Data fetched successfully. Saving to assets/data/quran_qaloon.json...');
    
    final dir = Directory('assets/data');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final file = File('assets/data/quran_qaloon.json');
    await file.writeAsString(response.body);
    print('Saved successfully to \${file.path}');
  } else {
    print('Failed to fetch data. Status code: \${response.statusCode}');
  }
}
