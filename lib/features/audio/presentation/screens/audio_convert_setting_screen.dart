import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/flow_action_button.dart';
import '../../../../shared/widgets/gray_card.dart';
import '../../../../shared/widgets/gugak_header.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(title: title, onBack: () => context.go('/upload')),
          const SizedBox(height: 28),
          const Text(
            '원곡의 특징과 국악 변환 방향을 선택해주세요',
            style: TextStyle(color: AppColors.textGray, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _FeatureToggleCard(
            title: '원곡 선율 유지',
            description: '원곡의 익숙한 멜로디 흐름을 최대한 유지합니다.',
            value: project.preserveMelody,
            onChanged: (value) => project.setAudioSettings(melody: value),
          ),
          const SizedBox(height: 12),
          _FeatureToggleCard(
            title: '보컬 유지',
            description: '보컬을 유지한 채 국악 편곡을 적용합니다.',
            value: project.preserveVocal,
            onChanged: (value) => project.setAudioSettings(vocal: value),
          ),
          const SizedBox(height: 26),
          _OptionSection(
            title: '장단 선택',
            options: _jangdanOptions,
            selectedValues: {project.preferredJangdan ?? 'auto'},
            onTap: (value) => project.setAudioSettings(jangdan: value),
          ),
          _OptionSection(
            title: '악기 선택',
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
            title: '분위기 선택',
            options: _moodOptions,
            selectedValues: {project.targetMood ?? 'auto'},
            onTap: (value) => project.setAudioSettings(mood: value),
          ),
          _OptionSection(
            title: '국악 변환 방향',
            options: _intensityOptions,
            selectedValues: {project.conversionIntensity ?? 'balanced'},
            onTap: (value) => project.setAudioSettings(intensity: value),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: FlowActionButton(
                  label: '이전',
                  primary: false,
                  onPressed: () => context.go('/upload'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FlowActionButton(
                  label: '국악 변환 시작',
                  onPressed: () {
                    project.updateStatus('audio_processing', newProgress: 0);
                    context.go('/audio/processing');
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

class _FeatureToggleCard extends StatelessWidget {
  const _FeatureToggleCard({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

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
            ? AppColors.softPurple
            : Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? AppColors.primaryPurple.withValues(alpha: 0.45)
              : AppColors.borderSoft,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 10, 15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.74,
                child: Switch(
                  value: value,
                  activeThumbColor: AppColors.primaryPurple,
                  activeTrackColor: AppColors.lightPurple,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.disabledGray,
                  onChanged: onChanged,
                ),
              ),
            ],
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
      padding: const EdgeInsets.only(bottom: 22),
      child: GrayCard(
        color: Colors.white.withValues(alpha: 0.82),
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    caption!,
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
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
          ],
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
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightPurple : AppColors.cardGrayAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple.withValues(alpha: 0.48)
                : AppColors.borderSoft,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primaryPurple : AppColors.textBlack,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
