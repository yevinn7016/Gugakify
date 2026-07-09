import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/flow_action_button.dart';
import '../../../../shared/widgets/gugak_header.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/mock_info_panel.dart';
import '../../../../shared/widgets/mock_player.dart';

class FinalResultScreen extends StatelessWidget {
  const FinalResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final ratio = aspectRatioValue(project.aspectRatio);
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(title: '최종 결과', onBack: () => context.go('/mv/settings')),
          const SizedBox(height: 18),
          const Text('최종 결과', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          MockVideoPlayer(
            title: '생성된 전통 MV',
            aspectRatio: ratio,
            onDownload: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('다운로드할 MV가 아직 없습니다.')),
            ),
          ),
          const SizedBox(height: 14),
          MockAudioPlayer(
            title: '변환된 국악 음원',
            onDownload: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('다운로드할 음원이 아직 없습니다.')),
            ),
          ),
          const SizedBox(height: 14),
          MockInfoPanel(
            title: '결과 요약',
            children: [
              Text('길이 ${project.mvLength ?? 60}초'),
              Text('${project.visualStyle ?? '수묵담채화'} 스타일'),
              Text('${project.effectMode ?? '역동적으로'} 장단 반응 효과'),
              Text('${project.aspectRatio ?? '16:9'} 영상 비율'),
              const Text('128BPM · 자진모리 · energetic'),
            ],
          ),
          const SizedBox(height: 12),
          const MockInfoPanel(
            title: '적용 효과',
            children: [
              Text('장구 타격 구간에서 먹 번짐 효과 확대'),
              Text('빠른 BPM 구간에서 붓 획 속도 증가'),
              Text('클라이맥스 구간에서 빠른 화면 전환 적용'),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: FlowActionButton(label: '다시 변환', primary: false, onPressed: () => context.go('/mv/settings'))),
              const SizedBox(width: 10),
              Expanded(child: FlowActionButton(label: '홈으로', onPressed: () => context.go('/home'))),
            ],
          ),
        ],
      ),
    );
  }
}
