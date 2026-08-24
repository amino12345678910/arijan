import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adhan/adhan.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PrayerProvider with ChangeNotifier {
  Coordinates? _coordinates;
  PrayerTimes? _prayerTimes;
  CalculationParameters? _params = CalculationMethod.muslim_world_league.getParameters();
  String _locationStatus = "لم يتم تحديد الموقع";
  Duration? _timeUntilNextPrayer;
  bool _isPlayingAdhan = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;

  String get locationStatus => _locationStatus;
  Coordinates? get coordinates => _coordinates;
  Duration? get timeUntilNextPrayer => _timeUntilNextPrayer;
  bool get isPlayingAdhan => _isPlayingAdhan;
  PrayerTimes? get prayerTimes => _prayerTimes;
  DateTime get currentTime => DateTime.now();

  PrayerProvider() {
    _coordinates = Coordinates(21.4225, 39.8262); // Makkah default fallback
    updatePrayerTimes();
    refreshLocation();
    _startTimer();
  }

  String _lastCountdownString = '';

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateNextPrayerCountdown();
      final newString = _formatCountdown();
      if (newString != _lastCountdownString) {
        _lastCountdownString = newString;
        notifyListeners();
      }
    });
  }

  String _formatCountdown() {
    if (_timeUntilNextPrayer == null) return '--:--:--';
    final t = _timeUntilNextPrayer!;
    return '${t.inHours.toString().padLeft(2, '0')}:${(t.inMinutes % 60).toString().padLeft(2, '0')}:${(t.inSeconds % 60).toString().padLeft(2, '0')}';
  }
  
  Future<void> refreshLocation() async {
    _locationStatus = "جاري البحث عن الموقع...";
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationStatus = "خدمة الموقع غير مفعلة (مكة المكرمة افتراضياً)";
        updatePrayerTimes();
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationStatus = "تم رفض الإذن (مكة المكرمة افتراضياً)";
          updatePrayerTimes();
          notifyListeners();
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _locationStatus = "الإذن مرفوض نهائياً (مكة المكرمة افتراضياً)";
        updatePrayerTimes();
        notifyListeners();
        return;
      } 

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      _coordinates = Coordinates(position.latitude, position.longitude);
      
      try {
        // Try Native Geocoding first (Works on Mobile)
        if (!kIsWeb) {
            List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              _locationStatus = "${place.locality ?? place.subAdministrativeArea}, ${place.country}";
            } else {
               throw Exception("No placemarks");
            }
        } else {
            throw Exception("Web requires API key, fallback needed");
        }
      } catch (nativeError) {
         // Fallback: OpenStreetMap API (Free, works on Web without key)
         debugPrint("Native Geocoding failed: $nativeError. Trying OSM...");
         try {
             final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&accept-language=ar');
             final response = await http.get(url, headers: {'User-Agent': 'ArijApp/1.0'});
             
             if (response.statusCode == 200) {
                 final data = json.decode(response.body);
                 final address = data['address'];
                 String city = address['city'] ?? address['town'] ?? address['village'] ?? address['state'] ?? '';
                 String country = address['country'] ?? '';
                 _locationStatus = "$city, $country";
             } else {
                 throw Exception("OSM Failed");
             }
         } catch (osmError) {
             debugPrint("OSM Geocoding failed: $osmError");
             _locationStatus = "تم تحديد الموقع";
         }
      }

      updatePrayerTimes();
    } catch (e) {
      _locationStatus = "مكة المكرمة افتراضياً";
      debugPrint("Error getting location: $e");
      updatePrayerTimes();
      notifyListeners();
    }
  }

  void updatePrayerTimes() {
    if (_coordinates != null && _params != null) {
      final myDate = DateComponents.from(DateTime.now());
      _prayerTimes = PrayerTimes(_coordinates!, myDate, _params!);
      _calculateNextPrayerCountdown();
      notifyListeners();
    }
  }
  
  Prayer _nextPrayer = Prayer.none;

  void _calculateNextPrayerCountdown() {
    if (_prayerTimes == null || _coordinates == null || _params == null) return;
    
    final now = DateTime.now();
    DateTime? targetTime;
    Prayer next = Prayer.none;

    // Manually check all prayers for today to find the next one
    if (_prayerTimes!.fajr.isAfter(now)) {
      targetTime = _prayerTimes!.fajr;
      next = Prayer.fajr;
    } else if (_prayerTimes!.sunrise.isAfter(now)) {
      targetTime = _prayerTimes!.sunrise;
      next = Prayer.sunrise;
    } else if (_prayerTimes!.dhuhr.isAfter(now)) {
      targetTime = _prayerTimes!.dhuhr;
      next = Prayer.dhuhr;
    } else if (_prayerTimes!.asr.isAfter(now)) {
      targetTime = _prayerTimes!.asr;
      next = Prayer.asr;
    } else if (_prayerTimes!.maghrib.isAfter(now)) {
      targetTime = _prayerTimes!.maghrib;
      next = Prayer.maghrib;
    } else if (_prayerTimes!.isha.isAfter(now)) {
      targetTime = _prayerTimes!.isha;
      next = Prayer.isha;
    }
    
    // If we passed all prayers today, next is Tomorrow's Fajr
    if (targetTime == null) {
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowPrayerTimes = PrayerTimes(
        _coordinates!,
        DateComponents.from(tomorrow),
        _params!,
      );
      targetTime = tomorrowPrayerTimes.fajr;
      next = Prayer.fajr;
    }

    _nextPrayer = next;

    _timeUntilNextPrayer = targetTime.difference(now);

    if (_timeUntilNextPrayer!.inSeconds == 0 && !_isPlayingAdhan) {
      playAdhan();
    }
  }
  
  Future<void> playAdhan() async {
    _isPlayingAdhan = true;
    notifyListeners();
    
    try {
        debugPrint("Playing Adhan (Asset)...");
        // Using local asset exclusively
        await _audioPlayer.play(AssetSource('audio/adhan.mp3'));
        
        Future.delayed(const Duration(minutes: 4), () {
            if (_timer != null) {
              _isPlayingAdhan = false;
              notifyListeners();
            }
        });
    } catch (e) {
        debugPrint("Error playing adhan: $e");
        _isPlayingAdhan = false;
        notifyListeners();
    }
  }

  Future<void> stopAdhan() async {
    await _audioPlayer.stop();
    _isPlayingAdhan = false;
    notifyListeners();
  }

  Prayer get nextPrayer => _nextPrayer;
  
  Prayer get currentPrayer {
    return _prayerTimes?.currentPrayer() ?? Prayer.none;
  }
  
  String getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'الـفجر';
      case Prayer.sunrise: return 'الـشروق';
      case Prayer.dhuhr: return 'الـظهر';
      case Prayer.asr: return 'الـعصر';
      case Prayer.maghrib: return 'الـمغرب';
      case Prayer.isha: return 'الـعشاء';
      case Prayer.none: return 'العشاء (التالي الفجر)'; // Simplified
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
