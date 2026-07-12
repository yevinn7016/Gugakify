import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/app_state/project_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/gray_card.dart';
import '../../../../shared/widgets/gugak_header.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/progress_step_list.dart';

class AudioProcessingScreen extends StatefulWidget {
  const AudioProcessingScreen({super.key});

  @override
  State<AudioProcessingScreen> createState() => _AudioProcessingScreenState();
}

class _AudioProcessingScreenState extends State<AudioProcessingScreen> {
  Timer? _timer;
  final _steps = const [
    '음원 전처리',
    'BPM·분위기 분석',
    '보컬/반주 분리',
    '국악 프롬프트 생성',
    'MusicGen 생성',
    '완료',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final provider = context.read<ProjectProvider>();
      final next = provider.progress + 0.05;
      if (next >= 1) {
        _timer?.cancel();
        provider.updateStatus('audio_completed', newProgress: 1);
        if (mounted) context.go('/audio/result');
      } else {
        provider.updateProgress(next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProjectProvider>().progress;
    final index = (progress * _steps.length).floor().clamp(
      0,
      _steps.length - 1,
    );
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(
            title: '새 프로젝트 만들기',
            onBack: () => context.go('/audio/settings'),
          ),
          const SizedBox(height: 28),
          const Text(
            '국악 스타일 음원 변환 중',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 26),
          const Text(
            'AI가 음원을 분석하고 국악 스타일로 재구성해요',
            style: TextStyle(color: AppColors.textGray, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).round()} %',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 15,
              backgroundColor: AppColors.lightPurple.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 46),
          Text(
            '현재 단계 : ${_steps[index]} 중',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 34),
          GrayCard(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
            child: ProgressStepList(steps: _steps, progress: progress),
          ),
        ],
      ),
    );
  }
}
