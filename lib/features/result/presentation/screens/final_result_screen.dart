import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/mock_player.dart';
import '../../../../shared/widgets/primary_lavender_button.dart';

class FinalResultScreen extends StatelessWidget {
  const FinalResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final ratio = aspectRatioValue(project.aspectRatio);
    final audioDuration = Duration(
      seconds: project.outputAudioDurationSeconds ?? 192,
    );
    final videoDuration = Duration(
      seconds:
          project.outputVideoDurationSeconds ??
          project.outputAudioDurationSeconds ??
          192,
    );
    final projectName = project.projectName.isEmpty
        ? '새 프로젝트'
        : project.projectName;
    final outputAudioFileName =
        project.outputAudioFileName ??
        ProjectProvider.buildOutputAudioFileName(project.projectName);
    final outputVideoFileName =
        project.outputVideoFileName ??
        ProjectProvider.buildOutputVideoFileName(project.projectName);
    return GugakifyAppScaffold(
      backgroundColor: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Stack(
        children: [
          const Positioned.fill(child: _FinalAtmosphere()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FinalHeader(
                projectName: projectName,
                onBack: () => context.go('/mv/settings'),
              ),
              const SizedBox(height: 18),
              const _CompletionHeroCard(),
              const SizedBox(height: 16),
              _MediaSection(
                title: '전통 화풍 MV',
                description: '입력 영상을 전통 화풍으로 변환한 결과',
                icon: Icons.movie_creation_outlined,
                child: MockVideoPlayer(
                  title: outputVideoFileName,
                  duration: videoDuration,
                  aspectRatio: ratio,
                  onDownload: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '다운로드할 MV가 아직 없습니다. ($outputVideoFileName)',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _MediaSection(
                title: '국악 음원',
                description: '원곡 멜로디를 국악기 음색으로 재연주한 결과',
                icon: Icons.graphic_eq_rounded,
                child: MockAudioPlayer(
                  title: outputAudioFileName,
                  duration: audioDuration,
                  onDownload: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('다운로드할 음원이 아직 없습니다.')),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ResultSummaryCard(
                items: [
                  _SummaryItem(
                    label: 'MV 스타일',
                    value: _visualStyleLabel(project.visualStyle),
                  ),
                  _SummaryItem(
                    label: '화면 비율',
                    value: project.aspectRatio ?? '16:9',
                  ),
                  _SummaryItem(
                    label: '길이',
                    value: formatDuration(videoDuration),
                  ),
                  _SummaryItem(
                    label: '보컬 악기',
                    value: _instrumentLabel(project.vocalInstrument),
                  ),
                  _SummaryItem(
                    label: '반주 악기',
                    value: _instrumentLabel(project.accompanimentInstrument),
                  ),
                  const _SummaryItem(
                    label: '음원 처리',
                    value: '보컬/반주 분리 → MIDI 생성 → 악기별 렌더링',
                  ),
                  _SummaryItem(label: '음원 파일', value: outputAudioFileName),
                  _SummaryItem(label: 'MV 파일', value: outputVideoFileName),
                  const _SummaryItem(
                    label: 'MV 처리',
                    value: '프레임 단위 스타일 변환 → 오디오 병합',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SecondaryOutlineButton(
                      label: '다시 변환',
                      onPressed: () => context.go('/mv/settings'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryLavenderButton(
                      label: '홈으로',
                      onPressed: () => context.go('/home'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _visualStyleLabel(String? value) {
  switch (value) {
    case 'sumukhwa':
      return '수묵화';
    case 'minhwa':
      return '민화';
    case null:
      return '수묵화';
    default:
      return value;
  }
}

String _instrumentLabel(String? value) {
  switch (value) {
    case 'geomungo':
      return '거문고';
    case 'gayageum':
      return '가야금';
    case 'haegeum':
      return '해금';
    case 'daegeum':
      return '대금';
    case 'piri':
      return '피리';
    case 'danso':
      return '단소';
    case null:
      return '선택 전';
    default:
      return value;
  }
}

class _FinalAtmosphere extends StatelessWidget {
  const _FinalAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.055,
              child: Image.asset(
                'assets/images/intro_hero.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.92),
              ),
            ),
          ),
          Positioned(
            top: 86,
            right: -48,
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.paleLavender.withValues(alpha: 0.56),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            left: -58,
            child: Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.lightPurple.withValues(alpha: 0.34),
                  width: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalHeader extends StatelessWidget {
  const _FinalHeader({required this.projectName, required this.onBack});

  final String projectName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleIconButton(
                tooltip: 'MV 설정으로 돌아가기',
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBack,
              ),
              const _StatusPill(label: '완성됨'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '최종 결과',
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          projectName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.deepInkPurple,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.72),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          color: AppColors.primaryPurple,
          icon: Icon(icon, size: 18),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.paleLavender.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightPurple),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.deepInkPurple,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CompletionHeroCard extends StatelessWidget {
  const _CompletionHeroCard();

  @override
  Widget build(BuildContext context) {
    return _KoreanSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Stack(
        children: [
          const Positioned.fill(child: _HeroInkWash()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StatusPill(label: 'Gugakify Result'),
              const SizedBox(height: 14),
              const Text(
                '전통 화풍 MV가\n완성됐어요',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '입력 영상을 수묵화 또는 민화 스타일로 변환한 결과입니다. 국악 스타일 음원과 전통 화풍 영상을 함께 확인할 수 있어요.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaPill(label: '전체 음원 기반'),
                  _MetaPill(label: '전통 화풍 MV'),
                  _MetaPill(label: '프레임 스타일 변환'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.deepInkPurple,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MediaSection extends StatelessWidget {
  const _MediaSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.child,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _KoreanSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ResultSummaryCard extends StatelessWidget {
  const _ResultSummaryCard({required this.items});

  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return _KoreanSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '결과 요약',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: items
                .map(
                  (item) => _SummaryTile(
                    label: item.label,
                    value: item.value,
                    wide: item.label == '악기' || item.label == '생성 방식',
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    this.wide = false,
  });

  final String label;
  final String value;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? 288 : 139,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: AppColors.paleLavender.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: wide ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.deepInkPurple,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// Retained for compatibility with archived mock results; not shown currently.
// ignore: unused_element
class _EffectSummaryCard extends StatelessWidget {
  const _EffectSummaryCard();

  @override
  Widget build(BuildContext context) {
    return _KoreanSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '적용된 전통 효과',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14),
          _EffectRow(text: '장구 타격 구간에서 먹 번짐 효과 확대'),
          _EffectRow(text: '빠른 BPM 구간에서 붓 획 속도 증가'),
          _EffectRow(text: '클라이맥스 구간에서 빠른 화면 전환 적용', isLast: true),
        ],
      ),
    );
  }
}

class _EffectRow extends StatelessWidget {
  const _EffectRow({required this.text, this.isLast = false});

  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primaryPurple,
            size: 16,
          ),
          const SizedBox(width: 9),
          SizedBox(
            width: 258,
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textBlack,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KoreanSurface extends StatelessWidget {
  const _KoreanSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.055),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeroInkWash extends StatelessWidget {
  const _HeroInkWash();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: CustomPaint(
        painter: _HeroInkPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HeroInkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final moonPaint = Paint()
      ..color = AppColors.lightPurple.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(size.width - 34, 38), 26, moonPaint);

    final linePaint = Paint()
      ..color = AppColors.deepInkPurple.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 2; i++) {
      final y = size.height - 28 + i * 10;
      final wave = Path()
        ..moveTo(size.width * 0.36, y)
        ..cubicTo(
          size.width * 0.52,
          y - 18,
          size.width * 0.72,
          y + 16,
          size.width,
          y - 4,
        );
      canvas.drawPath(wave, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroInkPainter oldDelegate) => false;
}
