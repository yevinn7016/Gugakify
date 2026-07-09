import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

Future<bool> _assetExists(String asset) async {
  try {
    await rootBundle.load(asset);
    return true;
  } catch (_) {
    return false;
  }
}

class DemoAudioPlayer extends StatefulWidget {
  const DemoAudioPlayer({super.key, this.assetPath = 'assets/demo/demo_audio.mp3'});

  final String assetPath;

  @override
  State<DemoAudioPlayer> createState() => _DemoAudioPlayerState();
}

class _DemoAudioPlayerState extends State<DemoAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _available = false;
  bool _ready = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _available = await _assetExists(widget.assetPath);
    if (!_available) {
      if (mounted) setState(() {});
      return;
    }
    try {
      final duration = await _player.setAsset(widget.assetPath);
      _duration = duration ?? Duration.zero;
      _positionSub = _player.positionStream.listen((value) {
        if (mounted) setState(() => _position = value);
      });
      _durationSub = _player.durationStream.listen((value) {
        if (mounted && value != null) setState(() => _duration = value);
      });
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _available = false);
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_available) {
      return const _DemoPlaceholder(label: '데모 오디오 파일을 추가해주세요.');
    }
    final playing = _player.playing;
    final value = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;
    return _DemoBox(
      title: 'Demo Audio Player',
      child: Row(
        children: [
          IconButton(
            icon: Icon(playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
            color: AppColors.primaryPurple,
            onPressed: !_ready
                ? null
                : () async {
                    if (playing) {
                      await _player.pause();
                    } else {
                      await _player.play();
                    }
                    if (mounted) setState(() {});
                  },
          ),
          SizedBox(width: 44, child: Text(formatDuration(_position), style: const TextStyle(fontSize: 12))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 8),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(formatDuration(_duration), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class DemoVideoPlayer extends StatefulWidget {
  const DemoVideoPlayer({super.key, this.assetPath = 'assets/demo/demo_video.mp4'});

  final String assetPath;

  @override
  State<DemoVideoPlayer> createState() => _DemoVideoPlayerState();
}

class _DemoVideoPlayerState extends State<DemoVideoPlayer> {
  VideoPlayerController? _controller;
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _available = await _assetExists(widget.assetPath);
    if (!_available) {
      if (mounted) setState(() {});
      return;
    }
    try {
      final controller = VideoPlayerController.asset(widget.assetPath);
      await controller.initialize();
      controller.addListener(() {
        if (mounted) setState(() {});
      });
      if (mounted) setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => _available = false);
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (!_available) {
      return const _DemoPlaceholder(label: '데모 비디오 파일을 추가해주세요.');
    }
    return _DemoBox(
      title: 'Demo Video Player',
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: controller?.value.aspectRatio == 0 ? 16 / 9 : controller?.value.aspectRatio ?? 16 / 9,
            child: Container(
              alignment: Alignment.center,
              color: Colors.black12,
              child: controller == null || !controller.value.isInitialized
                  ? const CircularProgressIndicator()
                  : VideoPlayer(controller),
            ),
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: Icon(controller?.value.isPlaying == true ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
            color: AppColors.primaryPurple,
            onPressed: controller == null
                ? null
                : () {
                    controller.value.isPlaying ? controller.pause() : controller.play();
                  },
          ),
        ],
      ),
    );
  }
}

class _DemoBox extends StatelessWidget {
  const _DemoBox({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DemoPlaceholder extends StatelessWidget {
  const _DemoPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return _DemoBox(
      title: label.contains('비디오') ? 'Demo Video Player' : 'Demo Audio Player',
      child: SizedBox(
        height: 72,
        child: Center(
          child: Text(label, style: const TextStyle(color: AppColors.textGray)),
        ),
      ),
    );
  }
}
