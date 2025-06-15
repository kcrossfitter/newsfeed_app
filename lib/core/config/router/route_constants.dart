abstract class RoutePaths {
  // --- 최상위 경로들 ---
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';

  // --- Bottom Navigation Bar tabs ---
  static const String newsfeed = '/newsfeed';
  static const String search = '/search';
  static const String profile = '/profile';

  // --- sub routes ---
  static const String newsfeedDetail = 'detail/:postId';
  static const String newsfeedEdit = 'edit'; // detail/:postId/edit
  static const String profileEdit = 'edit';

  //--- Top-level routes for fullscreen pages ---
  static const String newsfeedCreate = '/create';
}

abstract class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String signup = 'signup';

  static const String newsfeed = 'newsfeed';
  static const String search = 'search';
  static const String profile = 'profile';

  static const String newsfeedDetail = 'newsfeedDetail';
  static const String newsfeedEdit = 'newsfeedEdit';
  static const String profileEdit = 'profileEdit';
  static const String newsfeedCreate = 'newsfeedCreate';
  // 향후 추가될 경로
}
