import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';

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
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('تنبيهات الصلاة'),
            subtitle: const Text('تفعيل الأذان عند وقت الصلاة'),
            value: _prayerNotifications,
            onChanged: (val) {
              setState(() => _prayerNotifications = val);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('تذكير الأذكار'),
            subtitle: const Text('تذكير بأذكار الصباح والمساء'),
            value: _morningEveningReminders,
            onChanged: (val) {
              setState(() => _morningEveningReminders = val);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('الموقع'),
            subtitle: Text(provider.locationStatus),
            leading: const Icon(Icons.location_on),
            onTap: () {
               provider.refreshLocation();
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري تحديث الموقع...')),
              );
            },
          ),
          const Divider(),
          const Divider(),
          ListTile(
            title: const Text('عن التطبيق'),
            subtitle: const Text('إصدار 1.0.0'),
            leading: const Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}
