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
          opacity: 0.025,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  AppColors.softPurple.withValues(alpha: 0.26),
                  AppColors.backgroundAlt,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 36),
              child: Column(
                children: [
                  const SizedBox(height: 122),
                  Image.asset(
                    'assets/icons/gugakify_logo_full.png',
                    width: 188,
                    errorBuilder: (_, error, stackTrace) =>
                        const Text('Gugakify'),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'AI로 재해석하는 국악 스타일 콘텐츠',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 58),
                  _LoginButton(
                    label: '구글 로그인',
                    icon: SvgPicture.asset(
                      'assets/icons/google_logo.svg',
                      width: 22,
                      height: 22,
                      placeholderBuilder: (_) =>
                          const Icon(Icons.g_mobiledata_rounded),
                    ),
                    onPressed: () => _enter(context, auth.signInWithGoogle),
                  ),
                  const SizedBox(height: 16),
                  _LoginButton(
                    label: '비회원으로 둘러보기',
                    icon: const Icon(
                      Icons.person_off_outlined,
                      size: 24,
                      color: AppColors.primaryPurple,
                    ),
                    muted: true,
                    onPressed: () => _enter(context, auth.continueAsGuest),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
      width: 282,
      height: 57,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: muted ? 0 : 2,
          shadowColor: AppColors.primaryPurple.withValues(alpha: 0.08),
          backgroundColor: muted
              ? AppColors.cardGrayAlt
              : Colors.white.withValues(alpha: 0.94),
          foregroundColor: AppColors.textBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: muted
                  ? Colors.transparent
                  : AppColors.lightPurple.withValues(alpha: 0.45),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Align(alignment: Alignment.centerLeft, child: icon),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
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
