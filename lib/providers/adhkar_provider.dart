
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhkarProvider with ChangeNotifier {
  SharedPreferences? _prefs;
  
  // Map of Category -> Completed Count for today
  Map<String, int> _dailyProgress = {};
  
  // Current active counter in UI
  int _currentCounter = 0;
  
  AdhkarProvider() {
    _loadPrefs();
  }
  
  int get currentCounter => _currentCounter;

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Reset logic if new day? 
    // keeping it simple for now.
    notifyListeners();
  }

  void incrementCounter() {
    _currentCounter++;
    notifyListeners();
  }

  void resetCounter() {
    _currentCounter = 0;
    notifyListeners();
  }
  
  void markCategoryComplete(String category) {
    // Logic to track streaks
  }
}
