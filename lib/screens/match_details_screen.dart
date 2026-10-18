import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/stream_launcher.dart';
import '../utils/validators.dart';
import 'player_screen.dart';

class MatchDetailsScreen extends StatefulWidget {
  final MatchEvent match;
  const MatchDetailsScreen({super.key, required this.match});
  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  late int _reminder;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    _reminder = context.read<SettingsProvider>().defaultReminder;
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }
  void _tick() {
    final remaining = widget.match.localTime.difference(DateTime.now());
    if (mounted) {
      setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _schedule() async {
    final granted = await NotificationService.instance.requestPermissions();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى السماح بالإشعارات والمنبهات الدقيقة')));
      return;
    }
    await NotificationService.instance.scheduleMatchReminder(match: widget.match, minutesBefore: _reminder);
    if (!mounted) return;
    setState(() => _scheduled = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم جدولة التذكير قبل $_reminder دقيقة')));
  }

  Future<void> _openCustomPlayer() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رابط HLS أملكه'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أدخل رابط HTTPS ينتهي بـ .m3u8. أنت مسؤول عن قانونية المصدر.', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              t
              decoration: const InputDecoration(hintText: 'https://.../master.m3u8', border: OutlineInputBorder()),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('تشغيل'))
        ],
      ),
    );
    if (url == null || url.isEmpty) return;
    if (!Validators.isSafeStreamUrl(url)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رابط غير آمن. يجب أن يكون HTTPS.')));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(url: url, title: '${widget.match.homeTeam} × ${widget.match.awayTeam}')));
  }

  String get _countdown {
    final h = _remaining.inHours;
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المباراة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(match.league, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Text(match.homeTeam, textAlign: TextAlign.center, style: theme.textTheme.titleLarge)),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('×', style: theme.textTheme.headlineSmall)),
                      Expanded(child: Text(match.awayTeam, textAlign: TextAlign.center, style: theme.textTheme.titleLarge))
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(DateFormat('EEEE، d MMMM yyyy • HH:mm', 'ar').format(match.localTime), style: theme.textTheme.bodyMedium),
                  if (match.venue != null) ...[
                    const SizedBox(height: 4),
                    Text(match.venue!, style: theme.textTheme.bodySmall)
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                    child: Text(match.localTime.isAfter(DateTime.now()) ? 'تبدأ بعد $_countdown' : 'انطلقت المباراة', style: theme.textTheme.titleMedium),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('التذكير', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _reminder,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'قبل الانطلاق'),
                    items: const [5, 10, 15, 30, 60].map((m) => DropdownMenuItem(value: m, child: Text('$m دقيقة'))).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _reminder = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _scheduled ? null : _schedule,
                    icon: Icon(_scheduled ? Icons.check : Icons.alarm),
                    label: Text(_scheduled ? 'تم جدولة التذكير' : 'تفعيل التذكير'),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.live_tv), title: const Text('TOD (رسمي)'), subtitle: const Text('بث beIN Sports الرسمي حتى 4K'), trailing: const Icon(Icons.open_in_new), onTap: StreamLauncher.openTod),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.language), title: const Text('beIN CONNECT (رسمي)'), subtitle: const Text('المشاهدة عبر المتصفح حتى 1080p'), trailing: const Icon(Icons.open_in_new), onTap: StreamLauncher.openBeinConnect),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.public), title: const Text('FIFA+ (مجاني قانوني)'), subtitle: const Text('ملخصات وإعادات مجانية'), trailing: const Icon(Icons.open_in_new), onTap: StreamLauncher.openFifaPlus),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.newspaper), title: const Text('beIN Sports News'), subtitle: const Text('قناة مفتوحة رسمياً'), trailing: const Icon(Icons.open_in_new), onTap: StreamLauncher.openBeinNews),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.play_circle_outline), title: const Text('مشغل مخصص (رابط أملكه)'), subtitle: const Text('يدعم SD / HD / FHD وتبديل الجودة'), trailing: const Icon(Icons.chevron_left), onTap: _openCustomPlayer)
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'هذا التطبيق لا يوفر بثاً مجانياً لقنوات beIN Sports. الخيارات أعلاه هي منصات رسمية أو مجانية قانونية. المشغل المخصص يعمل فقط على روابط تملك حق استخدامها.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
