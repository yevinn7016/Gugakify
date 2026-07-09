import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/gugakify_app_scaffold.dart';
import '../../../../shared/widgets/primary_lavender_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _enter(BuildContext context, Future<void> Function() action) async {
    await action();
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return GugakifyAppScaffold(
      child: Column(
        children: [
          const SizedBox(height: 92),
          Image.asset(
            'assets/icons/gugakify_logo_full.png',
            width: 188,
            errorBuilder: (_, error, stackTrace) => const Text('Gugakify'),
          ),
          const SizedBox(height: 78),
          PrimaryLavenderButton(
            label: '구글 로그인',
            icon: SvgPicture.asset(
              'assets/icons/google_logo.svg',
              width: 22,
              height: 22,
              placeholderBuilder: (_) => const Icon(Icons.g_mobiledata_rounded),
            ),
            onPressed: () => _enter(context, auth.signInWithGoogle),
          ),
          const SizedBox(height: 14),
          SecondaryOutlineButton(
            label: '비회원으로 둘러보기',
            onPressed: () => _enter(context, auth.continueAsGuest),
          ),
        ],
      ),
    );
  }
}
