import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/app_state/project_state.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

class GugakifyApp extends StatelessWidget {
  const GugakifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(
          create: (_) => ProjectProvider()..loadRecentProjects(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = createAppRouter(context.read<AuthProvider>());
          return MaterialApp.router(
            title: 'Gugakify',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
