import 'package:collection/collection.dart';
import 'package:digit_data_model/data/oplog/oplog.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:hcm_digit/blocs/app_initialization/app_initialization.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/app_configuration.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/localization.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/row_versions.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/service_registry.dart';

import 'package:recase/recase.dart';


class Constants {

  late String _version;
  static final Constants _instance = Constants._();
  Constants._() {

  }
  factory Constants() {
    return _instance;
  }

  String get version {
    return _version;
  }





getActionMap(List<ServiceRegistry> serviceRegistryList) {
  return serviceRegistryList
      .map((e) => e.actions.map((e) {
            ApiOperation? operation;
            DataModelType? type;

            operation = ApiOperation.values.firstWhereOrNull((element) {
              return e.action.camelCase == element.name;
            });

            type = DataModelType.values.firstWhereOrNull((element) {
              return e.entityName.camelCase == element.name;
            });

            if (operation == null || type == null) return null;

            return ActionPathModel(
              operation: operation,
              type: type,
              path: e.path,
            );
          }))
      .expand((element) => element)
      .whereNotNull()
      .fold(
    <DataModelType, Map<ApiOperation, String>>{},
    (Map<DataModelType, Map<ApiOperation, String>> o, element) {
      if (o.containsKey(element.type)) {
        o[element.type]?.addEntries(
          [MapEntry(element.operation, element.path)],
        );
      } else {
        o[element.type] = Map.fromEntries([
          MapEntry(element.operation, element.path),
        ]);
      }

      return o;
    },
  );
}




  
}
class Modules {
  static const String localizationModule = "LOCALIZATION_MODULE";
}

class RequestInfoData {
  static const String apiId = 'hcm';
  static const String ver = '.01';
  static num ts = DateTime.now().millisecondsSinceEpoch;
  static const did = "1";
  static const key = "";
  static String? authToken;
}