import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/primary_lavender_button.dart';

const _visualStyleOptions = {
  'sumukhwa': _VisualStyleOption(
    label: '수묵화',
    description: '먹의 흐름과 한지 질감이 살아있는 수묵 스타일',
    icon: Icons.brush_outlined,
  ),
  'minhwa': _VisualStyleOption(
    label: '민화',
    description: '전통 색감과 장식성이 살아있는 민화 스타일',
    icon: Icons.palette_outlined,
  ),
};

const _effectModeOptions = {
  'calm': _EffectOption(
    label: '잔잔하게',
    description: '먹 번짐과 안개 흐름을 부드럽게',
    icon: Icons.water_drop_outlined,
  ),
  'balanced': _EffectOption(
    label: '균형 있게',
    description: '음악 흐름에 맞춰 자연스럽게 변화',
    icon: Icons.tune_rounded,
  ),
  'dynamic': _EffectOption(
    label: '역동적으로',
    description: '빠른 장단에 맞춰 붓 획과 전환을 강조',
    icon: Icons.auto_awesome_rounded,
  ),
};

const _aspectRatioOptions = {
  '16:9': _AspectRatioOption(label: '16:9', description: '가로형 영상'),
  '9:16': _AspectRatioOption(label: '9:16', description: '모바일 숏폼'),
  '1:1': _AspectRatioOption(label: '1:1', description: '정사각형'),
};

class MvSettingScreen extends StatelessWidget {
  const MvSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final canStart = project.visualStyle != null && project.aspectRatio != null;
    final projectName = project.projectName.isEmpty
        ? '새 프로젝트'
        : project.projectName;

    return GugakifyAppScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          const Positioned.fill(child: _MvAtmosphere()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MvHeader(
                projectName: projectName,
                onBack: () => context.go('/audio/result'),
              ),
              const SizedBox(height: 20),
              const _MvHeroCard(),
              const SizedBox(height: 16),
              _VisualStyleSection(
                selected: project.visualStyle,
                onTap: (value) => project.setMvSettings(style: value),
              ),
              const SizedBox(height: 16),
              _AspectRatioSection(
                selected: project.aspectRatio,
                onTap: (value) => project.setMvSettings(ratio: value),
              ),
              const SizedBox(height: 16),
              _MvSummaryCard(
                visualStyle: project.visualStyle,
                aspectRatio: project.aspectRatio,
              ),
              const SizedBox(height: 22),
              PrimaryLavenderButton(
                label: 'MV 생성 시작',
                icon: const Icon(Icons.movie_creation_outlined, size: 19),
                onPressed: canStart
                    ? () {
                        // TODO(backend integration point): route through the backend.
                        // URL: POST /api/v1/mv-conversions
                        // File: POST /api/v1/mv-conversions/upload
                        // Poll/result: GET /api/v1/mv-conversions/{jobId}[/result]
                        // styleType: sumukhwa|minhwa, preserveAudio: true
                        project.setMvSettings(
                          effect: project.effectMode ?? 'balanced',
                        );
                        project.updateStatus('mv_processing', newProgress: 0);
                        context.go('/mv/processing');
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisualStyleOption {
  const _VisualStyleOption({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}

class _EffectOption {
  const _EffectOption({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}

class _AspectRatioOption {
  const _AspectRatioOption({required this.label, required this.description});

  final String label;
  final String description;
}

class _MvAtmosphere extends StatelessWidget {
  const _MvAtmosphere();

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
              width: 146,
              height: 146,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.paleLavender.withValues(alpha: 0.54),
              ),
            ),
          ),
          Positioned(
            bottom: 88,
            left: -58,
            child: Container(
              width: 138,
              height: 138,
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

class _MvHeader extends StatelessWidget {
  const _MvHeader({required this.projectName, required this.onBack});

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
                tooltip: '오디오 결과로 돌아가기',
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBack,
              ),
              const _StepPill(label: 'STEP 5'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '전통 MV 설정',
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

class _MvHeroCard extends StatelessWidget {
  const _MvHeroCard();

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
              const _StepPill(label: 'AI Traditional MV'),
              const SizedBox(height: 16),
              const Text(
                '전통 화풍 MV 변환',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '입력 영상을 한국 전통 화풍으로 변환합니다.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaPill(label: '프레임 스타일 변환'),
                  _MetaPill(label: '원본 오디오 유지'),
                  _MetaPill(label: '수묵화 · 민화'),
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

class _VisualStyleSection extends StatelessWidget {
  const _VisualStyleSection({required this.selected, required this.onTap});

  final String? selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: '비주얼 스타일',
      caption: 'MV의 전체 그림체와 전통 미감을 선택해주세요.',
      child: Column(
        children: [
          for (final entry in _visualStyleOptions.entries) ...[
            _VisualStyleCard(
              option: entry.value,
              selected: selected == entry.key,
              onTap: () => onTap(entry.key),
            ),
            if (entry.key != _visualStyleOptions.keys.last)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _VisualStyleCard extends StatelessWidget {
  const _VisualStyleCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _VisualStyleOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.paleLavender.withValues(alpha: 0.92)
              : AppColors.backgroundAlt.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple.withValues(alpha: 0.52)
                : AppColors.borderSoft,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreviewMark(icon: option.icon, selected: selected),
            const SizedBox(width: 12),
            SizedBox(
              width: 202,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      color: selected
                          ? AppColors.deepInkPurple
                          : AppColors.textBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    option.description,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryPurple,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewMark extends StatelessWidget {
  const _PreviewMark({required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.backgroundAlt.withValues(alpha: 0.95)
            : AppColors.paleLavender.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightPurple.withValues(alpha: 0.8)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _PreviewStrokePainter(selected: selected),
            child: const SizedBox.expand(),
          ),
          Icon(icon, color: AppColors.primaryPurple, size: 22),
        ],
      ),
    );
  }
}

class _PreviewStrokePainter extends CustomPainter {
  const _PreviewStrokePainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.deepInkPurple.withValues(
        alpha: selected ? 0.14 : 0.08,
      )
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(8, size.height - 13)
      ..cubicTo(18, 22, 28, 36, size.width - 8, 15);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PreviewStrokePainter oldDelegate) {
    return oldDelegate.selected != selected;
  }
}

// Retained as a dormant mock option; the current MV API does not expose it.
// ignore: unused_element
class _EffectModeSection extends StatelessWidget {
  const _EffectModeSection({required this.selected, required this.onTap});

  final String? selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: '연출 방식',
      caption: '장단과 분위기에 맞춰 화면 변화의 강도를 선택해주세요.',
      child: Wrap(
        spacing: 8,
        runSpacing: 9,
        children: _effectModeOptions.entries
            .map(
              (entry) => _EffectPill(
                option: entry.value,
                selected: selected == entry.key,
                onTap: () => onTap(entry.key),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EffectPill extends StatelessWidget {
  const _EffectPill({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _EffectOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 140,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.paleLavender
              : AppColors.backgroundAlt.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple.withValues(alpha: 0.5)
                : AppColors.borderSoft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              option.icon,
              color: selected ? AppColors.primaryPurple : AppColors.textMuted,
              size: 19,
            ),
            const SizedBox(height: 7),
            Text(
              option.label,
              style: TextStyle(
                color: selected ? AppColors.deepInkPurple : AppColors.textBlack,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AspectRatioSection extends StatelessWidget {
  const _AspectRatioSection({required this.selected, required this.onTap});

  final String? selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: '영상 비율',
      caption: '결과 MV를 사용할 화면 비율을 선택해주세요.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 16) / 3;
          return Row(
            children: _aspectRatioOptions.entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      right: entry.key == _aspectRatioOptions.keys.last ? 0 : 8,
                    ),
                    child: _AspectRatioCard(
                      width: width,
                      value: entry.key,
                      option: entry.value,
                      selected: selected == entry.key,
                      onTap: () => onTap(entry.key),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _AspectRatioCard extends StatelessWidget {
  const _AspectRatioCard({
    required this.width,
    required this.value,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String value;
  final _AspectRatioOption option;
  final bool selected;
  final VoidCallback onTap;

  double get _ratio {
    switch (value) {
      case '9:16':
        return 9 / 16;
      case '1:1':
        return 1;
      case '16:9':
      default:
        return 16 / 9;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(8, 11, 8, 11),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.paleLavender
                : AppColors.backgroundAlt.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.primaryPurple.withValues(alpha: 0.55)
                  : AppColors.borderSoft,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 42,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _ratio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundAlt.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryPurple
                              : AppColors.lightPurple,
                          width: selected ? 1.6 : 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                option.label,
                style: TextStyle(
                  color: selected
                      ? AppColors.deepInkPurple
                      : AppColors.textBlack,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                option.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MvSummaryCard extends StatelessWidget {
  const _MvSummaryCard({required this.visualStyle, required this.aspectRatio});

  final String? visualStyle;
  final String? aspectRatio;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: 'MV 설정 요약',
      child: Column(
        children: [
          _SummaryRow(label: '스타일', value: _visualLabel(visualStyle)),
          _SummaryRow(label: '비율', value: aspectRatio ?? '선택 전'),
          const _SummaryRow(
            label: '처리 방식',
            value: '프레임 단위 전통 화풍 변환',
            isLast: true,
          ),
        ],
      ),
    );
  }

  String _visualLabel(String? value) {
    if (value == null) {
      return '선택 전';
    }
    return _visualStyleOptions[value]?.label ?? value;
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  bool get _isPending => value == '선택 전';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.borderSoft.withValues(alpha: 0.68),
                ),
              ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final valueWidth = (constraints.maxWidth - 86).clamp(
            0.0,
            constraints.maxWidth,
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 76,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: valueWidth,
                child: Text(
                  value,
                  style: TextStyle(
                    color: _isPending
                        ? AppColors.textMuted
                        : AppColors.deepInkPurple,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionSurface extends StatelessWidget {
  const _SectionSurface({
    required this.title,
    required this.child,
    this.caption,
  });

  final String title;
  final String? caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _KoreanSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 5),
            Text(
              caption!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
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
            color: AppColors.deepInkPurple.withValues(alpha: 0.052),
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
        ..moveTo(size.width * 0.38, y)
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
