
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quran/quran.dart' as quran;
import '../data/reciters_data.dart';

class QuranProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  SharedPreferences? _prefs;

  // Settings
  double _fontSize = 28.0;
  String _fontFamily = 'Amiri'; // Options: Amiri, Aref Ruqaa
  bool _isMushafMode = false; // Page view vs List view

  // Specifics
  Reciter _selectedReciter = RecitersData.reciters.first;
  
  // State
  bool _isPlaying = false;
  int _currentPlayingSurah = 1;
  int _currentPlayingAyah = 1;
  
  // Data
  List<String> _favorites = []; // stored as "surah_ayah"
  List<String> _bookmarks = []; 
  int _lastReadSurah = 1;
  int _lastReadAyah = 1;

  QuranProvider() {
    _loadPrefs();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
       _playNextAyah();
    });
  }

  // Getters
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  bool get isMushafMode => _isMushafMode;
  Reciter get selectedReciter => _selectedReciter;
  bool get isPlaying => _isPlaying;
  int get currentPlayingSurah => _currentPlayingSurah;
  int get currentPlayingAyah => _currentPlayingAyah;
  List<String> get favorites => _favorites;
  int get lastReadSurah => _lastReadSurah;
  int get lastReadAyah => _lastReadAyah;

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _fontSize = _prefs?.getDouble('fontSize') ?? 28.0;
    _fontFamily = _prefs?.getString('fontFamily') ?? 'Amiri';
    _isMushafMode = _prefs?.getBool('isMushafMode') ?? false;
    
    String? reciterId = _prefs?.getString('reciterId');
    if (reciterId != null) {
      try {
        _selectedReciter = RecitersData.reciters.firstWhere((r) => r.id == reciterId);
      } catch (_) {}
    }
    
    _favorites = _prefs?.getStringList('favorites') ?? [];
    _bookmarks = _prefs?.getStringList('bookmarks') ?? [];
    _lastReadSurah = _prefs?.getInt('lastReadSurah') ?? 1;
    _lastReadAyah = _prefs?.getInt('lastReadAyah') ?? 1;
    notifyListeners();
  }

  // Settings Methods
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await _prefs?.setDouble('fontSize', size);
    notifyListeners();
  }

  Future<void> setReciter(Reciter reciter) async {
    _selectedReciter = reciter;
    await _prefs?.setString('reciterId', reciter.id);
    notifyListeners();
  }

  // Audio Methods
  Future<void> playAudio(int surah, int ayah) async {
     _currentPlayingSurah = surah;
     _currentPlayingAyah = ayah;
     
     // Construct URL
     // Format: https://server.mp3quran.net/afs/001001.mp3
     // Pad Surah and Ayah to 3 digits
     String surahPad = surah.toString().padLeft(3, '0');
     String ayahPad = ayah.toString().padLeft(3, '0');
     String url = "${_selectedReciter.serverUrl}/$surahPad$ayahPad.mp3";
     
     if (kDebugMode) {
       print("Playing: $url");
     }

     try {
       await _audioPlayer.play(UrlSource(url));
     } catch (e) {
       if (kDebugMode) {
         print("Audio Error: $e");
       }
     }
     notifyListeners();
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }
  
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  void _playNextAyah() {
     int nextAyah = _currentPlayingAyah + 1;
     int totalVerses = quran.getVerseCount(_currentPlayingSurah);
     
     if (nextAyah <= totalVerses) {
        playAudio(_currentPlayingSurah, nextAyah);
     } else {
        // End of Surah, stop or go next surah?
        // Basic version: stop
        _audioPlayer.stop();
     }
  }

  // Interaction Methods
  void toggleFavorite(int surah, int ayah) {
     String key = "${surah}_$ayah";
     if (_favorites.contains(key)) {
        _favorites.remove(key);
     } else {
        _favorites.add(key);
     }
     _prefs?.setStringList('favorites', _favorites);
     notifyListeners();
  }
  
  bool isFavorite(int surah, int ayah) {
     return _favorites.contains("${surah}_$ayah");
  }

  Future<void> setLastRead(int surah, int ayah) async {
    _lastReadSurah = surah;
    _lastReadAyah = ayah;
    await _prefs?.setInt('lastReadSurah', surah);
    await _prefs?.setInt('lastReadAyah', ayah);
    notifyListeners();
  }
}
