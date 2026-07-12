import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/app_state/project_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/flow_action_button.dart';
import '../../../../shared/widgets/gugak_header.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';

const _visualStyleOptions = {
  'sumukhwa': '수묵화',
  'chaesaekhwa': '채색화',
  'sumukh_damchae': '수묵담채화',
  'palace_painting': '궁중채색화',
  'landscape': '산수화',
};

const _effectModeOptions = {
  'calm': '잔잔하게',
  'balanced': '균형 있게',
  'dynamic': '역동적으로',
};

class MvSettingScreen extends StatelessWidget {
  const MvSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final canStart =
        project.visualStyle != null &&
        project.effectMode != null &&
        project.aspectRatio != null;
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(
            title: '새 프로젝트 만들기',
            onBack: () => context.go('/audio/result'),
          ),
          const SizedBox(height: 28),
          const Text(
            '전통 MV 생성 설정',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 26),
          const Text(
            '장단과 에너지 변화에 반응하는 MV를 생성해요',
            style: TextStyle(color: AppColors.textGray, fontSize: 13),
          ),
          const SizedBox(height: 34),
          _Section(
            title: '전통 시각 스타일',
            options: _visualStyleOptions,
            selected: project.visualStyle,
            onTap: (value) => project.setMvSettings(style: value),
          ),
          _Section(
            title: '장단 반응 효과 강도',
            options: _effectModeOptions,
            selected: project.effectMode,
            onTap: (value) => project.setMvSettings(effect: value),
          ),
          _Section(
            title: '영상 비율',
            options: const {'16:9': '16 : 9', '9:16': '9 : 16', '1:1': '1 : 1'},
            selected: project.aspectRatio,
            onTap: (value) => project.setMvSettings(ratio: value),
          ),
          const SizedBox(height: 54),
          Row(
            children: [
              Expanded(
                child: FlowActionButton(
                  label: '이전',
                  primary: false,
                  onPressed: () => context.go('/audio/result'),
                ),
              ),
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
  final Map<String, String> options;
  final String? selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 16) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 10,
                children: options.entries
                    .map(
                      (entry) => _OptionBox(
                        width: width,
                        label: entry.value,
                        selected:
                            selected == entry.key || selected == entry.value,
                        onTap: () => onTap(entry.key),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OptionBox extends StatelessWidget {
  const _OptionBox({
    required this.width,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 46,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.lightPurple : AppColors.cardGray,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primaryPurple.withValues(alpha: 0.45)
                  : AppColors.borderSoft,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primaryPurple : AppColors.textBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
