import 'package:url_launcher/url_launcher.dart';

class StreamLauncher {
  static Future<bool> _launch(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri == null) return false;
    try {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> openTod() async {
    if (await _launch('tod://')) return true;
    if (await _launch('https://www.tod.tv/')) return true;
    return _launch('https://play.google.com/store/apps/details?id=com.bein.tod');
  }

  static Future<bool> openBeinConnect() => _launch('https://www.bein.com/connect');
  static Future<bool> openFifaPlus() => _launch('https://plus.fifa.com/');
  static Future<bool> openBeinNews() => _launch('https://www.bein.com/en/');
}
