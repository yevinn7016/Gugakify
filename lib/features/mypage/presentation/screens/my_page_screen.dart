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
    if (auth.isGuest) {
      return GugakifyAppScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GugakHeader(title: '마이페이지', onBack: () => context.go('/home')),
            const SizedBox(height: 80),
            const GrayCard(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 34),
              child: Center(child: Text('비회원은 마이페이지를 사용할 수 없습니다.')),
            ),
          ],
        ),
      );
    }
    return GugakifyAppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GugakHeader(title: '마이페이지', onBack: () => context.go('/home')),
          const SizedBox(height: 18),
          const Text('닉네임', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          GrayCard(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Text(auth.userName),
          ),
          const SizedBox(height: 26),
          const Text('이메일', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          GrayCard(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Text(auth.userEmail),
          ),
          const SizedBox(height: 42),
          SizedBox(
            height: 45,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.cardGrayAlt,
                foregroundColor: AppColors.textBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 56),
          const Text(
            '프로젝트 보관함',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['전체', '변환 중', '완료', '실패', '즐겨찾기']
                .map(
                  (filter) => OptionChipButton(
                    label: filter,
                    selected: _filter == filter,
                    onTap: () => setState(() => _filter = filter),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty)
            const GrayCard(
              child: Center(
                child: Text(
                  '프로젝트가 없습니다.',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            )
          else
            ...projects.map(
              (project) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ArchiveCard(
                  project: project,
                  provider: projectProvider,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<RecentProject> _filtered(List<RecentProject> projects) {
    switch (_filter) {
      case '변환 중':
        return projects
            .where(
              (project) => !project.isCompleted && project.status != 'failed',
            )
            .toList();
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
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    project.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                  ),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => _confirmDelete(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: 208,
            height: 140,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.paleLavender, AppColors.lightPurple],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.music_video_rounded,
              size: 44,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 26),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '상태 - ${_statusLabel(project)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '결과 - ${project.resultType == 'audioWithMv' ? '음원 + MV' : '음원만 생성됨'}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '생성일 - ${_dateLabel(project.createdAt)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '스타일 - ${_styleLabel(project.visualStyle)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          FlowActionButton(
            label: '결과 보기',
            onPressed: () {
              provider.selectRecentProject(project);
              context.go(
                project.resultType == 'audioWithMv'
                    ? '/result'
                    : '/audio/result',
              );
            },
          ),
        ],
      ),
    );
  }

  String _statusLabel(RecentProject project) {
    if (project.resultType == 'audioWithMv') {
      return 'MV 생성 완료';
    }
    if (project.resultType == 'audioOnly') {
      return '국악 음원 완료';
    }
    return project.currentStep;
  }

  String _dateLabel(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _styleLabel(String? value) {
    switch (value) {
      case 'sumukhwa':
        return '수묵화';
      case 'chaesaekhwa':
        return '채색화';
      case 'sumukh_damchae':
        return '수묵담채화';
      case 'palace_painting':
        return '궁중채색화';
      case 'landscape':
        return '산수화';
      case null:
        return '미선택';
      default:
        return value;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backgroundAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('이 프로젝트를 삭제할까요?'),
        content: const Text('삭제한 프로젝트는 보관함에서 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              provider.deleteProject(project.id);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('프로젝트가 삭제되었습니다.')));
            },
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
