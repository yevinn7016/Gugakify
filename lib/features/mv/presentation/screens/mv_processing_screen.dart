import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';

class MvProcessingScreen extends StatefulWidget {
  const MvProcessingScreen({super.key});

  @override
  State<MvProcessingScreen> createState() => _MvProcessingScreenState();
}

class _MvProcessingScreenState extends State<MvProcessingScreen> {
  Timer? _timer;
  final _steps = const [
    '입력 영상 준비',
    '프레임 추출',
    '전통 화풍 변환',
    '프레임 연속성 보정',
    '영상 합성',
    '오디오 병합',
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
    final project = context.watch<ProjectProvider>();
    final progress = project.progress.clamp(0.0, 1.0);
    final index = (progress * _steps.length).floor().clamp(
      0,
      _steps.length - 1,
    );
    final projectName = project.projectName.isEmpty
        ? '새 프로젝트'
        : project.projectName;

    return GugakifyAppScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          const Positioned.fill(child: _MvProcessingAtmosphere()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MvProcessingHeader(
                projectName: projectName,
                onBack: () => context.go('/mv/settings'),
              ),
              const SizedBox(height: 22),
              _MvProcessingCard(progress: progress, currentStep: _steps[index]),
              const SizedBox(height: 16),
              _SelectedOptionsCard(project: project),
              const SizedBox(height: 16),
              _StepListCard(
                steps: _steps,
                activeIndex: index,
                progress: progress,
              ),
              const SizedBox(height: 16),
              const _WaitingGuideCard(),
            ],
          ),
        ],
      ),
    );
  }
}

class _MvProcessingAtmosphere extends StatelessWidget {
  const _MvProcessingAtmosphere();

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
            top: 92,
            right: -42,
            child: Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.paleLavender.withValues(alpha: 0.52),
              ),
            ),
          ),
          Positioned(
            top: 266,
            left: -54,
            child: Container(
              width: 128,
              height: 128,
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

class _MvProcessingHeader extends StatelessWidget {
  const _MvProcessingHeader({required this.projectName, required this.onBack});

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
                tooltip: 'MV 설정 화면으로 돌아가기',
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBack,
              ),
              const _StepPill(label: 'STEP 6'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '전통 화풍 변환 중',
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
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
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

class _MvProcessingCard extends StatelessWidget {
  const _MvProcessingCard({required this.progress, required this.currentStep});

  final double progress;
  final String currentStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.065),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _MvProcessingInkWash()),
          Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: _StepPill(label: 'AI Traditional MV'),
              ),
              const SizedBox(height: 22),
              _PulseIcon(progress: progress),
              const SizedBox(height: 20),
              const Text(
                'AI가 입력 영상을\n전통 화풍으로 변환하고 있어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'OpenCV 기반으로 각 프레임을 선택한 전통 화풍으로 변환하고 원본 오디오와 합치는 중입니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: progress),
                duration: const Duration(milliseconds: 220),
                builder: (context, value, child) {
                  return Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.deepInkPurple,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _SoftProgressBar(progress: progress),
              const SizedBox(height: 16),
              _CurrentStepPill(label: currentStep),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseIcon extends StatelessWidget {
  const _PulseIcon({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: progress),
      duration: const Duration(milliseconds: 250),
      builder: (context, value, child) {
        final pulse = 0.35 + (value * 0.5);
        return SizedBox(
          width: 108,
          height: 108,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.paleLavender.withValues(alpha: 0.48),
                ),
              ),
              Container(
                width: 84 + pulse * 8,
                height: 84 + pulse * 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.lightPurple.withValues(alpha: 0.76),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundAlt,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.movie_creation_outlined,
                  color: AppColors.primaryPurple,
                  size: 34,
                ),
              ),
              Positioned(
                left: 18,
                bottom: 18,
                child: Opacity(
                  opacity: 0.38 + value * 0.42,
                  child: const Icon(
                    Icons.brush_outlined,
                    color: AppColors.deepInkPurple,
                    size: 17,
                  ),
                ),
              ),
              Positioned(
                right: 15,
                top: 18,
                child: Opacity(
                  opacity: 0.45 + value * 0.45,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.deepInkPurple,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SoftProgressBar extends StatelessWidget {
  const _SoftProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.paleLavender,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: constraints.maxWidth * progress,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.lightPurple],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CurrentStepPill extends StatelessWidget {
  const _CurrentStepPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.paleLavender.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.lightPurple),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.movie_filter_outlined,
            size: 17,
            color: AppColors.primaryPurple,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 236,
            child: Text(
              '현재 단계: $label',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.deepInkPurple,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MvProcessingInkWash extends StatelessWidget {
  const _MvProcessingInkWash();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CustomPaint(
        painter: _MvProcessingInkPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MvProcessingInkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final moonPaint = Paint()
      ..color = AppColors.lightPurple.withValues(alpha: 0.22);
    canvas.drawCircle(Offset(size.width - 40, 44), 30, moonPaint);

    final framePaint = Paint()
      ..color = AppColors.deepInkPurple.withValues(alpha: 0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 98, 84, 70, 40),
      const Radius.circular(10),
    );
    canvas.drawRRect(frame, framePaint);

    final linePaint = Paint()
      ..color = AppColors.deepInkPurple.withValues(alpha: 0.1)
      ..strokeWidth = 2.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = size.height - 44 + i * 12;
      final wave = Path()
        ..moveTo(size.width * 0.22, y)
        ..cubicTo(
          size.width * 0.42,
          y - 22,
          size.width * 0.63,
          y + 18,
          size.width * 0.9,
          y - 6,
        )
        ..cubicTo(
          size.width,
          y - 14,
          size.width + 16,
          y - 2,
          size.width + 26,
          y,
        );
      canvas.drawPath(wave, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MvProcessingInkPainter oldDelegate) => false;
}

class _SelectedOptionsCard extends StatelessWidget {
  const _SelectedOptionsCard({required this.project});

  final ProjectProvider project;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '선택한 MV 옵션',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OptionPill(
                label: '스타일',
                value: _visualStyleLabel(project.visualStyle),
              ),
              _OptionPill(
                label: '연출',
                value: _effectModeLabel(project.effectMode),
              ),
              _OptionPill(label: '비율', value: project.aspectRatio ?? '선택 전'),
              const _OptionPill(label: '길이', value: '전체 음원 기반'),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionPill extends StatelessWidget {
  const _OptionPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.paleLavender.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.85)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: AppColors.deepInkPurple,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StepListCard extends StatelessWidget {
  const _StepListCard({
    required this.steps,
    required this.activeIndex,
    required this.progress,
  });

  final List<String> steps;
  final int activeIndex;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '진행 단계',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++)
            _StepListItem(
              label: steps[i],
              isCompleted: progress >= 1 || i < activeIndex,
              isCurrent: progress < 1 && i == activeIndex,
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _StepListItem extends StatelessWidget {
  const _StepListItem({
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
  });

  final String label;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted || isCurrent
        ? AppColors.primaryPurple
        : AppColors.textGray;
    final icon = isCompleted
        ? Icons.check_circle_rounded
        : isCurrent
        ? Icons.movie_filter_outlined
        : Icons.radio_button_unchecked_rounded;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 10 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(icon, size: 22, color: color),
              if (!isLast)
                Container(
                  width: 2,
                  height: 20,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 248,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.paleLavender.withValues(alpha: 0.86)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: isCurrent
                  ? Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.35),
                    )
                  : null,
            ),
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isCompleted || isCurrent
                    ? AppColors.textBlack
                    : AppColors.textGray,
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingGuideCard extends StatelessWidget {
  const _WaitingGuideCard();

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
            Icons.info_outline_rounded,
            color: AppColors.primaryPurple,
            size: 18,
          ),
          SizedBox(width: 9),
          SizedBox(
            width: 258,
            child: Text(
              '영상은 프레임 단위로 변환되므로 처리 시간이 오래 걸릴 수 있어요.',
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

String _visualStyleLabel(String? value) {
  switch (value) {
    case 'sumukhwa':
      return '수묵화';
    case 'minhwa':
      return '민화';
    case null:
      return '선택 전';
    default:
      return value;
  }
}

String _effectModeLabel(String? value) {
  switch (value) {
    case 'calm':
      return '잔잔하게';
    case 'balanced':
      return '균형 있게';
    case 'dynamic':
      return '역동적으로';
    case null:
      return '선택 전';
    default:
      return value;
  }
}
