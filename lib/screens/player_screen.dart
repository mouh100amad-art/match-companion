import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../services/hls_quality_parser.dart';

class PlayerScreen extends StatefulWidget {
  final String url;
  final String title;
  const PlayerScreen({super.key, required this.url, required this.title});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  List<StreamVariant> _variants = <StreamVariant>[];
  StreamVariant? _selected;
  bool _loading = true;
  bool _showControls = true;
  String? _error;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final variants = await HlsQualityParser.parse(widget.url);
      if (!mounted) return;
      _variants = variants;
      final initialUrl = variants.isNotEmpty ? variants.first.url : widget.url;
      if (variants.isNotEmpty) _selected = variants.first;
      await _initController(initialUrl);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تشغيل الرابط. تأكد من أنه رابط HLS صالح وأنك تملك حق استخدامه.';
      });
    }
  }

  Future<void> _initController(String url) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.addListener(_onPlayerChanged);
    await controller.play();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _loading = false;
      _error = null;
    });
  }

  void _onPlayerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _switchTo(StreamVariant variant) async {
    final old = _controller;
    final position = old?.value.isInitialized == true ? old!.value.position : Duration.zero;
    await old?.pause();
    old?.removeListener(_onPlayerChanged);
    await old?.dispose();
    if (!mounted) return;
    setState(() {
      _loading = true;
      _selected = variant;
    });
    final controller = VideoPlayerController.networkUrl(Uri.parse(variant.url));
    await controller.initialize();
    await controller.seekTo(position);
    controller.addListener(_onPlayerChanged);
    await controller.play();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _loading = false;
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    _hideTimer?.cancel();
    if (_showControls) {
      _hideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showControls = false);
      });
    }
  }

  Future<void> _toggleFullscreen() async {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _showQualitySheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('الجودة', style: TextStyle(fontWeight: FontWeight.bold)), dense: true),
            ..._variants.map((v) => ListTile(title: Text(v.label), trailing: _selected == v ? const Icon(Icons.check) : null, onTap: () {
              Navigator.pop(ctx);
              _switchTo(v);
            })),
            if (_variants.isEmpty) const ListTile(title: Text('لا توجد جودات متعددة لهذا الرابط'))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onPlayerChanged);
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : _error != null
                      ? Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center))
                      : AspectRatio(aspectRatio: controller!.value.aspectRatio, child: VideoPlayer(controller)),
            ),
            if (!_loading && _error == null)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleControls,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: _buildControls(controller!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(VideoPlayerController controller) {
    final duration = controller.value.duration;
    final position = controller.value.position;
    final maxMs = duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
    final valueMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();
    return Column(
      children: [
        Container(
          color: Colors.black54,
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
              Expanded(child: Text(widget.title, style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
              TextButton.icon(onPressed: _showQualitySheet, icon: const Icon(Icons.high_quality, color: Colors.white), label: Text(_selected?.label ?? 'تلقائي', style: const TextStyle(color: Colors.white)))
            ],
          ),
        ),
        const Spacer(),
        Container(
          color: Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                onPressed: () {
                  controller.value.isPlaying ? controller.pause() : controller.play();
                },
              ),
              Expanded(
                child: Slider(value: valueMs, max: maxMs, onChanged: (v) => controller.seekTo(Duration(milliseconds: v.round()))),
              ),
              IconButton(icon: const Icon(Icons.fullscreen, color: Colors.white), onPressed: _toggleFullscreen)
            ],
          ),
        ),
      ],
    );
  }
}
