import 'package:go_router/go_router.dart';

import '../../features/audio/presentation/screens/audio_convert_setting_screen.dart';
import '../../features/audio/presentation/screens/audio_processing_screen.dart';
import '../../features/audio/presentation/screens/audio_result_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/intro_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/mv/presentation/screens/mv_processing_screen.dart';
import '../../features/mv/presentation/screens/mv_setting_screen.dart';
import '../../features/mypage/presentation/screens/my_page_screen.dart';
import '../../features/result/presentation/screens/final_result_screen.dart';
import '../../features/upload/presentation/screens/upload_screen.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/intro',
    refreshListenable: authProvider,
    redirect: (context, state) {
      if (state.uri.path == '/mypage' && authProvider.isGuest) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/intro', builder: (context, state) => const IntroScreen()),
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/upload',
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: '/audio/settings',
        builder: (context, state) => const AudioConvertSettingScreen(),
      ),
      GoRoute(
        path: '/audio/processing',
        builder: (context, state) => const AudioProcessingScreen(),
      ),
      GoRoute(
        path: '/audio/result',
        builder: (context, state) => const AudioResultScreen(),
      ),
      GoRoute(
        path: '/mv/settings',
        builder: (context, state) => const MvSettingScreen(),
      ),
      GoRoute(
        path: '/mv/processing',
        builder: (context, state) => const MvProcessingScreen(),
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) => const FinalResultScreen(),
      ),
      GoRoute(
        path: '/mypage',
        builder: (context, state) => const MyPageScreen(),
      ),
    ],
  );
}
