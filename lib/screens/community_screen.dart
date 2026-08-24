import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _postController = TextEditingController();
  String _selectedCategory = 'خاطرة';
  bool _isPosting = false;

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'خاطرة', 'icon': Icons.lightbulb_outline},
    {'label': 'دعاء', 'icon': Icons.volunteer_activism},
    {'label': 'تجربة', 'icon': Icons.auto_stories},
    {'label': 'تذكير', 'icon': Icons.notifications_active_outlined},
  ];

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);

    await FirebaseFirestore.instance.collection('posts').add({
      'text': text,
      'category': _selectedCategory,
      'hearts': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _postController.clear();
    setState(() => _isPosting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم النشر بنجاح ✓'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showNewPostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A261D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'شارك مع الآخرين',
              style: GoogleFonts.amiri(
                fontSize: 22, color: AppTheme.goldAccent, fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Category chips
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isSelected = cat['label'] == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat['label']),
                  avatar: Icon(cat['icon'], size: 18, color: isSelected ? Colors.black : Colors.white60),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat['label']),
                  selectedColor: AppTheme.goldAccent,
                  backgroundColor: Colors.white10,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Text field
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _postController,
                maxLines: 4,
                maxLength: 500,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'اكتب هنا...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: const TextStyle(color: Colors.white30),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isPosting ? null : () {
                _submitPost();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'نشر',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'مجتمع أريجان',
          style: GoogleFonts.amiri(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.goldAccent),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.goldAccent),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.forum_outlined, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'كن أول من يشارك!',
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 18),
                      ),
                    ],
                  ),
                );
              }

              final posts = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final data = post.data() as Map<String, dynamic>;
                  return _PostCard(
                    postId: post.id,
                    text: data['text'] ?? '',
                    category: data['category'] ?? '',
                    hearts: data['hearts'] ?? 0,
                    timestamp: data['timestamp'] as Timestamp?,
                  ).animate().fadeIn(delay: (50 * (index % 10)).ms).slideY(begin: 0.05);
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewPostSheet,
        backgroundColor: AppTheme.goldAccent,
        child: const Icon(Icons.edit, color: Colors.black),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String postId;
  final String text;
  final String category;
  final int hearts;
  final Timestamp? timestamp;

  const _PostCard({
    required this.postId,
    required this.text,
    required this.category,
    required this.hearts,
    this.timestamp,
  });

  String _timeAgo() {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final diff = now.difference(timestamp!.toDate());
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${timestamp!.toDate().day}/${timestamp!.toDate().month}';
  }

  void _toggleHeart() {
    FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'hearts': hearts + 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: category + time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.cairo(
                    color: AppTheme.goldAccent, fontSize: 12, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _timeAgo(),
                style: const TextStyle(color: Colors.white30, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Body text
          Text(
            text,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          // Heart button
          GestureDetector(
            onTap: _toggleHeart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hearts > 0 ? Icons.favorite : Icons.favorite_border,
                  color: hearts > 0 ? Colors.redAccent : Colors.white30,
                  size: 20,
                ),
                if (hearts > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$hearts',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
