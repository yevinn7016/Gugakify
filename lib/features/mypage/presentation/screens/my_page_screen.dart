import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/flow_action_button.dart';
import '../../../../shared/widgets/gray_card.dart';
import '../../../../shared/widgets/gugak_header.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/option_chip_button.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String _filter = '전체';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final projects = _filtered(projectProvider.recentProjects);
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(title: '마이페이지', onBack: () => context.go('/home')),
          const SizedBox(height: 16),
          const Text('닉네임', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          GrayCard(child: Text(auth.nickname ?? 'user_001')),
          const SizedBox(height: 12),
          const Text('이메일', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          GrayCard(child: Text(auth.email ?? 'user001@gmail.com')),
          const SizedBox(height: 16),
          FlowActionButton(
            label: '로그아웃',
            primary: false,
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/');
            },
          ),
          const SizedBox(height: 28),
          const Text('프로젝트 보관함', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['전체', '변환 중', '완료', '실패', '즐겨찾기']
                .map((filter) => OptionChipButton(
                      label: filter,
                      selected: _filter == filter,
                      onTap: () => setState(() => _filter = filter),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty)
            const GrayCard(child: Center(child: Text('프로젝트가 없습니다.', style: TextStyle(color: AppColors.textGray))))
          else
            ...projects.map(
              (project) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ArchiveCard(project: project, provider: projectProvider),
              ),
            ),
        ],
      ),
    );
  }

  List<RecentProject> _filtered(List<RecentProject> projects) {
    switch (_filter) {
      case '변환 중':
        return projects.where((project) => !project.isCompleted && project.status != 'failed').toList();
      case '완료':
        return projects.where((project) => project.isCompleted).toList();
      case '실패':
        return projects.where((project) => project.status == 'failed').toList();
      case '즐겨찾기':
        return projects.where((project) => project.isFavorite).toList();
      case '전체':
      default:
        return projects;
    }
  }
}

class _ArchiveCard extends StatelessWidget {
  const _ArchiveCard({required this.project, required this.provider});

  final RecentProject project;
  final ProjectProvider provider;

  @override
  Widget build(BuildContext context) {
    return GrayCard(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(project.isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
                  color: AppColors.primaryPurple,
                  onPressed: () => provider.toggleFavorite(project.id),
                ),
              ),
              Expanded(
                child: Text(
                  project.projectName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => provider.deleteProject(project.id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 118,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.music_video_rounded, size: 42, color: AppColors.primaryPurple),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('상태: ${project.currentStep}', maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text('${(project.progress * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: project.progress.clamp(0, 1), minHeight: 7),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('스타일: ${project.visualStyle ?? '미선택'} · ${project.aspectRatio ?? '미선택'}'),
          ),
        ],
      ),
    );
  }
}
