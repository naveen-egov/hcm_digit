import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hcm_digit/pages/deliver_intervention.dart';
import 'package:hcm_digit/pages/language_selection.dart';
import 'package:hcm_digit/pages/login.dart';
import 'package:hcm_digit/pages/user_profile.dart';
import 'package:hive/hive.dart';

import '../blocs/localization/app_localization.dart';
// import '../pages/acknowledgement.dart';
import '../data/local_store/no_sql/schema/app_configuration.dart';
import '../data/local_store/no_sql/schema/service_registry.dart';
import '../pages/authenticated.dart';
// import '../pages/boundary_selection.dart';
import '../pages/home.dart';
// import '../pages/language_selection.dart';
// import '../pages/login.dart';
// import '../pages/profile.dart';
// import '../pages/project_facility_selection.dart';
// import '../pages/project_selection.dart';
// import '../pages/qr_details_page.dart';
// import '../pages/reports/beneficiary/beneficaries_report.dart';
import '../pages/boundary_selection.dart';
import '../pages/project_selection.dart';
import '../pages/acknowledgement.dart';
import '../pages/unauthenticated.dart';
export 'package:auto_route/auto_route.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(
  // INFO : Need to add the router modules here
  modules: [],
)
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> routes = [
    AutoRoute(
      page: UnauthenticatedRouteWrapper.page,
      path: '/',
      initial: true,
      children: [
        AutoRoute(
          page: LanguageSelectionRoute.page,
          path: 'language_selection',
          initial: true,
        ),
        AutoRoute(page: LoginRoute.page, path: 'login'),
      ],
    ),
    AutoRoute(
      page: AuthenticatedRouteWrapper.page,
      path: '/',
      children: [
        AutoRoute(
          page: UserProfileRoute.page,
          path: 'userprofile',
        ),
        AutoRoute(
          page: DeliverInterventionRoute.page,
          path: 'deliver-intervention',
        ),
        // project selection
        AutoRoute(
          page: ProjectSelectionRoute.page,
          path: 'select-project',
          initial: true,
        ),
        AutoRoute(page: AcknowledgementRoute.page, path: 'acknowledgement'),

        /// Boundary Selection
        AutoRoute(
          page: BoundarySelectionRoute.page,
          path: 'select-boundary',
        ),
        AutoRoute(page: HomeRoute.page, path: 'home'),
        // AutoRoute(page: HomeRoute.page, path: 'home'),
        // INFO : Need to add Router of package Here
      ],
    )
  ];
}
