import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/pages/signup_page.dart';
import '../../../features/newsfeed/presentation/pages/newsfeed_page.dart';
import '../../../features/splash/presentation/pages/splash_page.dart';
import '../../providers/auth_providers.dart';
import 'route_constants.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _rootNavigator = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);

  return GoRouter(
    navigatorKey: _rootNavigator,
    initialLocation: RoutePaths.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.uri.toString();

      // 1. 인증 상태 로딩 중일 때 처리
      if (authState is AsyncLoading) {
        // 아직 초기값이 없거나 로딩 중
        // Splash 화면이 아니면 Splash 화면으로, Splash 화면이면 그대로 둠
        return location == RoutePaths.splash ? null : RoutePaths.splash;
      }

      // 2. 인증 stream에서 에러가 발생했을 때 처리
      if (authState is AsyncError) {
        // 로그인 페이지나 Splash 페이지가 아니면 로그인 페이지로 이동
        return (location == RoutePaths.login || location == RoutePaths.splash)
            ? null
            : RoutePaths.login;
      }

      // 3. 인증 상태 (User object 가져오기)
      final user = authState.valueOrNull;
      final bool loggedIn = user != null;

      print('loggedIn: $loggedIn');

      // 4. 보호된 경로와 인증/Splash 경로 구분
      final bool isAuthRoute =
          (location == RoutePaths.login || location == RoutePaths.signup);
      final bool isSplash = location == RoutePaths.splash;
      // 우선 newsfeed만 보호
      final bool isProectedRoute = (location == RoutePaths.newsfeed);

      // 5. redirection logic
      if (loggedIn) {
        // 로그인 상태
        // - Splash 또는 인증 관련 경로(로그인, 회원가입)에 있다면 newsfeed 화면으로 이동
        if (isSplash || isAuthRoute) return RoutePaths.newsfeed;
        // - 그 외 경우 (이미 보호된 경로 등)는 그대로 둠 (추가 로직 가능)
        return null;
      } else {
        // 로그이웃 상태
        // - 인증 관련 경로(로그인, 회원가입) 또는 스플래시 화면은 그대로 둠
        if (isAuthRoute) return null;
        if (isSplash) return RoutePaths.login;
        // - 보호된 경로에 접근 시도 시 로그인 페이지로 이동
        if (isProectedRoute) return RoutePaths.login;
        // - 그 외 정의되지 않은 경로로 접근 시 (또는 기본적으로) 로그인 페이지로 (선택적)
        return RoutePaths.login;
      }
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashPage();
        },
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (BuildContext context, GoRouterState state) {
          return const SignupPage();
        },
      ),
      GoRoute(
        path: RoutePaths.newsfeed,
        name: RouteNames.newsfeed,
        builder: (BuildContext context, GoRouterState state) {
          return const NewsfeedPage();
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      // 간단한 에러 페이지
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}
