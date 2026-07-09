import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class MockMediaPlayer extends StatefulWidget {
  const MockMediaPlayer({
    super.key,
    required this.title,
    this.duration = const Duration(seconds: 30),
    this.mediaUrl,
    this.isVideo = false,
    this.showPreviewBox = false,
    this.aspectRatio = 16 / 9,
    this.onDownload,
  });

  final String title;
  final Duration duration;
  final String? mediaUrl;
  final bool isVideo;
  final bool showPreviewBox;
  final double aspectRatio;
  final VoidCallback? onDownload;

  @override
  State<MockMediaPlayer> createState() => _MockMediaPlayerState();
}

class _MockMediaPlayerState extends State<MockMediaPlayer> {
  Timer? _timer;
  bool _playing = false;
  Duration _position = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() => _playing = !_playing);
    _timer?.cancel();
    if (_playing) {
      _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          final next = _position + const Duration(milliseconds: 250);
          if (next >= widget.duration) {
            _position = widget.duration;
            _playing = false;
            _timer?.cancel();
          } else {
            _position = next;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / widget.duration.inMilliseconds;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  tooltip: 'download',
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.download_rounded, size: 22),
                  onPressed: widget.onDownload,
                ),
              ),
            ],
          ),
          if (widget.showPreviewBox) ...[
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.mediaUrl == null ? 'Video Preview' : 'Mock Video',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(_playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
                    color: AppColors.primaryPurple,
                    onPressed: _toggle,
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(formatDuration(_position), style: const TextStyle(fontSize: 12)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: ratio.clamp(0, 1),
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    formatDuration(widget.duration),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MockAudioPlayer extends StatelessWidget {
  const MockAudioPlayer({
    super.key,
    required this.title,
    this.mediaUrl,
    this.onDownload,
  });

  final String title;
  final String? mediaUrl;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return MockMediaPlayer(
      title: title,
      mediaUrl: mediaUrl,
      onDownload: onDownload,
    );
  }
}

class MockVideoPlayer extends StatelessWidget {
  const MockVideoPlayer({
    super.key,
    required this.title,
    this.mediaUrl,
    this.aspectRatio = 16 / 9,
    this.onDownload,
  });

  final String title;
  final String? mediaUrl;
  final double aspectRatio;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return MockMediaPlayer(
      title: title,
      mediaUrl: mediaUrl,
      isVideo: true,
      showPreviewBox: true,
      aspectRatio: aspectRatio,
      onDownload: onDownload,
    );
  }
}
