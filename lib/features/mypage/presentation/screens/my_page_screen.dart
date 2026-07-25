import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';

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
    final allProjects = projectProvider.recentProjects;
    final projects = _filtered(allProjects);

    return GugakifyAppScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          const Positioned.fill(child: _MyPageAtmosphere()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MyPageHeader(onBack: () => context.go('/home')),
              const SizedBox(height: 22),
              if (auth.isGuest)
                const _GuestBlockedCard()
              else ...[
                _ProfileCard(
                  userName: auth.userName,
                  userEmail: auth.userEmail,
                  onLogout: () {
                    context.read<AuthProvider>().logout();
                    context.go('/');
                  },
                ),
                const SizedBox(height: 14),
                _ArchiveSummary(projects: allProjects),
                const SizedBox(height: 30),
                const _ArchiveSectionHeader(),
                const SizedBox(height: 15),
                _FilterChips(
                  selected: _filter,
                  onSelected: (filter) => setState(() => _filter = filter),
                ),
                const SizedBox(height: 18),
                if (projects.isEmpty)
                  _ArchiveEmptyState(filter: _filter)
                else
                  ...projects.map(
                    (project) => Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _ArchiveCard(
                        project: project,
                        provider: projectProvider,
                      ),
                    ),
                  ),
              ],
            ],
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

class _MyPageAtmosphere extends StatelessWidget {
  const _MyPageAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                'assets/images/intro_hero.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.9),
              ),
            ),
          ),
          Positioned(
            top: 96,
            right: -42,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.paleLavender.withValues(alpha: 0.42),
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            left: -38,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.lightPurple.withValues(alpha: 0.4),
                  width: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPageHeader extends StatelessWidget {
  const _MyPageHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          _CircleIconButton(
            tooltip: '홈으로 돌아가기',
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              '마이페이지',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Image.asset(
            'assets/icons/gugakify_wordmark.png',
            width: 86,
            errorBuilder: (_, error, stackTrace) => const SizedBox(width: 86),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _HanjiSurface(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProfileAvatar(),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SoftBadge(label: 'Google 로그인'),
                    const SizedBox(height: 9),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _CompactOutlineButton(
            label: '로그아웃',
            icon: Icons.logout_rounded,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.paleLavender,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lightPurple),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: AppColors.primaryPurple,
        size: 30,
      ),
    );
  }
}

class _ArchiveSummary extends StatelessWidget {
  const _ArchiveSummary({required this.projects});

  final List<RecentProject> projects;

  @override
  Widget build(BuildContext context) {
    final completedCount = projects
        .where((project) => project.isCompleted)
        .length;
    final favoriteCount = projects
        .where((project) => project.isFavorite)
        .length;
    return Row(
      children: [
        Expanded(
          child: _StatTile(label: '전체', value: projects.length.toString()),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(label: '완료', value: completedCount.toString()),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(label: '즐겨찾기', value: favoriteCount.toString()),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.deepInkPurple,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchiveSectionHeader extends StatelessWidget {
  const _ArchiveSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '프로젝트 보관함',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 58,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryPurple.withValues(alpha: 0.42),
                        AppColors.lightPurple.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          '생성한 국악 음원과 전통 MV를 다시 확인할 수 있어요.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  static const _filters = ['전체', '변환 중', '완료', '실패', '즐겨찾기'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _filters.length; i++) ...[
            _FilterChipButton(
              label: _filters[i],
              selected: selected == _filters[i],
              icon: _filters[i] == '즐겨찾기' ? Icons.star_rounded : null,
              onTap: () => onSelected(_filters[i]),
            ),
            if (i != _filters.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.paleLavender : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple.withValues(alpha: 0.34)
                : AppColors.borderSoft,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? AppColors.primaryPurple : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.deepInkPurple : AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  const _ArchiveCard({required this.project, required this.provider});

  final RecentProject project;
  final ProjectProvider provider;

  bool get _isFullyDone =>
      project.resultType == 'audioWithMv' ||
      (project.hasAudio && project.hasMv) ||
      project.status == 'completed';

  bool get _isAudioOnlyDone =>
      !_isFullyDone &&
      project.isCompleted &&
      (project.resultType == 'audioOnly' || project.hasAudio);

  @override
  Widget build(BuildContext context) {
    final canViewResult = _isFullyDone || _isAudioOnlyDone;
    return _HanjiSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 19),
      child: Stack(
        children: [
          const _CardInkWash(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ArchiveIcon(isVideo: _isFullyDone),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.projectName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            _SoftBadge(label: _statusLabel()),
                            if (project.hasAudio || _isAudioOnlyDone)
                              const _SoftBadge(label: '국악 음원'),
                            if (project.hasMv || _isFullyDone)
                              const _SoftBadge(label: '전통 MV'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    tooltip: project.isFavorite ? '즐겨찾기 해제' : '즐겨찾기',
                    icon: project.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    compact: true,
                    onPressed: () => provider.toggleFavorite(project.id),
                  ),
                  const SizedBox(width: 6),
                  _CircleIconButton(
                    tooltip: '삭제',
                    icon: Icons.close_rounded,
                    compact: true,
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProjectMetaPanel(
                dateLabel: _dateLabel(project.createdAt),
                currentStep: project.currentStep,
                detailLabel: _detailLabel(),
              ),
              const SizedBox(height: 17),
              _ArchiveActionArea(
                isFullyDone: _isFullyDone,
                isAudioOnlyDone: _isAudioOnlyDone,
                canViewResult: canViewResult,
                onContinue: _isFullyDone
                    ? null
                    : () {
                        provider.selectRecentProject(project);
                        context.go(_continuePath());
                      },
                onViewResult: canViewResult
                    ? () {
                        provider.selectRecentProject(project);
                        context.go(
                          project.resultType == 'audioWithMv' || project.hasMv
                              ? '/result'
                              : '/audio/result',
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel() {
    if (project.status == 'failed') {
      return '실패';
    }
    if (_isFullyDone) {
      return 'MV 생성 완료';
    }
    if (_isAudioOnlyDone) {
      return '국악 음원 완료';
    }
    return '변환 중';
  }

  String _detailLabel() {
    final parts = <String>[];
    final style = _styleLabel(project.visualStyle);
    if (style != null) {
      parts.add(style);
    }
    if (project.aspectRatio != null && project.aspectRatio!.isNotEmpty) {
      parts.add(project.aspectRatio!);
    }
    if (project.resultType == 'audioWithMv' || project.hasMv) {
      parts.add('음원 + MV');
    } else if (project.resultType == 'audioOnly' || project.hasAudio) {
      parts.add('음원만 생성됨');
    }
    return parts.isEmpty ? '세부 설정 미선택' : parts.join(' · ');
  }

  String _dateLabel(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day 생성';
  }

  String? _styleLabel(String? value) {
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
      case '':
        return null;
      default:
        return value;
    }
  }

  String _continuePath() {
    if (_isAudioOnlyDone) {
      return '/mv/settings';
    }
    switch (project.status) {
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

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _DeleteConfirmCard(
          onCancel: () => Navigator.of(dialogContext).pop(),
          onDelete: () {
            Navigator.of(dialogContext).pop();
            provider.deleteProject(project.id);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('프로젝트가 삭제되었습니다.')));
          },
        ),
      ),
    );
  }
}

class _ArchiveActionArea extends StatelessWidget {
  const _ArchiveActionArea({
    required this.isFullyDone,
    required this.isAudioOnlyDone,
    required this.canViewResult,
    required this.onContinue,
    required this.onViewResult,
  });

  final bool isFullyDone;
  final bool isAudioOnlyDone;
  final bool canViewResult;
  final VoidCallback? onContinue;
  final VoidCallback? onViewResult;

  @override
  Widget build(BuildContext context) {
    if (isFullyDone) {
      return _ArchiveButton(
        label: '결과 보기',
        icon: Icons.play_circle_outline_rounded,
        filled: true,
        onPressed: onViewResult,
      );
    }

    if (isAudioOnlyDone) {
      return Row(
        children: [
          Expanded(
            child: _ArchiveButton(
              label: '음원 보기',
              icon: Icons.graphic_eq_rounded,
              filled: false,
              onPressed: onViewResult,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ArchiveButton(
              label: 'MV 만들기',
              icon: Icons.movie_filter_outlined,
              filled: true,
              onPressed: onContinue,
            ),
          ),
        ],
      );
    }

    return _ArchiveButton(
      label: canViewResult ? '결과 보기' : '이어보기',
      icon: canViewResult
          ? Icons.play_circle_outline_rounded
          : Icons.arrow_forward_rounded,
      filled: true,
      onPressed: canViewResult ? onViewResult : onContinue,
    );
  }
}

class _ProjectMetaPanel extends StatelessWidget {
  const _ProjectMetaPanel({
    required this.dateLabel,
    required this.currentStep,
    required this.detailLabel,
  });

  final String dateLabel;
  final String currentStep;
  final String detailLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.78)),
      ),
      child: Column(
        children: [
          _MetaRow(icon: Icons.calendar_today_outlined, label: dateLabel),
          const SizedBox(height: 8),
          _MetaRow(icon: Icons.spa_outlined, label: '$currentStep 단계'),
          const SizedBox(height: 8),
          _MetaRow(icon: Icons.tune_rounded, label: detailLabel),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryPurple, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArchiveEmptyState extends StatelessWidget {
  const _ArchiveEmptyState({required this.filter});

  final String filter;

  @override
  Widget build(BuildContext context) {
    final title = switch (filter) {
      '즐겨찾기' => '즐겨찾기한 프로젝트가 없습니다.',
      '완료' => '완료된 프로젝트가 없습니다.',
      '변환 중' => '진행 중인 프로젝트가 없습니다.',
      '실패' => '실패한 프로젝트가 없습니다.',
      _ => '아직 저장된 프로젝트가 없습니다.',
    };
    final body = switch (filter) {
      '즐겨찾기' => '자주 확인할 프로젝트에 별표를 눌러보세요.',
      _ => '홈에서 새 변환을 시작하면 이곳에 보관됩니다.',
    };

    return _HanjiSurface(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        children: [
          const _ArchiveIcon(isVideo: false, size: 52),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestBlockedCard extends StatelessWidget {
  const _GuestBlockedCard();

  @override
  Widget build(BuildContext context) {
    return _HanjiSurface(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      child: Column(
        children: [
          const _ArchiveIcon(isVideo: false, size: 52),
          const SizedBox(height: 16),
          const Text(
            '비회원은 마이페이지를 사용할 수 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '프로젝트를 보관하려면 로그인 후 이용해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteConfirmCard extends StatelessWidget {
  const _DeleteConfirmCard({required this.onCancel, required this.onDelete});

  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _HanjiSurface(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECEC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE3C6C6)),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFB75A5A),
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '이 프로젝트를 삭제할까요?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '삭제한 프로젝트는 보관함에서 사라집니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ArchiveButton(
                  label: '취소',
                  icon: Icons.close_rounded,
                  filled: false,
                  onPressed: onCancel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _WarningButton(onPressed: onDelete)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WarningButton extends StatelessWidget {
  const _WarningButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFFFECEC),
          foregroundColor: const Color(0xFFB75A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE3C6C6)),
          ),
        ),
        child: const Text(
          '삭제',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ArchiveButton extends StatelessWidget {
  const _ArchiveButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final foregroundColor = enabled
        ? AppColors.deepInkPurple
        : AppColors.textGray;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: filled
          ? DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: enabled
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.lightPurple, AppColors.softPurple],
                      )
                    : null,
                color: enabled ? null : AppColors.disabledGray,
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: _buttonStyle(
                  foregroundColor: foregroundColor,
                  borderColor: Colors.transparent,
                ),
                child: _ButtonLabel(label: label, icon: icon),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: _buttonStyle(
                foregroundColor: foregroundColor,
                backgroundColor: enabled
                    ? AppColors.backgroundAlt.withValues(alpha: 0.86)
                    : AppColors.disabledGray,
                borderColor: enabled
                    ? AppColors.lightPurple.withValues(alpha: 0.9)
                    : AppColors.disabledGray,
              ),
              child: _ButtonLabel(label: label, icon: icon),
            ),
    );
  }

  ButtonStyle _buttonStyle({
    required Color foregroundColor,
    required Color borderColor,
    Color backgroundColor = Colors.transparent,
  }) {
    return ButtonStyle(
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.all(backgroundColor),
      foregroundColor: WidgetStateProperty.all(foregroundColor),
      overlayColor: WidgetStateProperty.all(
        AppColors.primaryPurple.withValues(alpha: 0.06),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 12),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}

class _CompactOutlineButton extends StatelessWidget {
  const _CompactOutlineButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 42,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 17),
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryPurple,
            backgroundColor: AppColors.backgroundAlt.withValues(alpha: 0.82),
            side: BorderSide(
              color: AppColors.lightPurple.withValues(alpha: 0.9),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelMaxWidth = (constraints.maxWidth - 27).clamp(
          0.0,
          constraints.maxWidth,
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 7),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: labelMaxWidth),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArchiveIcon extends StatelessWidget {
  const _ArchiveIcon({required this.isVideo, this.size = 46});

  final bool isVideo;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.paleLavender,
        borderRadius: BorderRadius.circular(size * 0.36),
        border: Border.all(color: AppColors.lightPurple.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        isVideo ? Icons.movie_creation_outlined : Icons.music_note_rounded,
        color: AppColors.primaryPurple,
        size: size * 0.48,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.compact = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 36.0 : 42.0;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt.withValues(alpha: 0.82),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderSoft.withValues(alpha: 0.9),
          ),
        ),
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          color: AppColors.primaryPurple,
          icon: Icon(icon, size: compact ? 20 : 21),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.paleLavender,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightPurple.withValues(alpha: 0.8)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.deepInkPurple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardInkWash extends StatelessWidget {
  const _CardInkWash();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -28,
      right: -24,
      child: IgnorePointer(
        child: Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.lightPurple.withValues(alpha: 0.22),
                AppColors.lightPurple.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HanjiSurface extends StatelessWidget {
  const _HanjiSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.055),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}
