import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/flow_action_button.dart';
import '../../../../shared/widgets/gugak_header.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/mock_info_panel.dart';
import '../../../../shared/widgets/option_chip_button.dart';

class MvSettingScreen extends StatelessWidget {
  const MvSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final canStart = project.mvLength != null &&
        project.visualStyle != null &&
        project.effectMode != null &&
        project.aspectRatio != null;
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(title: 'MV 설정', onBack: () => context.go('/audio/result')),
          const SizedBox(height: 18),
          const Text('전통 MV 생성 설정', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _Section(title: 'MV 길이', options: ['15초', '30초', '60초'], selected: project.mvLength == null ? null : '${project.mvLength}초', onTap: (value) => project.setMvSettings(length: int.parse(value.replaceAll('초', '')))),
          _Section(title: '전통 시각 스타일', options: ['수묵화', '채색화', '수묵담채화', '궁중채색화', '산수화'], selected: project.visualStyle, onTap: (value) => project.setMvSettings(style: value)),
          _Section(title: '장단 반응 효과 강도', options: ['잔잔하게', '균형 있게', '역동적으로'], selected: project.effectMode, onTap: (value) => project.setMvSettings(effect: value)),
          _Section(title: '영상 비율', options: ['16:9', '9:16', '1:1'], selected: project.aspectRatio, onTap: (value) => project.setMvSettings(ratio: value)),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: FlowActionButton(label: '이전', primary: false, onPressed: () => context.go('/audio/result'))),
              const SizedBox(width: 10),
              Expanded(
                child: FlowActionButton(
                  label: 'MV 생성 시작',
                  onPressed: canStart
                      ? () {
                          project.updateStatus('mv_processing', newProgress: 0);
                          context.go('/mv/processing');
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.options,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MockInfoPanel(
        title: title,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map((option) => OptionChipButton(
                      label: option,
                      selected: selected == option,
                      onTap: () => onTap(option),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
