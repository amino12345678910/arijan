import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/models.dart';
import 'adhkar_detail_screen.dart';
import '../core/app_theme.dart';
import 'dart:ui';

class AdhkarListScreen extends StatelessWidget {
  final AdhkarCategory category;

  const AdhkarListScreen({super.key, required this.category});

  Color _getCategoryColor() {
    switch (category.id) {
      case 'morning':
        return const Color(0xFFFFB74D); // Morning Orange
      case 'evening':
        return const Color(0xFF7986CB); // Evening Blueish
      case 'sleep':
        return const Color(0xFF4527A0); // Deep Purple
      case 'prayer':
        return const Color(0xFF4CAF50); // Prayer Green
      default:
        return AppTheme.emeraldPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = _getCategoryColor();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(category.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: theme.colorScheme.surface.withOpacity(0.5)),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor.withOpacity(0.15),
              theme.colorScheme.background,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 120, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = category.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildAdhkarCard(context, item, index, accentColor),
                    );
                  },
                  childCount: category.items.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdhkarCard(BuildContext context, AdhkarItem item, int index, Color accentColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdhkarDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.repeat, size: 14, color: accentColor),
                            const SizedBox(width: 4),
                            Text(
                              "${item.count} مرات",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded, 
                           size: 16, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Amiri', // Ensure Arabic font
                      fontSize: 18,
                      height: 1.6,
                    ),
                  ),
                  if (item.reference != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      item.reference!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      )
      .animate()
      .fadeIn(duration: 400.ms, delay: (50 * index).ms)
      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
    );
  }
}
