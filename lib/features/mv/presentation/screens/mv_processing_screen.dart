import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/gray_card.dart';
import '../../../../shared/widgets/gugak_header.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/progress_step_list.dart';

class MvProcessingScreen extends StatefulWidget {
  const MvProcessingScreen({super.key});

  @override
  State<MvProcessingScreen> createState() => _MvProcessingScreenState();
}

class _MvProcessingScreenState extends State<MvProcessingScreen> {
  Timer? _timer;
  final _steps = const [
    'BPM·비트·에너지 분석',
    '곡 구간 분할',
    '장단 및 분위기 매핑',
    'Scene Script 생성',
    '전통 이미지 생성',
    '장단 기반 효과 타임라인 생성',
    '영상 합성',
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
        provider.completeProject();
        if (mounted) context.go('/result');
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
    final index = (progress * _steps.length).floor().clamp(0, _steps.length - 1);
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(title: 'MV 생성', onBack: () => context.go('/mv/settings')),
          const SizedBox(height: 22),
          const Text('전통 MV 생성 중', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 22),
          GrayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${(progress * 100).round()}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress, minHeight: 10),
                const SizedBox(height: 12),
                Text('현재 단계: ${_steps[index]}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          ProgressStepList(steps: _steps, progress: progress),
        ],
      ),
    );
  }
}
