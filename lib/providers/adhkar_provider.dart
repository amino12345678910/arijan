import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhkarProvider with ChangeNotifier {
  SharedPreferences? _prefs;

  int _currentCounter = 0;
  Map<String, int> _completedToday = {};
  int _streak = 0;

  AdhkarProvider() {
    _loadPrefs();
  }

  int get currentCounter => _currentCounter;
  int get streak => _streak;
  Map<String, int> get completedToday => _completedToday;

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _streak = _prefs?.getInt('adhkar_streak') ?? 0;
    final lastDate = _prefs?.getString('adhkar_last_date') ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastDate != today) {
      _completedToday = {};
    }
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
    _completedToday[category] = (_completedToday[category] ?? 0) + 1;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = _prefs?.getString('adhkar_last_date') ?? '';
    if (lastDate != today) {
      _streak++;
      _prefs?.setInt('adhkar_streak', _streak);
      _prefs?.setString('adhkar_last_date', today);
    }
    notifyListeners();
  }
}
