import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/hanji_background.dart';
import '../../../../shared/widgets/mobile_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _enter(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    await action();
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      body: MobileShell(
        child: HanjiBackground(
          baseColor: AppColors.backgroundAlt,
          opacity: 0.03,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  AppColors.paleLavender.withValues(alpha: 0.55),
                  AppColors.backgroundAlt,
                ],
              ),
            ),
            child: Stack(
              children: [
                const Positioned(top: 12, right: -34, child: _MoonGlow()),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _MountainSilhouette(),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 72),
                      Image.asset(
                        'assets/icons/gugakify_logo_full.png',
                        width: 172,
                        errorBuilder: (_, error, stackTrace) => const Text(
                          'Gugakify',
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'AI로 재해석하는 국악 스타일 콘텐츠',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 54),
                      _LoginCard(
                        child: Column(
                          children: [
                            const Text(
                              '나만의 국악 스타일 변환을\n시작해보세요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textBlack,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 22),
                            _LoginButton(
                              label: '구글 로그인',
                              icon: SvgPicture.asset(
                                'assets/icons/google_logo.svg',
                                width: 20,
                                height: 20,
                                placeholderBuilder: (_) =>
                                    const Icon(Icons.g_mobiledata_rounded),
                              ),
                              onPressed: () =>
                                  _enter(context, auth.signInWithGoogle),
                            ),
                            const SizedBox(height: 12),
                            _LoginButton(
                              label: '비회원으로 둘러보기',
                              icon: const Icon(
                                Icons.person_off_outlined,
                                size: 20,
                                color: AppColors.primaryPurple,
                              ),
                              muted: true,
                              onPressed: () =>
                                  _enter(context, auth.continueAsGuest),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '로그인하면 프로젝트를 저장하고 다시 확인할 수 있어요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    this.muted = false,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget icon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: muted ? 52 : 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            ElevatedButton.styleFrom(
              elevation: muted ? 0 : 1,
              shadowColor: AppColors.primaryPurple.withValues(alpha: 0.08),
              backgroundColor: muted
                  ? AppColors.paleLavender.withValues(alpha: 0.6)
                  : Colors.white,
              foregroundColor: muted
                  ? AppColors.primaryPurple
                  : AppColors.textBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: BorderSide(
                  color: muted ? AppColors.lightPurple : AppColors.borderSoft,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ).copyWith(
              overlayColor: WidgetStateProperty.all(
                AppColors.lightPurple.withValues(alpha: 0.18),
              ),
            ),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              child: Align(alignment: Alignment.centerLeft, child: icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoonGlow extends StatelessWidget {
  const _MoonGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.lightPurple.withValues(alpha: 0.35),
              AppColors.lightPurple.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _MountainSilhouette extends StatelessWidget {
  const _MountainSilhouette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 96,
        width: double.infinity,
        child: CustomPaint(painter: _MountainPainter()),
      ),
    );
  }
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lightPurple.withValues(alpha: 0.14);
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.15,
        size.width * 0.46,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.85,
        size.width,
        size.height * 0.3,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MountainPainter oldDelegate) => false;
}
