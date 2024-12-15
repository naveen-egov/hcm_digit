import 'dart:async';

import 'package:digit_components/digit_components.dart';
import 'package:digit_data_model/data/repositories/remote/project_staff.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_data_model/utils/typedefs.dart';

import 'package:digit_showcase/showcase_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:hcm_digit/data/repositories/remote/mdms.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';

import '../blocs/localization/app_localization.dart';

import '../blocs/project_selection/project.dart';
import '../data/local_store/no_sql/schema/app_configuration.dart';
import '../data/local_store/no_sql/schema/service_registry.dart';
import '../data/remote_client.dart';

import '../router/app_router.dart';
import '../router/authenticated_route_observer.dart';
import '../utils/constants.dart';
import '../utils/environment_config.dart';
import '../utils/i18_key_constants.dart' as i18;

import '../widgets/sidebar/side_bar.dart';

@RoutePage()
class AuthenticatedPageWrapper extends StatelessWidget {
  final Box<ServiceRegistry> sbox;
  final Box<AppConfiguration> abox;

  AuthenticatedPageWrapper({super.key,
    required this.sbox,
    required this.abox});

  final StreamController<bool> _drawerVisibilityController =
      StreamController.broadcast();

  @override
  Widget build(BuildContext context) {

    return ShowcaseWidget(
      enableAutoScroll: true,
      builder: Builder(
        builder: (context) {
          return StreamBuilder<bool>(
            stream: _drawerVisibilityController.stream,
            builder: (context, snapshot) {
              final showDrawer = snapshot.data ?? false;

              return Portal(
                child: Scaffold(
                  backgroundColor: DigitTheme.instance.colorScheme.background,
                  appBar: AppBar(
                    backgroundColor: DigitTheme.instance.colorScheme.primary,
                    actions: showDrawer
                        ? [
                            // BlocBuilder<BoundaryBloc, BoundaryState>(
                            //   builder: (ctx, state) {
                            //     final selectedBoundary = ctx.boundaryOrNull;

                            //     if (selectedBoundary == null) {
                            //       return const SizedBox.shrink();
                            //     } else {
                            //       final boundaryName =
                            //           AppLocalizations.of(context).translate(
                            //         selectedBoundary.name ??
                            //             selectedBoundary.code ??
                            //             i18.projectSelection.onProjectMapped,
                            //       );

                            //       final theme = Theme.of(context);

                            //       return GestureDetector(
                            //         onTap: () {
                            //           ctx.router.replaceAll([
                            //             HomeRoute(),
                            //             BoundarySelectionRoute(),
                            //           ]);
                            //         },
                            //         child: SizedBox(
                            //           width: MediaQuery.of(context).size.width -
                            //               60,
                            //           child: Align(
                            //             alignment: Alignment.centerRight,
                            //             child: Row(
                            //               mainAxisSize: MainAxisSize.min,
                            //               children: [
                            //                 Flexible(
                            //                   child: Text(
                            //                     boundaryName,
                            //                     overflow: TextOverflow.ellipsis,
                            //                     style: TextStyle(
                            //                       color:
                            //                           theme.colorScheme.surface,
                            //                       fontSize: 16,
                            //                     ),
                            //                   ),
                            //                 ),
                            //                 const Icon(
                            //                   Icons.arrow_drop_down_outlined,
                            //                 ),
                            //               ],
                            //             ),
                            //           ),
                            //         ),
                            //       );
                            //     }
                            //   },
                            // ),
                          ]
                        : null,
                  ),
                  drawer: showDrawer ? null : null,
                  body: MultiBlocProvider(
                    providers: [
                    
                      BlocProvider(
                        create: (_) => LocationBloc(location: Location())
                          ..add(const LoadLocationEvent()),
                      ),
                      BlocProvider(
                        create: (_) => ProjectBloc(mdmsRepository: MdmsRepository(DioClient().dio,sbox ), context: context, projectStaffRemoteRepository: ProjectStaffRemoteRepository(
                          DioClient().dio,
                          actionMap: Constants().getActionMap(sbox.values.toList())[DataModelType.projectStaff],
                        ),
                          abox: abox,
                          facilityRemoteRepository: FacilityRemoteRepository( DioClient().dio,
                            actionMap: Constants().getActionMap(sbox.values.toList())[DataModelType.facility],),
                          individualRemoteRepository: IndividualRemoteRepository( DioClient().dio,
                            actionMap: Constants().getActionMap(sbox.values.toList())[DataModelType.individual],),
                          projectRemoteRepository: ProjectRemoteRepository( DioClient().dio,
                            actionMap: Constants().getActionMap(sbox.values.toList())[DataModelType.project],),
                          productVariantRemoteRepository: ProductVariantRemoteRepository( DioClient().dio,
                            actionMap: Constants().getActionMap(sbox.values.toList())[DataModelType.productVariant],),
                          projectFacilityRemoteRepository: ProjectFacilityRemoteRepository( DioClient().dio,
                            actionMap: Constants().getActionMap(sbox.values.toList())[DataModelType.projectFacility],),
                          projectResourceRemoteRepository: ProjectResourceRemoteRepository( DioClient().dio,
                            actionMap: Constants().getActionMap(sbox.values.toList())[DataModelType.projectResource],),
                        ),
                      ),

                      // BlocProvider(
                      //   create: (_) => BoundaryBloc(boundaryRepository: BoundaryDataRepository(DioClient().dio,sbox))
                      // ),
                    ],
                    child: AutoRouter(
                      navigatorObservers: () => [
                        AuthenticatedRouteObserver(
                          onNavigated: () {
                            // bool shouldShowDrawer;
                            // switch (context.router.topRoute.name) {
                            //   case ProjectSelectionRoute.name:
                            //   case BoundarySelectionRoute.name:
                            //     shouldShowDrawer = false;
                            //     break;
                            //   default:
                            //     shouldShowDrawer = true;
                            // }

                            // _drawerVisibilityController.add(shouldShowDrawer);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}