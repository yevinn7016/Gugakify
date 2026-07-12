import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/flow_action_button.dart';
import '../../../../shared/widgets/gray_card.dart';
import '../../../../shared/widgets/gugak_header.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/mock_player.dart';

class AudioResultScreen extends StatelessWidget {
  const AudioResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final auth = context.watch<AuthProvider>();
    final duration = Duration(
      seconds: project.outputAudioDurationSeconds ?? 192,
    );
    final instruments = project.preferredInstruments.isEmpty
        ? ['자동 추천']
        : project.preferredInstruments.map(_instrumentLabel).toList();
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
            '국악 음원 변환 완료',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 26),
          const Text(
            '원곡이 국악 스타일로 재탄생했어요',
            style: TextStyle(color: AppColors.textGray, fontSize: 13),
          ),
          const SizedBox(height: 20),
          MockAudioPlayer(
            title: 'Audio Player',
            duration: duration,
            onDownload: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('다운로드할 음원이 아직 없습니다.'))),
          ),
          const SizedBox(height: 42),
          _ResultSection(
            title: '결과 요약',
            bullets: [
              if (project.preserveMelody) '원곡의 익숙한 선율 유지',
              if (project.preserveVocal) '보컬 유지 편곡 적용',
              'BPM 128',
              '장단 ${_jangdanLabel(project.preferredJangdan)}',
              '분위기 ${_moodLabel(project.targetMood)}',
              '변환 강도 ${_intensityLabel(project.conversionIntensity)}',
              '길이 ${formatDuration(duration)}',
            ],
          ),
          const SizedBox(height: 34),
          _ResultSection(title: '적용 악기', bullets: instruments),
          const SizedBox(height: 34),
          const _ResultSection(
            title: '파일 정보',
            bullets: ['전체 음원 길이 기준 변환', '파일 크기 12.4 MB'],
          ),
          const SizedBox(height: 44),
          FlowActionButton(
            label: 'MV 생성하기',
            onPressed: () {
              project.confirmAudioBeforeMv(saveToArchive: !auth.isGuest);
              context.go('/mv/settings');
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FlowActionButton(
                  label: '다시 변환',
                  primary: false,
                  onPressed: () {
                    project.discardPendingAudioResult();
                    context.go('/audio/settings');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FlowActionButton(
                  label: '홈으로',
                  primary: false,
                  onPressed: () {
                    project.confirmAudioOnlyResult(
                      saveToArchive: !auth.isGuest,
                    );
                    context.go('/home');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _jangdanLabel(String? value) {
  switch (value) {
    case 'jajinmori':
      return '자진모리';
    case 'jungmori':
      return '중모리';
    case 'gutgeori':
      return '굿거리';
    case 'semachi':
      return '세마치';
    case 'auto':
    case null:
      return '자동 추천';
    default:
      return value;
  }
}

String _instrumentLabel(String value) {
  switch (value) {
    case 'gayageum':
      return '가야금';
    case 'haegeum':
      return '해금';
    case 'daegeum':
      return '대금';
    case 'janggu':
      return '장구';
    case 'samulnori':
      return '사물놀이';
    default:
      return value;
  }
}

String _moodLabel(String? value) {
  switch (value) {
    case 'energetic':
      return '신나는';
    case 'calm':
      return '잔잔한';
    case 'grand':
      return '웅장한';
    case 'dreamy':
      return '몽환적인';
    case 'auto':
    case null:
      return '자동 추천';
    default:
      return value;
  }
}

String _intensityLabel(String? value) {
  switch (value) {
    case 'original_focused':
      return '원곡 중심';
    case 'gugak_focused':
      return '국악 중심';
    case 'balanced':
    case null:
      return '균형 있게';
    default:
      return value;
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.title, required this.bullets});

  final String title;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        GrayCard(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final bullet in bullets)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Text(
                    '•  $bullet',
                    style: const TextStyle(fontSize: 15, height: 1.35),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
