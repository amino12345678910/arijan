class AdhkarCategory {
  final String id;
  final String title;
  final String iconPath; // or IconData
  final List<AdhkarItem> items;

  AdhkarCategory({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.items,
  });
}

class AdhkarItem {
  final String id;
  final String text;
  final int count;
  final String? reference; // Fadl/Reward
  final String? transliteration;

  AdhkarItem({
    required this.id,
    required this.text,
    required this.count,
    this.reference,
    this.transliteration,
  });
}
