import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/primary_lavender_button.dart';

const _jangdanOptions = {
  'auto': '자동 추천',
  'jajinmori': '자진모리',
  'jungmori': '중모리',
  'gutgeori': '굿거리',
  'semachi': '세마치',
};

const _instrumentOptions = {
  'gayageum': '가야금',
  'haegeum': '해금',
  'daegeum': '대금',
  'janggu': '장구',
  'samulnori': '사물놀이',
};

const _moodOptions = {
  'auto': '자동 추천',
  'energetic': '신나는',
  'calm': '잔잔한',
  'grand': '웅장한',
  'dreamy': '몽환적인',
};

const _intensityOptions = {
  'original_focused': '원곡 중심',
  'balanced': '균형 있게',
  'gugak_focused': '국악 중심',
};

class AudioConvertSettingScreen extends StatelessWidget {
  const AudioConvertSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final title = project.projectName.isEmpty ? '새 프로젝트' : project.projectName;
    return GugakifyAppScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          const Positioned.fill(child: _AudioAtmosphere()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AudioHeader(title: title, onBack: () => context.go('/upload')),
              const SizedBox(height: 20),
              _SectionCard(
                title: '변환 방식',
                caption: '원곡의 어느 부분을 살릴지 선택해주세요',
                child: Column(
                  children: [
                    _FeatureToggleCard(
                      icon: Icons.graphic_eq_rounded,
                      title: '원곡 선율 유지',
                      description: '원곡의 멜로디 흐름을 최대한 살려요',
                      value: project.preserveMelody,
                      onChanged: (value) =>
                          project.setAudioSettings(melody: value),
                    ),
                    const SizedBox(height: 10),
                    _FeatureToggleCard(
                      icon: Icons.mic_none_rounded,
                      title: '보컬 유지',
                      description: '보컬 느낌을 유지한 채 국악 음색을 더해요',
                      value: project.preserveVocal,
                      onChanged: (value) =>
                          project.setAudioSettings(vocal: value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _OptionSection(
                title: '국악 변환 방향',
                options: _intensityOptions,
                selectedValues: {project.conversionIntensity ?? 'balanced'},
                onTap: (value) => project.setAudioSettings(intensity: value),
              ),
              _OptionSection(
                title: '장단 선택',
                options: _jangdanOptions,
                selectedValues: {project.preferredJangdan ?? 'auto'},
                onTap: (value) => project.setAudioSettings(jangdan: value),
              ),
              _OptionSection(
                title: '악기 구성',
                caption: '여러 개를 선택할 수 있어요',
                options: _instrumentOptions,
                selectedValues: project.preferredInstruments.toSet(),
                onTap: (value) {
                  final next = [...project.preferredInstruments];
                  next.contains(value) ? next.remove(value) : next.add(value);
                  project.setAudioSettings(instruments: next);
                },
              ),
              _OptionSection(
                title: '분위기',
                options: _moodOptions,
                selectedValues: {project.targetMood ?? 'auto'},
                onTap: (value) => project.setAudioSettings(mood: value),
              ),
              _SelectionSummaryCard(project: project),
              const SizedBox(height: 24),
              PrimaryLavenderButton(
                label: '국악 변환 시작',
                icon: const Icon(Icons.auto_awesome_rounded, size: 19),
                onPressed: () {
                  project.updateStatus('audio_processing', newProgress: 0);
                  context.go('/audio/processing');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AudioAtmosphere extends StatelessWidget {
  const _AudioAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
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
            right: -48,
            child: Container(
              width: 138,
              height: 138,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.paleLavender.withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            left: -58,
            child: Container(
              width: 132,
              height: 132,
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

class _AudioHeader extends StatelessWidget {
  const _AudioHeader({required this.title, required this.onBack});

  final String title;
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
                tooltip: '이전 화면',
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBack,
              ),
              Image.asset(
                'assets/icons/gugakify_wordmark.png',
                width: 86,
                errorBuilder: (_, error, stackTrace) => const Text(
                  'Gugakify',
                  style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _StepPill(label: 'STEP 2'),
        const SizedBox(height: 12),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textBlack,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '국악 변환 옵션을 선택해주세요',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.caption});

  final String title;
  final String? caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.055),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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

class _FeatureToggleCard extends StatelessWidget {
  const _FeatureToggleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: value
            ? AppColors.paleLavender.withValues(alpha: 0.95)
            : AppColors.cardLight.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value
              ? AppColors.primaryPurple.withValues(alpha: 0.44)
              : AppColors.borderSoft,
        ),
      ),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 8, 13),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textWidth = (constraints.maxWidth - 106).clamp(
                0.0,
                constraints.maxWidth,
              );
              return Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundAlt.withValues(alpha: 0.76),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.borderSoft.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Icon(icon, color: AppColors.primaryPurple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: textWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          description,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.76,
                    child: Switch(
                      value: value,
                      activeThumbColor: AppColors.primaryPurple,
                      activeTrackColor: AppColors.lightPurple,
                      inactiveThumbColor: AppColors.white,
                      inactiveTrackColor: AppColors.disabledGray,
                      onChanged: onChanged,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OptionSection extends StatelessWidget {
  const _OptionSection({
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onTap,
    this.caption,
  });

  final String title;
  final String? caption;
  final Map<String, String> options;
  final Set<String> selectedValues;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _SectionCard(
        title: title,
        caption: caption,
        child: Wrap(
          spacing: 8,
          runSpacing: 9,
          children: options.entries
              .map(
                (entry) => _SelectablePill(
                  label: entry.value,
                  selected: selectedValues.contains(entry.key),
                  onTap: () => onTap(entry.key),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SelectablePill extends StatelessWidget {
  const _SelectablePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.paleLavender
              : AppColors.backgroundAlt.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple.withValues(alpha: 0.5)
                : AppColors.borderSoft,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(
                Icons.check_rounded,
                size: 15,
                color: AppColors.deepInkPurple,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.deepInkPurple : AppColors.textBlack,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionSummaryCard extends StatelessWidget {
  const _SelectionSummaryCard({required this.project});

  final ProjectProvider project;

  @override
  Widget build(BuildContext context) {
    final jangdan = _jangdanOptions[project.preferredJangdan ?? 'auto']!;
    final mood = _moodOptions[project.targetMood ?? 'auto']!;
    final intensity =
        _intensityOptions[project.conversionIntensity ?? 'balanced']!;
    final instruments = project.preferredInstruments.isEmpty
        ? '자동 추천'
        : project.preferredInstruments
              .map((value) => _instrumentOptions[value] ?? value)
              .join(', ');

    return _SectionCard(
      title: '선택 요약',
      caption: '현재 선택한 국악 변환 설정입니다',
      child: Column(
        children: [
          _SummaryRow(
            label: '선율 유지',
            value: project.preserveMelody ? '켜짐' : '꺼짐',
          ),
          _SummaryRow(
            label: '보컬 유지',
            value: project.preserveVocal ? '켜짐' : '꺼짐',
          ),
          _SummaryRow(label: '변환 방향', value: intensity),
          _SummaryRow(label: '장단', value: jangdan),
          _SummaryRow(label: '악기', value: instruments),
          _SummaryRow(label: '분위기', value: mood, isLast: true),
        ],
      ),
    );
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
                  color: AppColors.borderSoft.withValues(alpha: 0.7),
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
                  style: const TextStyle(
                    color: AppColors.deepInkPurple,
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
