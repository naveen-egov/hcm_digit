import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_components/digit_components.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../models/app_config/app_config_model.dart' as app_configuration;
import '../../../models/mdms/service_registry/pgr_service_defenitions.dart';
import '../../../models/mdms/service_registry/service_registry_model.dart';
import '../../../models/role_actions/role_actions_model.dart';
import '../../local_store/no_sql/schema/app_configuration.dart';
import '../../local_store/no_sql/schema/row_versions.dart';
import '../../local_store/no_sql/schema/service_registry.dart';

class MdmsRepository {
  final Dio _client;
  final Box<ServiceRegistry> sbox;
  const MdmsRepository(this._client,this.sbox);

  Future<ServiceRegistryPrimaryWrapperModel> searchServiceRegistry(
    String apiEndPoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.post(apiEndPoint, data: body);
      print(response);
      print("HERE--");
      return ServiceRegistryPrimaryWrapperModel.fromJson(
        json.decode(response.toString())['MdmsRes'],
      );
    } catch (_) {
      print(_);
      print('CAT');
      rethrow;
    }
  }

  FutureOr<void> writeToRegistryDB(
    ServiceRegistryPrimaryWrapperModel result,
       Box<ServiceRegistry> sbox
  ) async {
    // TODO Write to HIVE
    final List<ServiceRegistry> newServiceRegistryList = [];
    final data = result.serviceRegistry?.serviceRegistryList;
    if (data != null && data.isNotEmpty) {
      // await isar.writeTxn(() async => await isar.serviceRegistrys.clear());
    }
    for (final element in data ?? <ServiceRegistryModel>[]) {
      final newServiceRegistry = ServiceRegistry();
      newServiceRegistry.service = element.service;
      final actions = element.actions.map((item) {
        final newServiceRegistryAction = Actions()
          ..entityName = item.entityName
          ..path = item.path
          ..action = item.action;

        return newServiceRegistryAction;
      }).toList();
      actions.add(Actions()
        ..entityName = 'Boundary'
        ..action = 'search'
        ..path = '/boundary-service/boundary-relationships/_search');

      newServiceRegistry.actions = actions;
      newServiceRegistryList.add(newServiceRegistry);
    }
    try {

      await sbox.addAll(newServiceRegistryList);
    } catch (e) {
      print(e);
    } finally {
      print("DONE");
      return;
    }

    return;
  }

  Future<app_configuration.AppConfigPrimaryWrapperModel> searchAppConfig(
    String apiEndPoint,
    Map body,
  ) async {
    try {
      final response = await _client.post(apiEndPoint, data: body);

      final appCon = app_configuration.AppConfigPrimaryWrapperModel.fromJson(
        json.decode(response.toString())['MdmsRes'],
      );

      return appCon;
    } on DioError catch (e) {
      AppLogger.instance.error(
        title: 'MDMS Repository',
        message: '$e',
        stackTrace: e.stackTrace,
      );
      rethrow;
    }
  }

  FutureOr<PGRServiceDefinitions> searchPGRServiceDefinitions(
    String apiEndPoint,
    Map<String, dynamic> body,
  ) async {
    var response;
    try {
      response = await _client.post(apiEndPoint, data: body);

      return PGRServiceDefinitions.fromJson(
        json.decode(response.toString())['MdmsRes'],
      );
    } on DioError catch (e) {
      AppLogger.instance.error(
        title: 'MDMS Repository',
        message: '$e',
        stackTrace: e.stackTrace,
      );
      rethrow;
    } finally {
      // ignore: control_flow_in_finally
      return PGRServiceDefinitions.fromJson(
        json.decode(response.toString())['MdmsRes'],
      );
    }
    
  }

  FutureOr<void> writeToAppConfigDB(
    app_configuration.AppConfigPrimaryWrapperModel result,
    PGRServiceDefinitions pgrServiceDefinitions,
      final Box<AppConfiguration> abox
  ) async {
    final appConfiguration = AppConfiguration();

    final data = result.rowVersions?.rowVersionslist;

    final List<RowVersionList> rowVersionList = [];

    for (final element in data ?? <app_configuration.RowVersions>[]) {
      final rowVersion = RowVersionList();
      rowVersion.module = element.module;
      rowVersion.version = element.version;
      rowVersionList.add(rowVersion);
    }

    final element = result.hcmWrapperModel;
    final appConfig = result.hcmWrapperModel?.appConfig.first;
    final commonMasters = result.commonMasters;

    appConfiguration
      ..networkDetection = appConfig?.networkDetection
      ..persistenceMode = appConfig?.persistenceMode
      ..syncMethod = appConfig?.syncMethod
      ..syncTrigger = appConfig?.syncTrigger
      ..tenantId = appConfig?.tenantId
      ..maxRadius = appConfig?.maxRadius;
    

    final List<Languages>? languageList =
        commonMasters?.stateInfo.first.languages.map((element) {
      final languages = Languages()
        ..label = element.label
        ..value = element.value;

      return languages;
    }).toList();

    final List<GenderOptions>? genderOptions =
        commonMasters?.genderType.map((element) {
      final genderOption = GenderOptions()
        ..name = element.name ?? ''
        ..code = element.code;

      return genderOption;
    }).toList();

    final List<Interfaces>? interfaceList =
        element?.backendInterface.first.interface.map((e) {
  

      final interfaces = Interfaces()
        ..name = e.name
        ..type = e.type;



      return interfaces;
    }).toList();

    final backendInterface = BackendInterface()
      ..interfaces = interfaceList ?? [];
    appConfiguration.genderOptions = genderOptions!;

    appConfiguration.backendInterface = backendInterface;


    appConfiguration.languages= languageList!;
    print("-----L----");
print(appConfiguration.languages.length);
      await abox.add(appConfiguration);


    print("-----O----");
    // await isar.writeTxn(() async {
    //   await isar.appConfigurations.put(appConfiguration);
    //   await isar.rowVersionLists.putAll(rowVersionList);
    // });
    return;
  }

  Future<RoleActionsWrapperModel> searchRoleActions(
    String apiEndPoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final Response response = await _client.post(apiEndPoint, data: body);

      return RoleActionsWrapperModel.fromJson(json.decode(response.toString()));
    } catch (_) {
      rethrow;
    }
  }
}
