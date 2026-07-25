import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class MockMediaPlayer extends StatefulWidget {
  const MockMediaPlayer({
    super.key,
    required this.title,
    this.duration = const Duration(seconds: 192),
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
      decoration: BoxDecoration(
        color: AppColors.cardLight.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final titleWidth = (constraints.maxWidth - 48).clamp(
                0.0,
                constraints.maxWidth,
              );
              return Row(
                children: [
                  SizedBox(
                    width: titleWidth,
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      tooltip: 'download',
                      padding: EdgeInsets.zero,
                      color: AppColors.primaryPurple,
                      icon: const Icon(Icons.download_rounded, size: 21),
                      onPressed: widget.onDownload,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 24,
            child: CustomPaint(
              painter: _WaveformPainter(ratio: ratio.clamp(0, 1)),
              child: const SizedBox.expand(),
            ),
          ),
          if (widget.showPreviewBox) ...[
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.paleLavender.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Text(
                    widget.mediaUrl == null ? 'Video Preview' : 'Mock Video',
                    style: const TextStyle(
                      color: AppColors.deepInkPurple,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final progressWidth = (constraints.maxWidth - 140).clamp(
                0.0,
                constraints.maxWidth,
              );
              return SizedBox(
                height: 42,
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          _playing
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                        ),
                        color: AppColors.primaryPurple,
                        iconSize: 34,
                        onPressed: _toggle,
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        formatDuration(_position),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: progressWidth,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 9,
                          value: ratio.clamp(0, 1),
                          backgroundColor: AppColors.paleLavender,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        formatDuration(widget.duration),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.ratio});

  final double ratio;

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = AppColors.primaryPurple.withValues(alpha: 0.62)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final inactivePaint = Paint()
      ..color = AppColors.lightPurple.withValues(alpha: 0.72)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const barCount = 34;
    final gap = size.width / barCount;
    for (var i = 0; i < barCount; i++) {
      final normalized = (i % 7 + 2) / 9;
      final height = 7 + normalized * 13;
      final x = gap * i + gap / 2;
      final y1 = size.height / 2 - height / 2;
      final y2 = size.height / 2 + height / 2;
      canvas.drawLine(
        Offset(x, y1),
        Offset(x, y2),
        i / barCount <= ratio ? activePaint : inactivePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.ratio != ratio;
  }
}

class MockAudioPlayer extends StatelessWidget {
  const MockAudioPlayer({
    super.key,
    required this.title,
    this.duration = const Duration(seconds: 192),
    this.mediaUrl,
    this.onDownload,
  });

  final String title;
  final Duration duration;
  final String? mediaUrl;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return MockMediaPlayer(
      title: title,
      duration: duration,
      mediaUrl: mediaUrl,
      onDownload: onDownload,
    );
  }
}

class MockVideoPlayer extends StatelessWidget {
  const MockVideoPlayer({
    super.key,
    required this.title,
    this.duration = const Duration(seconds: 192),
    this.mediaUrl,
    this.aspectRatio = 16 / 9,
    this.onDownload,
  });

  final String title;
  final Duration duration;
  final String? mediaUrl;
  final double aspectRatio;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return MockMediaPlayer(
      title: title,
      duration: duration,
      mediaUrl: mediaUrl,
      isVideo: true,
      showPreviewBox: true,
      aspectRatio: aspectRatio,
      onDownload: onDownload,
    );
  }
}
