import 'dart:io';


import 'package:digit_components/theme/digit_theme.dart';
import 'package:digit_components/widgets/digit_card.dart';
import 'package:digit_components/widgets/digit_elevated_button.dart';
import 'package:digit_components/widgets/scrollable_content.dart';
import 'package:digit_data_model/data/oplog/oplog.dart';
import 'package:digit_data_model/data_model.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:provider/provider.dart';


import '../blocs/app_initialization/app_initialization.dart';

import '../data/repositories/remote/auth.dart';


class NetworkManagerProviderWrapper extends StatelessWidget {

  final Dio dio;
  final Widget child;




  const NetworkManagerProviderWrapper({
    super.key,

    
    required this.dio,
    
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppInitializationBloc, AppInitializationState>(
      builder: (context, state) {
        final actionMap = state.entityActionMapping;
        if (actionMap.isEmpty) {
          return MaterialApp(
            theme: DigitTheme.instance.mobileTheme,
            home: Scaffold(
              appBar: AppBar(),
              body: state.maybeWhen(
                orElse: () => const Center(
                  child: Text('Unable to initialize the application'),
                ),
                /*Returns Loading state while app initialization is in progress*/
                loading: () => const Center(
                  child: Text('Loading'),
                ),
                /*Returns No Internet Connection warning if its failed to initialize after all retries
                  and shows a button to close the app*/
                failed: () => ScrollableContent(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  footer: DigitCard(
                    child: DigitElevatedButton(
                      onPressed: () => exit(0),
                      child: const Center(
                        child: Text('Close'),
                      ),
                    ),
                  ),
                  children: const [
                    Center(
                      child: Text('Internet not available. Try later.'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final remote = _getRemoteRepositories(dio, actionMap);


        return MultiRepositoryProvider(
          providers: [

            ...remote,
          ],
          child:child,
        );
      },
    );
  }

 
  List<RepositoryProvider> _getRemoteRepositories(
    Dio dio,
    Map<DataModelType, Map<ApiOperation, String>> actionMap,
  ) {
    final remoteRepositories = <RepositoryProvider>[];
    for (final value in DataModelType.values) {
      if (!actionMap.containsKey(value)) {
        continue;
      }

      final actions = actionMap[value]!;

      remoteRepositories.addAll([
        if (value == DataModelType.user)
          RepositoryProvider<AuthRepository>(
            create: (_) => AuthRepository(
              dio,
              loginPath: actions[ApiOperation.login] ?? '',
            ),
          ),
        if (value == DataModelType.facility)
          RepositoryProvider<
              RemoteRepository<FacilityModel, FacilitySearchModel>>(
            create: (_) => FacilityRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),
        if (value == DataModelType.individual)
          RepositoryProvider<
              RemoteRepository<IndividualModel, IndividualSearchModel>>(
            create: (_) => IndividualRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),
        if (value == DataModelType.product)
          RepositoryProvider<
              RemoteRepository<ProductModel, ProductSearchModel>>(
            create: (_) => ProductRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),
        if (value == DataModelType.productVariant)
          RepositoryProvider<
              RemoteRepository<ProductVariantModel, ProductVariantSearchModel>>(
            create: (_) =>
                ProductVariantRemoteRepository(dio, actionMap: actions),
          ),
        if (value == DataModelType.project)
          RepositoryProvider<
              RemoteRepository<ProjectModel, ProjectSearchModel>>(
            create: (_) => ProjectRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),
        if (value == DataModelType.projectFacility)
          RepositoryProvider<
              RemoteRepository<ProjectFacilityModel,
                  ProjectFacilitySearchModel>>(
            create: (_) =>
                ProjectFacilityRemoteRepository(dio, actionMap: actions),
          ),
        if (value == DataModelType.projectProductVariant)
          RepositoryProvider<
              RemoteRepository<ProjectProductVariantModel,
                  ProjectProductVariantSearchModel>>(
            create: (_) =>
                ProjectProductVariantRemoteRepository(dio, actionMap: actions),
          ),
        if (value == DataModelType.projectStaff)
          RepositoryProvider<
              RemoteRepository<ProjectStaffModel, ProjectStaffSearchModel>>(
            create: (_) =>
                ProjectStaffRemoteRepository(dio, actionMap: actions),
          ),
        if (value == DataModelType.projectResource)
          RepositoryProvider<
              RemoteRepository<ProjectResourceModel,
                  ProjectResourceSearchModel>>(
            create: (_) =>
                ProjectResourceRemoteRepository(dio, actionMap: actions),
          ),
        if (value == DataModelType.service)
          RepositoryProvider<
              RemoteRepository<ServiceModel, ServiceSearchModel>>(
            create: (_) => ServiceRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),
        if (value == DataModelType.serviceDefinition)
          RepositoryProvider<
              RemoteRepository<ServiceDefinitionModel,
                  ServiceDefinitionSearchModel>>(
            create: (_) => ServiceDefinitionRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),
        if (value == DataModelType.boundary)
          RepositoryProvider<
              RemoteRepository<BoundaryModel, BoundarySearchModel>>(
            create: (_) => BoundaryRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),
        if (value == DataModelType.productVariant)
          RepositoryProvider<
              RemoteRepository<ProductVariantModel, ProductVariantSearchModel>>(
            create: (_) => ProductVariantRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),

        if (value == DataModelType.user)
          RepositoryProvider<RemoteRepository<UserModel, UserSearchModel>>(
            create: (_) => UserRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),
      
        // INFO Need to add packages here

        if (value == DataModelType.complaints)
          RepositoryProvider<
              RemoteRepository<PgrServiceModel, PgrServiceSearchModel>>(
            create: (_) => PgrServiceRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),


     if (value == DataModelType.task)
          RepositoryProvider<RemoteRepository<TaskModel, TaskSearchModel>>(
            create: (_) => TaskRemoteRepository(
              dio,
              actionMap: actions,
            ),
          ),
      ]);
    }

    return remoteRepositories;
  }
}

class ActionPathModel {
  final DataModelType type;
  final String path;
  final ApiOperation operation;

  const ActionPathModel({
    required this.operation,
    required this.type,
    required this.path,
  });
}
