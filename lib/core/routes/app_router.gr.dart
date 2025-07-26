// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:personal_finance_app/presentation/pages/category_management/category_management.dart'
    as _i1;
import 'package:personal_finance_app/presentation/pages/home/home_page.dart'
    as _i2;
import 'package:personal_finance_app/presentation/pages/splash/splash.dart'
    as _i3;
import 'package:personal_finance_app/presentation/pages/summary/summary_page.dart'
    as _i4;

/// generated route for
/// [_i1.CategoryManagementPage]
class CategoryManagementRoute extends _i5.PageRouteInfo<void> {
  const CategoryManagementRoute({List<_i5.PageRouteInfo>? children})
      : super(
          CategoryManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'CategoryManagementRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.CategoryManagementPage();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.Splash]
class Splash extends _i5.PageRouteInfo<void> {
  const Splash({List<_i5.PageRouteInfo>? children})
      : super(
          Splash.name,
          initialChildren: children,
        );

  static const String name = 'Splash';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.Splash();
    },
  );
}

/// generated route for
/// [_i4.SummaryPage]
class SummaryRoute extends _i5.PageRouteInfo<void> {
  const SummaryRoute({List<_i5.PageRouteInfo>? children})
      : super(
          SummaryRoute.name,
          initialChildren: children,
        );

  static const String name = 'SummaryRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.SummaryPage();
    },
  );
}
