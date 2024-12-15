
import 'package:digit_data_model/data/oplog/oplog.dart';
import 'package:hcm_digit/blocs/app_initialization/app_initialization.dart';
import 'package:hcm_digit/models/app_config/app_config_model.dart';
import '../data/local_store/app_shared_preferences.dart';
import '../data/local_store/no_sql/schema/service_registry.dart';
import '../models/data_model.init.dart';
import 'package:digit_data_model/data_model.init.dart' as data_model_mappers;

List<MdmsMasterDetailModel> getMasterDetailsModel(List<String> masterNames) {
  return masterNames.map((e) => MdmsMasterDetailModel(e)).toList();
}

getSelectedLanguage(AppInitialized state, int index) {
  if (AppSharedPreferences().getSelectedLocale == null) {
    AppSharedPreferences()
        .setSelectedLocale(state.appConfiguration.languages!.last.value);
  }
  final selectedLanguage = AppSharedPreferences().getSelectedLocale;
  final isSelected =
      state.appConfiguration.languages![index].value == selectedLanguage;

  return isSelected;
}

extension ApiOperationExtension on String {
  ApiOperation? toApiOperation() {
    switch (this.toLowerCase()) {
      case 'create':
        return ApiOperation.create;
      case 'update':
        return ApiOperation.update;
      case 'delete':
        return ApiOperation.delete;
      default:
        return null; // Handle unexpected values
    }
  }
}

initializeAllMappers() async {
  List<Future> initializations = [
    Future(() => initializeMappers()),
    Future(() => data_model_mappers.initializeMappers()),
  ];
  await Future.wait(initializations);
}

Map<ApiOperation, String>? convertServiceRegistryToMap(ServiceRegistry? registry) {
  if (registry == null) return {};

  return {
    for (var action in registry.actions)
      if (action.action.toApiOperation() != null)
        action.action.toApiOperation()!: action.path
  };
}