import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  // add routes
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: Splash.page, initial: true),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: SummaryRoute.page),
  ];

  @override
  List<AutoRouteGuard> get guards => [];
}
