// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:personal_finance_app/presentation/pages/home/home_page.dart'
    as _i1;
import 'package:personal_finance_app/presentation/pages/splash/splash.dart'
    as _i2;
import 'package:personal_finance_app/presentation/pages/summary/summary_page.dart'
    as _i3;

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i4.PageRouteInfo<void> {
  const HomeRoute({List<_i4.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomePage();
    },
  );
}

/// generated route for
/// [_i2.Splash]
class Splash extends _i4.PageRouteInfo<void> {
  const Splash({List<_i4.PageRouteInfo>? children})
    : super(Splash.name, initialChildren: children);

  static const String name = 'Splash';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.Splash();
    },
  );
}

/// generated route for
/// [_i3.SummaryPage]
class SummaryRoute extends _i4.PageRouteInfo<void> {
  const SummaryRoute({List<_i4.PageRouteInfo>? children})
    : super(SummaryRoute.name, initialChildren: children);

  static const String name = 'SummaryRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i3.SummaryPage();
    },
  );
}
