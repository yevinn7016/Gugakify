import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../shared/widgets/demo_media_players.dart';
import '../../../../shared/widgets/gray_card.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/primary_lavender_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectProvider>().recentProjects;
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 64,
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/gugakify_wordmark.png',
                  width: 120,
                  errorBuilder: (_, error, stackTrace) => const Text(
                    'Gugakify',
                    style: TextStyle(color: AppColors.primaryPurple, fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ),
                const Expanded(child: SizedBox.shrink()),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.person_outline_rounded),
                    onPressed: () => context.go('/mypage'),
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.help_outline_rounded),
                    onPressed: () => _showHelp(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            '음악을 AI가 음원을 분석하고\n국악 스타일로 변환해요',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.35),
          ),
          const SizedBox(height: 26),
          PrimaryLavenderButton(
            label: '새 프로젝트 만들기',
            onPressed: () {
              context.read<ProjectProvider>().resetCurrentProject();
              context.go('/upload');
            },
          ),
          const SizedBox(height: 12),
          SecondaryOutlineButton(
            label: '데모 보기',
            onPressed: () => _showDemo(context),
          ),
          const SizedBox(height: 34),
          const Text('최근 프로젝트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            const GrayCard(
              child: Center(
                child: Text('아직 생성된 프로젝트가 없습니다.', style: TextStyle(color: AppColors.textGray)),
              ),
            )
          else
            ...projects.map((project) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _RecentProjectCard(project: project),
                )),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gugakify 사용방법'),
        content: const Text('프로젝트를 만들고 YouTube URL을 입력한 뒤 국악 음원과 전통 MV 생성 흐름을 따라가면 됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('닫기')),
        ],
      ),
    );
  }

  void _showDemo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gugakify 데모', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('K-POP 음원이 국악 스타일 음원과 전통 MV로 변환되는 예시입니다.'),
              const SizedBox(height: 16),
              const DemoVideoPlayer(),
              const SizedBox(height: 12),
              const DemoAudioPlayer(),
              const SizedBox(height: 18),
              PrimaryLavenderButton(label: '닫기', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentProjectCard extends StatelessWidget {
  const _RecentProjectCard({required this.project});

  final RecentProject project;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProjectProvider>();
    final activeStep = _activeStep(project.status);
    final completed = project.status == 'completed';
    return GrayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.projectName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(project.currentStep, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                Expanded(
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: i <= activeStep ? AppColors.primaryPurple : AppColors.disabledGray,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                if (i < 3) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 7),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('준비', style: TextStyle(fontSize: 11)),
              Text('음원 생성', style: TextStyle(fontSize: 11)),
              Text('MV 생성', style: TextStyle(fontSize: 11)),
              Text('완료', style: TextStyle(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: SecondaryOutlineButton(
                  label: '이어하기',
                  onPressed: completed
                      ? null
                      : () {
                          provider.selectRecentProject(project);
                          context.go(_continuePath(project.status));
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryLavenderButton(
                  label: '결과 보기',
                  onPressed: completed
                      ? () {
                          provider.selectRecentProject(project);
                          context.go('/result');
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

  int _activeStep(String status) {
    switch (status) {
      case 'audio_processing':
      case 'audio_completed':
        return 1;
      case 'mv_setting':
      case 'mv_processing':
        return 2;
      case 'completed':
        return 3;
      case 'preparing':
      case 'audio_setting':
      default:
        return 0;
    }
  }

  String _continuePath(String status) {
    switch (status) {
      case 'audio_setting':
        return '/audio/settings';
      case 'audio_processing':
        return '/audio/processing';
      case 'audio_completed':
        return '/audio/result';
      case 'mv_setting':
        return '/mv/settings';
      case 'mv_processing':
        return '/mv/processing';
      case 'completed':
        return '/result';
      case 'preparing':
      default:
        return '/upload';
    }
  }
}
