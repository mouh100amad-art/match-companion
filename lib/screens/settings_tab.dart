import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/matches_provider.dart';
import '../providers/settings_provider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});
  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late final TextEditingController _apiController;
  @override
  void initState() {
    super.initState();
    _apiController = TextEditingController(text: context.read<SettingsProvider>().apiKey);
  }
  @override
  void dispose() {
    _apiController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('المظهر', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('النظام')),
            ButtonSegment(value: ThemeMode.light, label: Text('فاتح')),
            ButtonSegment(value: ThemeMode.dark, label: Text('داكن'))
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (value) => settings.setThemeMode(value.first),
        ),
        const SizedBox(height: 24),
        const Text('التذكير الافتراضي', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: settings.defaultReminder,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [5, 10, 15, 30, 60].map((m) => DropdownMenuItem(value: m, child: Text('قبل $m دقيقة'))).toList(),
          onChanged: (value) {
            if (value != null) settings.setDefaultReminder(value);
          },
        ),
        const SizedBox(height: 24),
        const Text('مفتاح TheSportsDB (اختياري)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _apiController,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '3'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () async {
            await settings.setApiKey(_apiController.text);
            if (!context.mounted) return;
            await context.read<MatchesProvider>().refresh();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ وتحديث المباريات')));
          },
          child: const Text('حفظ وتحديث'),
        ),
        const SizedBox(height: 24),
        const Text('الحماية والخصوصية', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const ListTile(leading: Icon(Icons.lock_outline), title: Text('اتصال HTTPS فقط'), subtitle: Text('تم تعطيل الاتصالات غير المشفرة على مستوى النظام')),
        const ListTile(leading: Icon(Icons.block), title: Text('منع الملفات الضارة'), subtitle: Text('لا يتم تحميل أو تنفيذ أي كود من روابط خارجية')),
        const ListTile(leading: Icon(Icons.backup_outlined), title: Text('بدون نسخ احتياطي'), subtitle: Text('تم تعطيل النسخ الاحتياطي التلقائي لبيانات التطبيق')),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () async {
            await context.read<MatchesProvider>().clearFavorites();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح المفضلة')));
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('مسح المفضلة'),
        ),
        const SizedBox(height: 32),
        Center(child: Text('رفيق المباريات • الإصدار 1.0.0', style: Theme.of(context).textTheme.bodySmall)),
        const SizedBox(height: 8),
        const Text(
          'إخلاء مسؤولية: هذا التطبيق لا يستضيف أو يبث أي محتوى مدفوع. يقتصر دوره على عرض جدول المباريات وتذكيراتها وفتح المنصات الرسمية. أنت مسؤول بالكامل عن أي رابط تستخدمه في المشغل المخصص.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
