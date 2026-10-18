import 'package:http/http.dart' as http;

class StreamVariant {
  final String label;
  final String url;
  final int? height;
  final int? bandwidth;
  const StreamVariant({required this.label, required this.url, this.height, this.bandwidth});
}

class HlsQualityParser {
  static Future<List<StreamVariant>> parse(String masterUrl) async {
    final uri = Uri.tryParse(masterUrl);
    if (uri == null || uri.scheme != 'https') return <StreamVariant>[];
    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) return <StreamVariant>[];
    final lines = response.body.split('\n');
    final variants = <StreamVariant>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (!line.startsWith('#EXT-X-STREAM-INF')) continue;
      final attrs = _parseAttributes(line);
      String? childUri;
      for (var j = i + 1; j < lines.length; j++) {
        final next = lines[j].trim();
        if (next.isEmpty || next.startsWith('#')) continue;
        childUri = next;
        break;
      }
      if (childUri == null) continue;
      final absolute = uri.resolve(childUri).toString();
      final resolution = attrs['RESOLUTION'];
      final height = int.tryParse(resolution == null ? '' : resolution.split('x').last);
      final bandwidth = int.tryParse(attrs['BANDWIDTH'] ?? '');
      variants.add(StreamVariant(label: _labelFor(height), url: absolute, height: height, bandwidth: bandwidth));
    }
    variants.sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));
    return variants;
  }

  static Map<String, String> _parseAttributes(String line) {
    final map = <String, String>{};
    final index = line.indexOf(':');
    if (index == -1) return map;
    final body = line.substring(index + 1);
    final pattern = RegExp(r'([A-Z0-9-]+)=("[^"]*"|[^,]*)');
    for (final match in pattern.allMatches(body)) {
      map[match.group(1)!] = match.group(2)!.replaceAll('"', '').trim();
    }
    return map;
  }

  static String _labelFor(int? height) {
    if (height == null) return 'تلقائي';
    if (height >= 2000) return '4K';
    if (height >= 1000) return 'FHD 1080p';
    if (height >= 700) return 'HD 720p';
    if (height >= 400) return 'SD 480p';
    return 'SD ${height}p';
  }
}
