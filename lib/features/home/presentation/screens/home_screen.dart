import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/app_state/project_state.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/demo_media_players.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/primary_lavender_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectProvider>().recentProjects;
    final auth = context.watch<AuthProvider>();
    return GugakifyAppScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          const Positioned.fill(child: _HomeAtmosphere()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(
                showMyPage: !auth.isGuest,
                onMyPage: () => context.go('/mypage'),
                onHelp: () => _showHelp(context),
              ),
              const SizedBox(height: 22),
              _HomeHeroCard(
                onStart: () {
                  context.read<ProjectProvider>().resetCurrentProject();
                  context.go('/upload');
                },
                onDemo: () => _showDemo(context),
              ),
              const SizedBox(height: 30),
              const _SectionHeader(),
              const SizedBox(height: 16),
              if (auth.isGuest)
                _GuestProjectPrompt(
                  onLogin: () {
                    context.read<AuthProvider>().logout();
                    context.go('/');
                  },
                )
              else if (projects.isEmpty)
                const _EmptyProjectCard()
              else
                ...projects.map(
                  (project) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _RecentProjectCard(project: project),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.86,
        minChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (context, scrollController) => _ServiceGuideSheet(
          scrollController: scrollController,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showDemo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const Text(
                'Gugakify 데모',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'K-POP 음원이 국악 스타일 음원과 전통 MV로 변환되는 예시입니다.',
                style: TextStyle(color: AppColors.textMuted, height: 1.45),
              ),
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

class _HomeAtmosphere extends StatelessWidget {
  const _HomeAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/intro_hero.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
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
            top: 118,
            right: -38,
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.paleLavender.withValues(alpha: 0.45),
              ),
            ),
          ),
          Positioned(
            top: 310,
            left: -42,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.lightPurple.withValues(alpha: 0.5),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.showMyPage,
    required this.onMyPage,
    required this.onHelp,
  });

  final bool showMyPage;
  final VoidCallback onMyPage;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/icons/gugakify_wordmark.png',
            width: 122,
            errorBuilder: (_, error, stackTrace) => const Text(
              'Gugakify',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showMyPage) ...[
                _HeaderIconButton(
                  tooltip: '마이페이지',
                  icon: Icons.person_outline_rounded,
                  onPressed: onMyPage,
                ),
                const SizedBox(width: 8),
              ],
              _HeaderIconButton(
                tooltip: '서비스 안내',
                icon: Icons.help_outline_rounded,
                onPressed: onHelp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.72),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderSoft.withValues(alpha: 0.9),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          color: AppColors.primaryPurple,
          icon: Icon(icon, size: 21),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({required this.onStart, required this.onDemo});

  final VoidCallback onStart;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _HeroInkWash()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.paleLavender.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.lightPurple.withValues(alpha: 0.8),
                  ),
                ),
                child: const Text(
                  'AI Gugak Remix',
                  style: TextStyle(
                    color: AppColors.deepInkPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'K-POP을\n국악과 전통 MV로',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  height: 1.22,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '익숙한 음악을 국악 장단과 전통 미학으로 새롭게 재해석해보세요.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              PrimaryLavenderButton(
                label: '새 변환 시작',
                icon: const Icon(Icons.auto_awesome_rounded, size: 19),
                onPressed: onStart,
              ),
              const SizedBox(height: 10),
              SecondaryOutlineButton(
                label: '데모 보기',
                icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                onPressed: onDemo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroInkWash extends StatelessWidget {
  const _HeroInkWash();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: CustomPaint(
        painter: _HeroInkPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HeroInkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final moonPaint = Paint()
      ..color = AppColors.lightPurple.withValues(alpha: 0.34);
    canvas.drawCircle(Offset(size.width - 44, 48), 34, moonPaint);

    final cloudPaint = Paint()
      ..color = AppColors.primaryPurple.withValues(alpha: 0.1)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final cloud = Path()
      ..moveTo(size.width - 118, 92)
      ..cubicTo(size.width - 84, 68, size.width - 70, 112, size.width - 36, 88)
      ..cubicTo(size.width - 20, 78, size.width - 8, 82, size.width + 8, 92);
    canvas.drawPath(cloud, cloudPaint);

    final wavePaint = Paint()
      ..color = AppColors.deepInkPurple.withValues(alpha: 0.12)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = size.height - 42 + i * 12;
      final wave = Path()
        ..moveTo(size.width * 0.25, y)
        ..cubicTo(
          size.width * 0.43,
          y - 24,
          size.width * 0.62,
          y + 22,
          size.width * 0.84,
          y - 6,
        )
        ..cubicTo(size.width * 0.94, y - 18, size.width, y - 4, size.width, y);
      canvas.drawPath(wave, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroInkPainter oldDelegate) => false;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '최근 프로젝트',
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
        const SizedBox(height: 5),
        const Text(
          '최근 작업을 이어서 진행해보세요',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ProjectIconBadge extends StatelessWidget {
  const _ProjectIconBadge({required this.icon, this.size = 48});

  final IconData icon;
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
      child: Icon(icon, color: AppColors.primaryPurple, size: size * 0.48),
    );
  }
}

class _RecentCardInk extends StatelessWidget {
  const _RecentCardInk();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -24,
      right: -20,
      child: IgnorePointer(
        child: Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.lightPurple.withValues(alpha: 0.24),
                AppColors.lightPurple.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyProjectCard extends StatelessWidget {
  const _EmptyProjectCard();

  @override
  Widget build(BuildContext context) {
    return _KoreanSurface(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        children: [
          const _ProjectIconBadge(icon: Icons.auto_awesome_rounded, size: 50),
          const SizedBox(height: 16),
          const Text(
            '아직 생성된 프로젝트가 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '새 변환을 시작하면 이곳에서 진행 상황을 이어볼 수 있어요.',
            textAlign: TextAlign.center,
            style: TextStyle(
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

class _KoreanSurface extends StatelessWidget {
  const _KoreanSurface({
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

class _GuestProjectPrompt extends StatelessWidget {
  const _GuestProjectPrompt({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return _KoreanSurface(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ProjectIconBadge(icon: Icons.lock_outline_rounded, size: 46),
          const SizedBox(height: 16),
          const Text(
            '로그인하면 프로젝트를 저장할 수 있어요',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
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
          _ProjectCardButton(
            label: '로그인하기',
            icon: Icons.person_outline_rounded,
            filled: true,
            onPressed: onLogin,
          ),
        ],
      ),
    );
  }
}

class _ServiceGuideSheet extends StatelessWidget {
  const _ServiceGuideSheet({
    required this.scrollController,
    required this.onClose,
  });

  final ScrollController scrollController;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: AppColors.borderSoft.withValues(alpha: 0.9)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepInkPurple.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _ServiceGuideAtmosphere()),
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 46,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.lightPurple,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ServiceGuideHero(onClose: onClose),
                    const SizedBox(height: 16),
                    const _ServiceSectionTitle(title: '핵심 기능'),
                    const SizedBox(height: 10),
                    const _FeatureCard(
                      icon: Icons.graphic_eq_rounded,
                      title: '국악 스타일 변환',
                      body: '음악의 BPM, 분위기, 멜로디를 분석해 국악 장단과 악기 구성으로 재해석해요.',
                    ),
                    const SizedBox(height: 12),
                    const _FeatureCard(
                      icon: Icons.movie_creation_outlined,
                      title: '전통 MV 생성',
                      body: '수묵화, 채색화, 산수화 등 한국적 미감의 영상으로 음악을 시각화해요.',
                    ),
                    const SizedBox(height: 12),
                    const _FeatureCard(
                      icon: Icons.auto_awesome_rounded,
                      title: '장단 기반 연출',
                      body: '장구 타격, 빠른 BPM, 클라이맥스에 맞춰 먹 번짐과 붓 획 효과가 변화해요.',
                    ),
                    const SizedBox(height: 22),
                    const _ServiceSectionTitle(title: '이용 방법'),
                    const SizedBox(height: 12),
                    const _GuideStepper(),
                    const SizedBox(height: 16),
                    const _CopyrightNoticeCard(),
                    const SizedBox(height: 20),
                    PrimaryLavenderButton(label: '닫기', onPressed: onClose),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceGuideAtmosphere extends StatelessWidget {
  const _ServiceGuideAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.055,
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
                color: AppColors.background.withValues(alpha: 0.92),
              ),
            ),
          ),
          Positioned(
            top: 82,
            right: -30,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.paleLavender.withValues(alpha: 0.48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceGuideHero extends StatelessWidget {
  const _ServiceGuideHero({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return _GuideSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 20),
      child: Stack(
        children: [
          const Positioned.fill(child: _GuideInkCurve()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GuideIcon(icon: Icons.music_note_rounded, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _GuideBadge(label: 'About Gugakify'),
                        const SizedBox(height: 10),
                        const Text(
                          'Gugakify는 어떤 서비스인가요?',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textBlack,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            height: 1.24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _GuideCloseButton(onClose: onClose),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'AI가 K-POP/POP 음원을 분석해 국악 장단과 악기 구성으로 재해석하고, 전통 미학 기반 MV까지 생성하는 서비스입니다.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _GuideSurface(
      padding: const EdgeInsets.all(16),
      radius: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuideIcon(icon: icon, size: 42),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStepper extends StatelessWidget {
  const _GuideStepper();

  static const _steps = [
    ('새 변환 시작', '프로젝트 이름과 YouTube URL을 입력해요.'),
    ('국악 변환 옵션 선택', '선율 유지, 보컬 유지, 장단, 악기, 분위기를 선택해요.'),
    ('국악 음원 생성', 'AI가 음원을 분석하고 국악 스타일로 변환해요.'),
    ('전통 MV 생성', '수묵화/채색화/산수화 스타일과 영상 비율을 선택해요.'),
    ('결과 확인', '완성된 국악 음원과 전통 MV를 확인하고 보관함에서 다시 볼 수 있어요.'),
  ];

  @override
  Widget build(BuildContext context) {
    return _GuideSurface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      radius: 20,
      child: Column(
        children: [
          for (var i = 0; i < _steps.length; i++)
            _GuideStepItem(
              number: i + 1,
              title: _steps[i].$1,
              body: _steps[i].$2,
              isLast: i == _steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _GuideStepItem extends StatelessWidget {
  const _GuideStepItem({
    required this.number,
    required this.title,
    required this.body,
    required this.isLast,
  });

  final int number;
  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.paleLavender,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  color: AppColors.deepInkPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: AppColors.lightPurple.withValues(alpha: 0.62),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CopyrightNoticeCard extends StatelessWidget {
  const _CopyrightNoticeCard();

  @override
  Widget build(BuildContext context) {
    return _GuideSurface(
      padding: const EdgeInsets.all(16),
      radius: 20,
      color: AppColors.paleLavender.withValues(alpha: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _GuideIcon(icon: Icons.shield_outlined, size: 40),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이용 전 확인해주세요',
                  style: TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                _GuideBullet(text: '본인이 보유하거나 이용 권한이 있는 음원만 변환할 수 있어요.'),
                _GuideBullet(text: '타인의 저작물을 무단으로 업로드하거나 결과물을 배포해서는 안 됩니다.'),
                _GuideBullet(text: '현재 결과물은 대회 시연 및 개인 학습 목적의 mock 결과로 사용됩니다.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideBullet extends StatelessWidget {
  const _GuideBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        '• $text',
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );
  }
}

class _ServiceSectionTitle extends StatelessWidget {
  const _ServiceSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textBlack,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 44,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.4),
                    AppColors.lightPurple.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideIcon extends StatelessWidget {
  const _GuideIcon({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.paleLavender,
        borderRadius: BorderRadius.circular(size * 0.36),
        border: Border.all(
          color: AppColors.lightPurple.withValues(alpha: 0.72),
        ),
      ),
      child: Icon(icon, color: AppColors.primaryPurple, size: size * 0.48),
    );
  }
}

class _GuideBadge extends StatelessWidget {
  const _GuideBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paleLavender,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightPurple.withValues(alpha: 0.8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.deepInkPurple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GuideCloseButton extends StatelessWidget {
  const _GuideCloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt.withValues(alpha: 0.82),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderSoft.withValues(alpha: 0.9),
          ),
        ),
        child: IconButton(
          tooltip: '닫기',
          padding: EdgeInsets.zero,
          color: AppColors.primaryPurple,
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: onClose,
        ),
      ),
    );
  }
}

class _GuideInkCurve extends StatelessWidget {
  const _GuideInkCurve();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GuideInkPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GuideInkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = AppColors.lightPurple.withValues(alpha: 0.22);
    canvas.drawCircle(Offset(size.width - 28, 36), 34, circlePaint);

    final linePaint = Paint()
      ..color = AppColors.deepInkPurple.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.44, size.height - 20)
      ..cubicTo(
        size.width * 0.6,
        size.height - 54,
        size.width * 0.78,
        size.height + 4,
        size.width + 8,
        size.height - 32,
      );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _GuideInkPainter oldDelegate) => false;
}

class _GuideSurface extends StatelessWidget {
  const _GuideSurface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.backgroundAlt.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepInkPurple.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RecentProjectCard extends StatelessWidget {
  const _RecentProjectCard({required this.project});

  final RecentProject project;

  bool get _isFullyDone =>
      project.resultType == 'audioWithMv' ||
      (project.hasAudio && project.hasMv) ||
      project.status == 'completed';

  // "음원만 생성된" 상태: 오디오 변환은 끝내고 홈으로 돌아온 프로젝트.
  // status가 mv_setting/mv_processing으로 이미 진행 중인 프로젝트는
  // hasAudio && !hasMv 이더라도 여기 포함하지 않고 "진행 중"으로 취급한다.
  bool get _isAudioOnlyDone =>
      !_isFullyDone &&
      project.isCompleted &&
      (project.resultType == 'audioOnly' || project.hasAudio);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProjectProvider>();
    final activeStep = _activeStep();
    final canViewResult = _isFullyDone || _isAudioOnlyDone;
    return _KoreanSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 21),
      child: Stack(
        children: [
          const _RecentCardInk(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProjectIconBadge(
                    icon: _isFullyDone
                        ? Icons.movie_creation_outlined
                        : Icons.music_note_rounded,
                    size: 46,
                  ),
                  const SizedBox(width: 13),
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
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _createdDateLabel(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusBadge(label: _statusBadgeLabel()),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.borderSoft.withValues(alpha: 0.78),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isFullyDone
                          ? Icons.check_circle_outline_rounded
                          : Icons.spa_outlined,
                      color: AppColors.primaryPurple,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _statusLabel(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 19),
              _ProjectTimeline(activeStep: activeStep),
              const SizedBox(height: 20),
              _ProjectActionArea(
                isFullyDone: _isFullyDone,
                isAudioOnlyDone: _isAudioOnlyDone,
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
    if (_isFullyDone) {
      return 'MV 생성 완료';
    }
    if (_isAudioOnlyDone) {
      return '국악 음원 완료 · MV 생성 가능';
    }
    switch (project.status) {
      case 'preparing':
        return '프로젝트 준비 중';
      case 'audio_setting':
        return '음원 변환 설정 중';
      case 'audio_processing':
        return '음원 변환 중';
      case 'audio_completed':
        return '국악 음원 완료 · 결과 확인 가능';
      case 'mv_setting':
        return '전통 MV 설정 중';
      case 'mv_processing':
        return '전통 MV 생성 중';
      default:
        return '${project.currentStep} 진행 중';
    }
  }

  String _statusBadgeLabel() {
    if (_isFullyDone) {
      return '완료';
    }
    if (_isAudioOnlyDone) {
      return '음원 완료';
    }
    if (project.status == 'preparing' || project.status == 'audio_setting') {
      return '준비 중';
    }
    return '진행 중';
  }

  String _createdDateLabel() {
    final year = project.createdAt.year.toString().padLeft(4, '0');
    final month = project.createdAt.month.toString().padLeft(2, '0');
    final day = project.createdAt.day.toString().padLeft(2, '0');
    return '$year.$month.$day 생성';
  }

  int _activeStep() {
    if (_isFullyDone) {
      return 3;
    }
    if (_isAudioOnlyDone) {
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
}

class _ProjectActionArea extends StatelessWidget {
  const _ProjectActionArea({
    required this.isFullyDone,
    required this.isAudioOnlyDone,
    required this.onContinue,
    required this.onViewResult,
  });

  final bool isFullyDone;
  final bool isAudioOnlyDone;
  final VoidCallback? onContinue;
  final VoidCallback? onViewResult;

  @override
  Widget build(BuildContext context) {
    if (isFullyDone) {
      return _ProjectCardButton(
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
            child: _ProjectCardButton(
              label: '음원 보기',
              icon: Icons.graphic_eq_rounded,
              filled: false,
              onPressed: onViewResult,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ProjectCardButton(
              label: 'MV 만들기',
              icon: Icons.movie_filter_outlined,
              filled: true,
              onPressed: onContinue,
            ),
          ),
        ],
      );
    }

    return _ProjectCardButton(
      label: '이어하기',
      icon: Icons.arrow_forward_rounded,
      filled: true,
      onPressed: onContinue,
    );
  }
}

class _ProjectCardButton extends StatelessWidget {
  const _ProjectCardButton({
    required this.label,
    required this.onPressed,
    required this.filled,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final IconData? icon;

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
                child: _ProjectButtonLabel(label: label, icon: icon),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: _buttonStyle(
                foregroundColor: foregroundColor,
                backgroundColor: enabled
                    ? AppColors.backgroundAlt.withValues(alpha: 0.85)
                    : AppColors.disabledGray,
                borderColor: enabled
                    ? AppColors.lightPurple.withValues(alpha: 0.9)
                    : AppColors.disabledGray,
              ),
              child: _ProjectButtonLabel(label: label, icon: icon),
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

class _ProjectButtonLabel extends StatelessWidget {
  const _ProjectButtonLabel({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final reserved = icon == null ? 0.0 : 26.0;
        final labelMaxWidth = (constraints.maxWidth - reserved).clamp(
          0.0,
          constraints.maxWidth,
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 7),
            ],
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paleLavender,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightPurple.withValues(alpha: 0.8)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.deepInkPurple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProjectTimeline extends StatelessWidget {
  const _ProjectTimeline({required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['준비', '음원 생성', 'MV 생성', '완료'];
    final clampedStep = activeStep.clamp(0, labels.length - 1).toInt();
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              _TimelineDot(isActive: i <= clampedStep, isDone: i == 3),
              if (i != labels.length - 1)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: i < clampedStep
                          ? AppColors.primaryPurple.withValues(alpha: 0.84)
                          : AppColors.borderSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: i <= clampedStep
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: i <= clampedStep
                        ? AppColors.deepInkPurple
                        : AppColors.textMuted,
                    height: 1.25,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.isActive, required this.isDone});

  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryPurple : AppColors.backgroundAlt,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.primaryPurple : AppColors.lightPurple,
          width: 1.4,
        ),
      ),
      child: isActive && isDone
          ? const Icon(Icons.check_rounded, size: 10, color: AppColors.white)
          : null,
    );
  }
}
