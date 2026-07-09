import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/flow_action_button.dart';
import '../../../../shared/widgets/gray_card.dart';
import '../../../../shared/widgets/gugak_header.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/option_chip_button.dart';

class AudioConvertSettingScreen extends StatelessWidget {
  const AudioConvertSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final title = project.projectName.isEmpty ? 'APT 국악 변환' : '${project.projectName} 국악 변환';
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(title: '국악 변환', onBack: () => context.go('/upload')),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('원곡의 특징을 선택하고 국악 스타일 변환을 시작하세요.'),
          const SizedBox(height: 22),
          _ToggleCard(
            title: '원곡의 익숙한 선율을 유지합니다',
            value: project.preserveMelody,
            onChanged: (value) => project.setAudioSettings(melody: value),
          ),
          const SizedBox(height: 12),
          _ToggleCard(
            title: '보컬을 유지한 채 국악 편곡합니다.',
            value: project.preserveVocal,
            onChanged: (value) => project.setAudioSettings(vocal: value),
          ),
          const SizedBox(height: 18),
          GrayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('고급 옵션', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OptionChipButton(
                      label: '장단 자동 추천',
                      selected: project.preferredJangdan == '자진모리',
                      onTap: () => project.setAudioSettings(jangdan: '자진모리'),
                    ),
                    OptionChipButton(
                      label: '악기 자동 추천',
                      selected: project.preferredInstruments.isNotEmpty,
                      onTap: () => project.setAudioSettings(instruments: ['장구', '가야금', '해금']),
                    ),
                    OptionChipButton(
                      label: '분위기 자동 추천',
                      selected: project.targetMood == 'energetic',
                      onTap: () => project.setAudioSettings(mood: 'energetic'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 46),
          Row(
            children: [
              Expanded(child: FlowActionButton(label: '이전', primary: false, onPressed: () => context.go('/upload'))),
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

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({required this.title, required this.value, required this.onChanged});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GrayCard(
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
