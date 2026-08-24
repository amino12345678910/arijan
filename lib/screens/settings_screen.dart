import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/prayer_provider.dart';
import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _prayerNotifications = true;
  bool _morningEveningReminders = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات', style: GoogleFonts.amiri(color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.emeraldPrimary,
        iconTheme: const IconThemeData(color: AppTheme.goldAccent),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('تنبيهات الصلاة', style: TextStyle(color: Colors.white)),
              subtitle: const Text('تفعيل الأذان عند وقت الصلاة', style: TextStyle(color: Colors.white60)),
              value: _prayerNotifications,
              activeColor: AppTheme.goldAccent,
              onChanged: (val) => setState(() => _prayerNotifications = val),
            ),
            const Divider(color: Colors.white12),
            SwitchListTile(
              title: const Text('تذكير الأذكار', style: TextStyle(color: Colors.white)),
              subtitle: const Text('تذكير بأذكار الصباح والمساء', style: TextStyle(color: Colors.white60)),
              value: _morningEveningReminders,
              activeColor: AppTheme.goldAccent,
              onChanged: (val) => setState(() => _morningEveningReminders = val),
            ),
            const Divider(color: Colors.white12),
            ListTile(
              title: const Text('الموقع', style: TextStyle(color: Colors.white)),
              subtitle: Text(provider.locationStatus, style: const TextStyle(color: Colors.white60)),
              leading: const Icon(Icons.location_on, color: AppTheme.goldAccent),
              trailing: const Icon(Icons.refresh, color: Colors.white54),
              onTap: () {
                provider.refreshLocation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('جاري تحديث الموقع...')),
                );
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              title: const Text('اقتراحاتكم', style: TextStyle(color: Colors.white)),
              subtitle: const Text('ساعدنا نطور التطبيق', style: TextStyle(color: Colors.white60)),
              leading: const Icon(Icons.feedback_outlined, color: AppTheme.goldAccent),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                );
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              title: const Text('عن التطبيق', style: TextStyle(color: Colors.white)),
              subtitle: const Text('إصدار 1.0.0 — أريجان', style: TextStyle(color: Colors.white60)),
              leading: const Icon(Icons.info_outline, color: AppTheme.goldAccent),
            ),
          ],
        ),
      ),
    );
  }
}
