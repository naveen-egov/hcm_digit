 import 'package:digit_data_model/data/oplog/oplog.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/service_registry.dart';
import 'package:hcm_digit/data/repositories/remote/auth.dart';
import 'package:hive/hive.dart';


List<RepositoryProvider> getRemoteRepositories(
    Dio dio,
    Map<DataModelType, Map<ApiOperation, String>> actionMap,
  ) {
    final List<RepositoryProvider> remoteRepositories = <RepositoryProvider>[];
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
      ]);
    }

    return remoteRepositories;
  }