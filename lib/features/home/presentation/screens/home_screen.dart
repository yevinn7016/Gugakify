import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/demo_media_players.dart';
import '../../../../shared/widgets/gray_card.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/primary_lavender_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectProvider>().recentProjects;
    final auth = context.watch<AuthProvider>();
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
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Expanded(child: SizedBox.shrink()),
                if (!auth.isGuest)
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
          const SizedBox(height: 38),
          const Text(
            '음악을 AI가 음원을 분석하고',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '국악 스타일로 변환해요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 52),
          Row(
            children: [
              Expanded(
                child: PrimaryLavenderButton(
                  label: '새 프로젝트 만들기',
                  onPressed: () {
                    context.read<ProjectProvider>().resetCurrentProject();
                    context.go('/upload');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SecondaryOutlineButton(
                  label: '데모 보기',
                  onPressed: () => _showDemo(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 38),
          Container(height: 1, color: AppColors.primaryPurple),
          const SizedBox(height: 34),
          const Text(
            '최근 프로젝트',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 30),
          if (auth.isGuest)
            _GuestProjectPrompt(
              onLogin: () {
                context.read<AuthProvider>().logout();
                context.go('/');
              },
            )
          else if (projects.isEmpty)
            const GrayCard(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 38),
              child: Center(
                child: Text(
                  '아직 생성된 프로젝트가 없습니다.',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            )
          else
            ...projects.map(
              (project) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _RecentProjectCard(project: project),
              ),
            ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '서비스 소개',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '닫기',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _HelpCard(
                title: 'Gugakify란?',
                body:
                    'K-POP 또는 POP 음원을 AI가 분석하여 국악 스타일 음원으로 변환하고, 장단과 에너지 변화에 반응하는 전통 MV까지 생성해주는 서비스입니다. 원곡의 분위기를 유지하면서도 국악 악기, 장단, 전통 시각 효과를 적용해 새로운 형태의 콘텐츠로 재해석합니다.',
              ),
              const SizedBox(height: 12),
              const _HelpCard(
                title: '무엇을 만들 수 있나요?',
                bullets: [
                  '원곡의 멜로디와 보컬 유지 여부를 선택한 국악 편곡 음원',
                  '장구, 가야금, 해금 등 전통 악기 기반의 사운드',
                  '장단, BPM, 곡 에너지에 맞춰 움직이는 전통 MV',
                  '완성 후 영상과 음원을 함께 확인하는 최종 결과',
                ],
              ),
              const SizedBox(height: 12),
              const _HelpCard(
                title: '서비스 사용 방법',
                bullets: [
                  '1. 홈 화면에서 새 프로젝트 만들기를 누릅니다.',
                  '2. 프로젝트 이름을 입력하고, 필요하면 음원 링크를 입력합니다.',
                  '3. 원곡 멜로디 유지 여부와 보컬 유지 여부를 선택합니다.',
                  '4. 국악 스타일 음원 변환을 시작하고 진행률을 확인합니다.',
                  '5. 변환된 음원을 재생하고 요약 정보를 확인합니다.',
                  '6. 원하는 경우 전통 MV 생성 설정을 선택합니다.',
                  '7. MV 생성이 완료되면 최종 결과 화면에서 영상과 음원을 함께 확인합니다.',
                ],
              ),
              const SizedBox(height: 18),
              PrimaryLavenderButton(
                label: '닫기',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
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
              const Text(
                'Gugakify 데모',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text('K-POP 음원이 국악 스타일 음원과 전통 MV로 변환되는 예시입니다.'),
              const SizedBox(height: 16),
              const DemoVideoPlayer(),
              const SizedBox(height: 12),
              const DemoAudioPlayer(),
              const SizedBox(height: 18),
              PrimaryLavenderButton(
                label: '닫기',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestProjectPrompt extends StatelessWidget {
  const _GuestProjectPrompt({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return GrayCard(
      color: Colors.white.withValues(alpha: 0.9),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.archive_outlined,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '로그인하면 프로젝트를 저장할 수 있어요',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 9),
          const Text(
            '생성한 국악 음원과 전통 MV를 보관함에서 다시 확인하려면 로그인이 필요합니다.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          PrimaryLavenderButton(label: '로그인하기', onPressed: onLogin),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.title, this.body, this.bullets = const []});

  final String title;
  final String? body;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return GrayCard(
      color: Colors.white.withValues(alpha: 0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (body != null)
            Text(body!, style: const TextStyle(height: 1.55, fontSize: 14))
          else
            ...bullets.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  item,
                  style: const TextStyle(height: 1.45, fontSize: 14),
                ),
              ),
            ),
        ],
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
    final activeStep = _activeStep(project);
    final completed = project.isCompleted;
    return GrayCard(
      padding: const EdgeInsets.fromLTRB(25, 22, 25, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.projectName,
            style: const TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project.resultType == 'audioWithMv' ? 'MV 생성 완료' : '국악 음원 완료',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 34),
          _ProjectTimeline(activeStep: activeStep),
          const SizedBox(height: 22),
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
                          context.go(
                            project.resultType == 'audioWithMv'
                                ? '/result'
                                : '/audio/result',
                          );
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

  int _activeStep(RecentProject project) {
    if (project.resultType == 'audioWithMv' || project.status == 'completed') {
      return 3;
    }
    if (project.resultType == 'audioOnly') {
      return 1;
    }
    switch (project.status) {
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

class _ProjectTimeline extends StatelessWidget {
  const _ProjectTimeline({required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['준비', '음원 생성', 'MV 생성', '완료'];
    return Column(
      children: [
        SizedBox(
          height: 22,
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: i <= activeStep
                        ? AppColors.primaryPurple
                        : AppColors.lightPurple,
                    shape: BoxShape.circle,
                  ),
                ),
                if (i < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i < activeStep
                          ? AppColors.primaryPurple
                          : AppColors.lightPurple,
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in labels)
              SizedBox(
                width: 56,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
