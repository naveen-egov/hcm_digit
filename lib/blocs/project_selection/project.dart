// GENERATED using mason_cli
import 'dart:async';
import 'dart:core';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:digit_components/digit_components.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hcm_digit/router/app_router.dart';
import 'package:hive/hive.dart';
import 'dart:html' as html;
import 'package:isar/isar.dart';
import 'package:recase/recase.dart';
import '../../../models/app_config/app_config_model.dart' as app_configuration;
// import '../../data/local_store/no_sql/schema/project.dart';
import '../../data/local_store/no_sql/schema/app_configuration.dart';
import '../../data/local_store/no_sql/schema/row_versions.dart';
import '../../data/local_store/no_sql/schema/service_registry.dart';
import '../../data/local_store/secure_store/secure_store.dart';
import '../../data/repositories/remote/auth.dart';
import '../../data/repositories/remote/mdms.dart';
import '../../models/app_config/app_config_model.dart';
import '../../models/auth/auth_model.dart';
import '../../models/entities/roles_type.dart';
import '../../utils/environment_config.dart';
import '../../utils/utils.dart';

part 'project.freezed.dart';

typedef ProjectEmitter = Emitter<ProjectState>;

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final LocalSecureStore localSecureStore;
  final MdmsRepository mdmsRepository;
  final RemoteRepository<IndividualModel, IndividualSearchModel>
      individualRemoteRepository;
  //
  //
  /// Project Staff Repositories
  final RemoteRepository<ProjectStaffModel, ProjectStaffSearchModel>
      projectStaffRemoteRepository;

  /// Project Repositories
  final RemoteRepository<ProjectModel, ProjectSearchModel>
      projectRemoteRepository;

  final Box<AppConfiguration> abox;

  // final RemoteRepository<AttendanceRegisterModel, AttendanceRegisterSearchModel>
  // attendanceRemoteRepository;

  // final RemoteRepository<IndividualModel, IndividualSearchModel>
  // individualRemoteRepository;

  // final RemoteRepository<AttendanceLogModel, AttendanceLogSearchModel>
  // attendanceLogRemoteRepository;

  /// Project Facility Repositories
  final RemoteRepository<ProjectFacilityModel, ProjectFacilitySearchModel>
      projectFacilityRemoteRepository;

  /// Facility Repositories
  final RemoteRepository<FacilityModel, FacilitySearchModel>
      facilityRemoteRepository;
  //
  // // /// Stock Repositories
  // // final RemoteRepository<StockModel, StockSearchModel> stockRemoteRepository;
  //
  // /// Service Definition Repositories
  // final RemoteRepository<ServiceDefinitionModel, ServiceDefinitionSearchModel>
  // serviceDefinitionRemoteRepository;
  //
  // ///Boundary Resource Repositories
  // final RemoteRepository<BoundaryModel, BoundarySearchModel>
  // boundaryRemoteRepository;

  /// Project Resource Repositories
  final RemoteRepository<ProjectResourceModel, ProjectResourceSearchModel>
      projectResourceRemoteRepository;

  /// Product Variant Repositories
  final RemoteRepository<ProductVariantModel, ProductVariantSearchModel>
      productVariantRemoteRepository;

  BuildContext context;

  ProjectBloc({
    LocalSecureStore? localSecureStore,
    required this.projectStaffRemoteRepository,
    required this.projectRemoteRepository,
    required this.projectFacilityRemoteRepository,
    required this.facilityRemoteRepository,
    // required this.stockRemoteRepository,
    // required this.serviceDefinitionRemoteRepository,
    // required this.boundaryRemoteRepository,
    // required this.isar,
    required this.projectResourceRemoteRepository,
    required this.productVariantRemoteRepository,
    required this.mdmsRepository,
    required this.abox,
    // required this.attendanceRemoteRepository,
    required this.individualRemoteRepository,
    // required this.attendanceLogRemoteRepository,
    required this.context,
  })  : localSecureStore = localSecureStore ?? LocalSecureStore.instance,
        super(const ProjectState()) {
    on(_handleProjectInit);
    on(_handleProjectSelection);
  }

  FutureOr<void> _handleProjectInit(
    ProjectInitializeEvent event,
    ProjectEmitter emit,
  ) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    AppLogger.instance.info(
      'Connectivity Result: $connectivityResult',
      title: 'ProjectBloc',
    );

// localSecureStore.storage.deleteAll();
    final isOnline = connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile;
    print("HERE___))))");
    final selectedProject = await localSecureStore.selectedProject;

    final isProjectSetUpComplete = await localSecureStore
        .isProjectSetUpComplete(selectedProject?.id ?? "noProjectId");
    print(isProjectSetUpComplete);
    //
    // /*Checks for if device is online and project data downloaded*/
    print(selectedProject);
    print("   ---- ---- --- ");
    print("---------selectedProject--------");
    print(!isProjectSetUpComplete);
    if (!isProjectSetUpComplete) {
      await _loadOnline(emit);
    } else {
      print(isProjectSetUpComplete);
         Uri uri = Uri.parse(html.window.location.href);
    final r = LocalSecureStore.instance.accessToken;
    final user = LocalSecureStore.instance.userRequestModel;
    final id = LocalSecureStore.instance.userIndividualId;
    print("URL-=--");

    // Extract query parameters
    Map<String, String> queryParams = uri.queryParameters;
        if (queryParams.entries.lastOrNull?.value != null) {
      // ignore: use_build_context_synchronously
      context.router.push(UserProfileRoute());
    } else {
      await _loadOnline(emit);
    }
    }
  }



  FutureOr<void> _loadOnline(ProjectEmitter emit) async {
    // final batchSize = await _getBatchSize();
    final userObject = await localSecureStore.userRequestModel;
    final uuid = userObject?.uuid;

    List<ProjectStaffModel> projectStaffList;
    try {
      projectStaffList = await projectStaffRemoteRepository.search(
        ProjectStaffSearchModel(staffId: [uuid.toString()]),
      );
      print('ttttttttttttttttttttttttttttttt');
    } catch (error) {
      print(
          '${error} eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');

      emit(
        state.copyWith(
          loading: false,
          syncError: ProjectSyncErrorType.projectStaff,
        ),
      );

      return;
    }

    print(projectStaffList);
    print('ssssssssssssssssssssssssssssss');

    // projectStaffList.removeDuplicates((e) => e.id);

    if (projectStaffList.isEmpty) {
      emit(const ProjectState(
        projects: [],
        loading: false,
        selectedProject: null,
        syncError: null,
      ));

      return;
    }

    List<ProjectModel> projects = [];
    for (final projectStaff in projectStaffList) {
      // await projectStaffLocalRepository.create(
      //   projectStaff,
      //   createOpLog: false,
      // );

      List<ProjectModel> staffProjects;
      try {
        // if (localSecureStore.loggedInUserRoles
        //     .where(
        //       (role) => role.code == RolesType.districtSupervisor.toValue(),
        // )
        //     .toList()
        //     .isNotEmpty) {
        //   final individual = await individualRemoteRepository.search(
        //     IndividualSearchModel(
        //       userUuid: [projectStaff.userId.toString()],
        //     ),
        //   );
        //   // if (individual.isNotEmpty) {
        //   //   final attendanceRegisters = await attendanceRemoteRepository.search(
        //   //     AttendanceRegisterSearchModel(
        //   //       staffId: individual.first.id,
        //   //       referenceId: projectStaff.projectId,
        //   //     ),
        //   //   );
        //   //   await attendanceLocalRepository.bulkCreate(attendanceRegisters);
        //   //
        //   //   for (final register in attendanceRegisters) {
        //   //     if (register.attendees != null &&
        //   //         (register.attendees ?? []).isNotEmpty) {
        //   //       try {
        //   //         final individuals = await individualRemoteRepository.search(
        //   //           IndividualSearchModel(
        //   //             id: register.attendees!
        //   //                 .map((e) => e.individualId!)
        //   //                 .toList(),
        //   //           ),
        //   //         );
        //   //         await individualLocalRepository.bulkCreate(individuals);
        //   //         final logs = await attendanceLogRemoteRepository.search(
        //   //           AttendanceLogSearchModel(
        //   //             registerId: register.id,
        //   //           ),
        //   //         );
        //   //         await attendanceLogLocalRepository.bulkCreate(logs);
        //   //       } catch (_) {
        //   //         emit(state.copyWith(
        //   //           loading: false,
        //   //           syncError: ProjectSyncErrorType.project,
        //   //         ));
        //   //
        //   //         return;
        //   //       }
        //   //     }
        //   //   }
        //   // }
        // }
        staffProjects = await projectRemoteRepository.search(
          ProjectSearchModel(
            id: projectStaff.projectId,
            tenantId: projectStaff.tenantId,
          ),
        );
      } catch (_) {
        emit(state.copyWith(
          loading: false,
          syncError: ProjectSyncErrorType.project,
        ));

        return;
      }

      projects.addAll(staffProjects);
    }
    //
    // projects.removeDuplicates((e) => e.id);
    //
    // for (final project in projects) {
    //   await projectLocalRepository.create(
    //     project,
    //     createOpLog: false,
    //   );
    // }
    //
    if (projects.isNotEmpty) {
      // INFO : Need to add project load functions

      try {
        await _loadProjectFacilities(projects, 100);
      } catch (_) {
        emit(
          state.copyWith(
            loading: false,
            syncError: ProjectSyncErrorType.projectFacilities,
          ),
        );
      }
      try {
        await _loadProductVariants(projects);
      } catch (_) {
        emit(
          state.copyWith(
            loading: false,
            syncError: ProjectSyncErrorType.productVariants,
          ),
        );
      }
      // try {
      //   await _loadServiceDefinition(projects);
      // } catch (_) {
      //   emit(
      //     state.copyWith(
      //       loading: false,
      //       syncError: ProjectSyncErrorType.serviceDefinitions,
      //     ),
      //   );
      // }
      // try {
      //   await _loadServiceDefinition(projects);
      // } catch (_) {
      //   emit(
      //     state.copyWith(
      //       loading: false,
      //       syncError: ProjectSyncErrorType.serviceDefinitions,
      //     ),
      //   );
      // }
    }

    emit(ProjectState(
      projects: projects,
      loading: false,
      syncError: null,
    ));

    if (projects.length == 1) {
      add(ProjectSelectProjectEvent(projects.first));
    }
  }
  //
  // FutureOr<void> _loadOffline(ProjectEmitter emit) async {
  //   final projects = await projectLocalRepository.search(
  //     ProjectSearchModel(
  //       tenantId: envConfig.variables.tenantId,
  //     ),
  //   );
  //
  //   projects.removeDuplicates((element) => element.id);
  //
  //   final selectedProject = await localSecureStore.selectedProject;
  //   emit(
  //     ProjectState(
  //       loading: false,
  //       projects: projects,
  //       selectedProject: selectedProject,
  //     ),
  //   );
  // }

  FutureOr<void> _loadProjectFacilities(
      List<ProjectModel> projects, int batchSize) async {
    final projectFacilities = await projectFacilityRemoteRepository.search(
      ProjectFacilitySearchModel(
        projectId: projects.map((e) => e.id).toList(),
      ),
    );

    // await projectFacilityLocalRepository.bulkCreate(projectFacilities);

    final facilities = await facilityRemoteRepository.search(
      FacilitySearchModel(tenantId: envConfig.variables.tenantId),
      limit: batchSize,
    );

    // await facilityLocalRepository.bulkCreate(facilities);
  }

  // FutureOr<void> _loadServiceDefinition(List<ProjectModel> projects) async {
  //   final configs = abox.values.toList();
  //   final userObject = await localSecureStore.userRequestModel;
  //   List<String> codes = [];
  //   for (UserRoleModel elements in userObject!.roles) {
  //     configs.first.checklistTypes?.map((e) => e.code).forEach((element) {
  //       for (final project in projects) {
  //         codes.add(
  //           '${project.name}.$element.${elements.code.snakeCase.toUpperCase()}',
  //         );
  //       }
  //     });
  //   }
  //
  //   final serviceDefinition = await serviceDefinitionRemoteRepository
  //       .search(ServiceDefinitionSearchModel(
  //     tenantId: envConfig.variables.tenantId,
  //     code: codes,
  //   ));
  //
  //   for (var element in serviceDefinition) {
  //     await serviceDefinitionLocalRepository.create(
  //       element,
  //       createOpLog: false,
  //     );
  //   }
  // }

  FutureOr<void> _loadProductVariants(List<ProjectModel> projects) async {
    for (final project in projects) {
      final projectResources = await projectResourceRemoteRepository.search(
        ProjectResourceSearchModel(projectId: [project.id]),
      );

      for (final projectResource in projectResources) {
        // await projectResourceLocalRepository.create(
        //   projectResource,
        //   createOpLog: false,
        // );

        final productVariants = await productVariantRemoteRepository.search(
          ProductVariantSearchModel(
            id: [projectResource.resource.productVariantId],
          ),
        );

        // for (final productVariant in productVariants) {
        //   await productVariantLocalRepository.create(
        //     productVariant,
        //     createOpLog: false,
        //   );
        // }
      }
    }
  }

  Future<void> _handleProjectSelection(
    ProjectSelectProjectEvent event,
    ProjectEmitter emit,
  ) async {
    emit(state.copyWith(loading: true, syncError: null));

    List<BoundaryModel> boundaries;
    try {
      // try {
      //   final startDate = DateTime(
      //       DateTime.now().year, DateTime.now().month, DateTime.now().day)
      //       .toLocal()
      //       .millisecondsSinceEpoch;
      //   final endDate = DateTime(DateTime.now().year, DateTime.now().month,
      //       DateTime.now().day, 23, 59)
      //       .toLocal()
      //       .millisecondsSinceEpoch;
      //   // final serviceRegistry = await isar.serviceRegistrys.where().findAll();
      //   // final dashboardConfig = await isar.dashboardConfigSchemas
      //   //     .where()
      //   //     .filter()
      //   //     .chartsIsNotNull()
      //   //     .chartsIsNotEmpty()
      //   //     .findAll();
      // //   final dashboardActionPath = Constants.getEndPoint(
      // //       serviceRegistry: serviceRegistry,
      // //       service: DashboardResponseModel.schemaName.toUpperCase(),
      // //       action: ApiOperation.search.toValue(),
      // //       entityName: DashboardResponseModel.schemaName);
      // //   if (dashboardConfig.isNotEmpty &&
      // //       dashboardConfig.first.enableDashboard == true &&
      // //       dashboardConfig.first.charts != null) {
      // //     final loggedInIndividualId = await localSecureStore.userIndividualId;
      // //     final registers = await attendanceLocalRepository.search(
      // //       AttendanceRegisterSearchModel(
      // //         staffId: loggedInIndividualId,
      // //         referenceId: event.model.id,
      // //       ),
      // //     );
      // //     List<String> attendeesIndividualIds = [];
      // //     registers.forEach((r) {
      // //       r.attendees?.where((a) => a.individualId != null).forEach((att) {
      // //         attendeesIndividualIds.add(att.individualId.toString());
      // //       });
      // //     });
      // //     final individuals =
      // //     await individualLocalRepository.search(IndividualSearchModel(
      // //       id: attendeesIndividualIds,
      // //     ));
      // //     final userUUIDList = individuals
      // //         .where((ind) => ind.userUuid != null)
      // //         .map((i) => i.userUuid.toString())
      // //         .toList();
      // //     await processDashboardConfig(
      // //       dashboardConfig.first.charts ?? [],
      // //       startDate,
      // //       endDate,
      // //       isar,
      // //       DateTime.now(),
      // //       dashboardRemoteRepository,
      // //       dashboardActionPath.trim().isNotEmpty
      // //           ? dashboardActionPath
      // //           : '/dashboard-analytics/dashboard/getChartV2', //[TODO: To be added to MDMS Service registry
      // //       envConfig.variables.tenantId,
      // //       event.model.id,
      // //       userUUIDList,
      // //     );
      // //   }
      // // } catch (e) {
      //   debugPrint(e.toString());
      // }
      // final configResult = await mdmsRepository.searchAppConfig(
      //   envConfig.variables.mdmsApiPath,
      //   MdmsRequestModel(
      //     mdmsCriteria: MdmsCriteriaModel(
      //       tenantId: envConfig.variables.tenantId,
      //       moduleDetails: [
      //         const MdmsModuleDetailModel(
      //           moduleName: 'module-version',
      //           masterDetails: [
      //             MdmsMasterDetailModel('ROW_VERSIONS'),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ).toJson(),
      // );

      // print(configResult);
      print('---result ---');

      // final rowversionList = await isar.rowVersionLists
      //     .filter()
      //     .moduleEqualTo('egov-location')
      //     .findAll();

      // final serverVersion = configResult.rowVersions?.rowVersionslist
      //     ?.where(
      //       (element) => element.module == 'egov-location',
      // )
      //     .toList()
      //     .firstOrNull
      //     ?.version;

      final boundaryRefetched = await localSecureStore.boundaryRefetched;
      await localSecureStore.setSelectedProject(event.model);
      await localSecureStore.setProjectSetUpComplete(event.model.id, true);
    } catch (_) {
      emit(state.copyWith(
        loading: false,
        syncError: ProjectSyncErrorType.boundary,
      ));
    }

    emit(state.copyWith(
      selectedProject: event.model,
      loading: false,
      syncError: null,
    ));
  }

  // FutureOr<int> _getBatchSize() async {
  //   try {
  //     final configs = await isar.appConfigurations.where().findAll();
  //
  //     final double speed = await bandwidthCheckRepository.pingBandwidthCheck(
  //       bandWidthCheckModel: null,
  //     );
  //
  //     int configuredBatchSize = getBatchSizeToBandwidth(
  //       speed,
  //       configs,
  //       isDownSync: true,
  //     );
  //     return configuredBatchSize;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}

@freezed
class ProjectEvent with _$ProjectEvent {
  const factory ProjectEvent.initialize() = ProjectInitializeEvent;

  const factory ProjectEvent.selectProject(ProjectModel model) =
      ProjectSelectProjectEvent;
}

@freezed
class ProjectState with _$ProjectState {
  const ProjectState._();

  const factory ProjectState({
    @Default([]) List<ProjectModel> projects,
    ProjectModel? selectedProject,
    @Default(false) bool loading,
    ProjectSyncErrorType? syncError,
  }) = _ProjectState;

  bool get isEmpty => projects.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool get hasSelectedProject => selectedProject != null;
}

enum ProjectSyncErrorType {
  projectStaff,
  project,
  projectFacilities,
  productVariants,
  serviceDefinitions,
  boundary
}
