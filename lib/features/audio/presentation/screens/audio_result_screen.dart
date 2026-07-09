import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/flow_action_button.dart';
import '../../../../shared/widgets/gugak_header.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/mock_info_panel.dart';
import '../../../../shared/widgets/mock_player.dart';

class AudioResultScreen extends StatelessWidget {
  const AudioResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(title: '음원 결과', onBack: () => context.go('/audio/settings')),
          const SizedBox(height: 18),
          const Text('국악 음원 변환 완료', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
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
              Text('선율 유지: ${project.preserveMelody ? '적용' : '미적용'}'),
              Text('보컬 유지: ${project.preserveVocal ? '적용' : '미적용'}'),
              const Text('BPM 128 · energetic · 자진모리'),
            ],
          ),
          const SizedBox(height: 12),
          const MockInfoPanel(title: '적용 악기', children: [Text('장구, 가야금, 해금')]),
          const SizedBox(height: 12),
          const MockInfoPanel(title: '파일 정보', children: [Text('길이 29.8초'), Text('파일 크기 12.4MB')]),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: FlowActionButton(label: '다시 변환', primary: false, onPressed: () => context.go('/audio/settings'))),
              const SizedBox(width: 10),
              Expanded(
                child: FlowActionButton(
                  label: 'MV 생성하기',
                  onPressed: () {
                    project.updateStatus('mv_setting', newProgress: 0.5);
                    context.go('/mv/settings');
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
