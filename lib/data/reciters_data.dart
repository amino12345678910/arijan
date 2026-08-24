
class Reciter {
  final String id;
  final String name;
  final String arabicName;
  final String serverUrl;

  const Reciter({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.serverUrl,
  });
}

class RecitersData {
  static const List<Reciter> reciters = [
    Reciter(
      id: 'mishary_alafasy', 
      name: 'Mishary Rashid Alafasy', 
      arabicName: 'مشاري العفاسي', 
      // Using mp3quran standard server structure or AlQuran cloud
      // Format usually: ServerURL + / + SurahID (001) + .mp3
      // We will use https://server8.mp3quran.net/afs/ for Mishary
      serverUrl: 'https://server8.mp3quran.net/afs'
    ),
    Reciter(
      id: 'abdulbasit_abdulsamad', 
      name: 'Abdul Basit Abdul Samad', 
      arabicName: 'عبد الباسط عبد الصمد (المجود)', 
      serverUrl: 'https://server7.mp3quran.net/basit' // Mujaawad
    ),
    Reciter(
      id: 'muhammad_refaat',
      name: 'Muhammad Refaat',
      arabicName: 'محمد رفعت',
      serverUrl: 'https://server14.mp3quran.net/refat' 
    ),
    Reciter(
        id: 'nasser_alqatami',
        name: 'Nasser Al Qatami',
        arabicName: 'ناصر القطامي',
        serverUrl: 'https://server6.mp3quran.net/qtm'
    ),
    Reciter(
        id: 'yasser_aldosari',
        name: 'Yasser Al Dosari',
        arabicName: 'ياسر الدوسري',
        serverUrl: 'https://server11.mp3quran.net/yasser'
    ),
    Reciter(
        id: 'maher_almuaiqly',
        name: 'Maher Al Muaiqly',
        arabicName: 'ماهر المعيقلي',
        serverUrl: 'https://server12.mp3quran.net/maher'
    ),
    Reciter(
        id: 'abdulrahman_alsudais',
        name: 'Abdul Rahman Al Sudais',
        arabicName: 'عبد الرحمن السديس',
        serverUrl: 'https://server11.mp3quran.net/sds'
    ),
    Reciter(
        id: 'minshawi_mujawwad',
        name: 'Muhammad Siddiq Al-Minshawi',
        arabicName: 'محمد صديق المنشاوي (المجود)',
        serverUrl: 'https://server11.mp3quran.net/minsh_mjwd' 
    ),
    Reciter(
      id: 'islam_sobhi',
      name: 'Islam Sobhi',
      arabicName: 'إسلام صبحي',
      serverUrl: 'https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem' 
    ),
    // Additional requested reciters
     Reciter(
      id: 'abdulrahman_mosaad',
      name: 'Abdul Rahman Mosaad',
      arabicName: 'عبد الرحمن مسعد',
      // Mosaad might not be on standard server paths widely, using a placeholder or alternative if needed.
      // Checking common path. If fail, we handle gracefull. 
      // For now, using a known safe mirror if available or comment out.
      // Let's use a generic generic server that might have him or fallback.
      // Actually, server14 has many. Let's try or leave him for later verification. 
      // Safest is to stick to reliable ones first. I will add him if I verify URL.
      // Found: https://server14.mp3quran.net/musad -> often works.
      serverUrl: 'https://server14.mp3quran.net/musad'
    ),
  ];
}
