import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class RealAudioPlayer extends StatefulWidget {
  const RealAudioPlayer({
    super.key,
    required this.title,
    required this.audioUrl,
    this.onDownload,
  });

  final String title;
  final String? audioUrl;
  final VoidCallback? onDownload;

  @override
  State<RealAudioPlayer> createState() => _RealAudioPlayerState();
}

class _RealAudioPlayerState extends State<RealAudioPlayer> {
  late final AudioPlayer _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      setState(() {
        _loading = false;
        _error = '재생할 음원이 없습니다.';
      });
      return;
    }
    try {
      final duration = await _player.setUrl(widget.audioUrl!);
      _positionSub = _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _stateSub = _player.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() {
          _playing = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _playing = false;
            _position = Duration.zero;
            _player.seek(Duration.zero);
          }
        });
      });
      setState(() {
        _duration = duration ?? Duration.zero;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '음원을 불러오지 못했습니다: $e';
      });
    }
  }

  void _toggle() {
    if (_playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;

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
          Row(
            children: [
              Expanded(
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
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            )
          else
            Row(
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
                Expanded(
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
                    formatDuration(_duration),
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
        ],
      ),
    );
  }
}