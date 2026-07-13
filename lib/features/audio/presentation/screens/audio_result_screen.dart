import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/mock_player.dart';
import '../../../../shared/widgets/primary_lavender_button.dart';

class AudioResultScreen extends StatelessWidget {
  const AudioResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final auth = context.watch<AuthProvider>();
    final duration = Duration(
      seconds: project.outputAudioDurationSeconds ?? 192,
    );
    final projectName = project.projectName.isEmpty
        ? '새 프로젝트'
        : project.projectName;
    final jangdan = _jangdanLabel(project.preferredJangdan);
    final mood = _moodLabel(project.targetMood);
    final intensity = _intensityLabel(project.conversionIntensity);
    final instruments = project.preferredInstruments.isEmpty
        ? '자동 추천'
        : project.preferredInstruments.map(_instrumentLabel).join(', ');

    return GugakifyAppScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          const Positioned.fill(child: _ResultAtmosphere()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultHeader(
                projectName: projectName,
                onBack: () => context.go('/audio/settings'),
              ),
              const SizedBox(height: 20),
              _CompletionHeroCard(bpm: '128', jangdan: jangdan, mood: mood),
              const SizedBox(height: 16),
              _AudioPlayerCard(
                duration: duration,
                onDownload: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('다운로드할 음원이 아직 없습니다.')),
                ),
              ),
              const SizedBox(height: 16),
              _ResultSummaryCard(
                items: [
                  _SummaryItem(label: '변환 방향', value: intensity),
                  _SummaryItem(
                    label: '선율 유지',
                    value: project.preserveMelody ? '켜짐' : '꺼짐',
                  ),
                  _SummaryItem(
                    label: '보컬 유지',
                    value: project.preserveVocal ? '켜짐' : '꺼짐',
                  ),
                  _SummaryItem(label: '장단', value: jangdan),
                  _SummaryItem(label: '분위기', value: mood),
                  _SummaryItem(label: '악기', value: instruments),
                  const _SummaryItem(label: 'BPM', value: '128'),
                  _SummaryItem(label: '길이', value: formatDuration(duration)),
                ],
              ),
              const SizedBox(height: 16),
              const _MvGuideCard(),
              const SizedBox(height: 20),
              PrimaryLavenderButton(
                label: 'MV 생성하기',
                icon: const Icon(Icons.movie_creation_outlined, size: 19),
                onPressed: () {
                  project.confirmAudioBeforeMv(saveToArchive: !auth.isGuest);
                  context.go('/mv/settings');
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SecondaryOutlineButton(
                      label: '다시 변환',
                      onPressed: () {
                        project.discardPendingAudioResult();
                        context.go('/audio/settings');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SecondaryOutlineButton(
                      label: '홈으로',
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

class _ResultAtmosphere extends StatelessWidget {
  const _ResultAtmosphere();

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
            right: -44,
            child: Container(
              width: 146,
              height: 146,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.paleLavender.withValues(alpha: 0.56),
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            left: -54,
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

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.projectName, required this.onBack});

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
                tooltip: '옵션 화면으로 돌아가기',
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBack,
              ),
              const _StepPill(label: 'STEP 4'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '국악 음원 완성',
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

class _StepPill extends StatelessWidget {
  const _StepPill({required this.label});

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
  const _CompletionHeroCard({
    required this.bpm,
    required this.jangdan,
    required this.mood,
  });

  final String bpm;
  final String jangdan;
  final String mood;

  @override
  Widget build(BuildContext context) {
    return _KoreanSurface(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Stack(
        children: [
          const Positioned.fill(child: _HeroInkWash()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepPill(label: 'AI Gugak Conversion'),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.paleLavender,
                      border: Border.all(color: AppColors.lightPurple),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryPurple,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const SizedBox(
                    width: 214,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '국악 스타일 음원이\n완성됐어요',
                          style: TextStyle(
                            color: AppColors.textBlack,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '원곡의 흐름을 바탕으로 장단과 국악 악기 구성을 반영해 재해석했습니다.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaPill(label: 'BPM $bpm'),
                  _MetaPill(label: jangdan),
                  _MetaPill(label: '$mood 분위기'),
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

class _AudioPlayerCard extends StatelessWidget {
  const _AudioPlayerCard({required this.duration, required this.onDownload});

  final Duration duration;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return _KoreanSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.primaryPurple,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '변환된 국악 음원',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '전체 음원 기반 변환 결과',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          MockAudioPlayer(
            title: 'Gugakify audio result',
            duration: duration,
            onDownload: onDownload,
          ),
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
            '변환 요약',
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
                    wide: item.label == '악기',
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

class _MvGuideCard extends StatelessWidget {
  const _MvGuideCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: AppColors.paleLavender.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.8)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primaryPurple,
            size: 18,
          ),
          SizedBox(width: 9),
          SizedBox(
            width: 258,
            child: Text(
              '이 음원을 기반으로 수묵화, 채색화, 산수화 스타일의 전통 MV를 이어서 만들 수 있어요.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.5,
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
