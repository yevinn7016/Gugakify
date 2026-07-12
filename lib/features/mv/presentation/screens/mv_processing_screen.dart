import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/app_state/project_state.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
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
        final auth = context.read<AuthProvider>();
        provider.completeProject(saveToArchive: !auth.isGuest);
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
            onBack: () => context.go('/mv/settings'),
          ),
          const SizedBox(height: 28),
          const Text(
            '전통 MV 생성 중',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 26),
          const Text(
            '장단과 에너지 변화에 맞춰 장면을 구성해요',
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
