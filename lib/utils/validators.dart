class Validators {
  static const Set<String> _blockedSchemes = {
    'file',
    'content',
    'javascript',
    'data',
    'blob',
  };

  static bool isSafeStreamUrl(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return false;
    final uri = Uri.tryParse(text);
    if (uri == null) return false;
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'https') return false;
    if (_blockedSchemes.contains(scheme)) return false;
    if (uri.host.isEmpty) return false;
    if (uri.userInfo.isNotEmpty) return false;
    return true;
  }
}
