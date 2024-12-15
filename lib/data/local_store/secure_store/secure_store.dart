import 'dart:convert';

import 'package:digit_data_model/data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_html/html.dart' as html;
import '../../../models/auth/auth_model.dart';
import '../../../models/role_actions/role_actions_model.dart';

class LocalSecureStore {
  static const accessTokenKey = 'accessTokenKey';
  static const refreshTokenKey = 'refreshTokenKey';
  static const userObjectKey = 'userObject';
  static const selectedProjectKey = 'selectedProject';
  static const selectedIndividualKey = 'selectedIndividual';
  static const hasAppRunBeforeKey = 'hasAppRunBefore';
  static const backgroundServiceKey = 'backgroundServiceKey';
  static const boundaryRefetchInKey = 'boundaryRefetchInKey';
  static const actionsListkey = 'actionsListkey';
  static const isAppInActiveKey = 'isAppInActiveKey';
  static const manualSyncKey = 'manualSyncKey';
  static const selectedProjectTypeKey = 'selectedProjectType';

  final storage = const FlutterSecureStorage();

  static LocalSecureStore get instance => _instance;
  static final LocalSecureStore _instance = LocalSecureStore._();

  LocalSecureStore._();

  Future<String?> get accessToken {
    if (kIsWeb) {
      return  html.window.sessionStorage[accessTokenKey] != null? jsonDecode(html.window.sessionStorage[accessTokenKey]!): storage.read(key: accessTokenKey);
    } else {
      return storage.read(key: accessTokenKey);
    }
  }

  Future<String?> get refreshToken {
    return storage.read(key: refreshTokenKey);
  }

  Future<bool> get isBackgroundSerivceRunning async {
    final hasRun = await storage.read(key: backgroundServiceKey);

    switch (hasRun) {
      case 'true':
        return true;
      default:
        return false;
    }
  }

  Future<UserRequestModel?> get userRequestModel async {
    if (kIsWeb) {
            final userBody = await storage.read(key: userObjectKey);
         
      return html.window.sessionStorage[userObjectKey] != null? UserRequestModel.fromJson(
          jsonDecode(html.window.sessionStorage[userObjectKey]!)) :    null;
    } else {
      final userBody = await storage.read(key: userObjectKey);
      if (userBody == null) return null;

      try {
        final user = UserRequestModel.fromJson(json.decode(userBody));

        return user;
      } catch (_) {
        return null;
      }
    }
  }

  Future<String?> get userIndividualId async {
    final individualId = await storage.read(key: selectedIndividualKey);
    if (individualId == null) return null;

    try {
      final user = individualId;

      return user;
    } catch (_) {
      return null;
    }
  }

  Future<bool> get isAppInActive async {
    final hasRun = await storage.read(key: isAppInActiveKey);

    switch (hasRun) {
      case 'true':
        return true;
      default:
        return false;
    }
  }

  Future<bool> get isManualSyncRunning async {
    final hasRun = await storage.read(key: manualSyncKey);

    switch (hasRun) {
      case 'true':
        return true;
      default:
        return false;
    }
  }

  Future<ProjectModel?> get selectedProject async {

    final projectString = kIsWeb? html.window.sessionStorage[selectedProjectKey] : await storage.read(key: selectedProjectKey);

    print(projectString);
    print("papapapap");
    if (projectString == null) return null;

    try {
     final project = ProjectModelMapper.fromJson( json.decode(projectString));

      // final project = ProjectModelMapper.fromMap(json.decode(projectString));
      print(project);
      print("===");

      return project;
    } catch (_) {
      print(_);
      print("---ERROR----");
      return null;
    }
  }

  Future<RoleActionsWrapperModel?> get savedActions async {
    final actionsListString = await storage.read(key: actionsListkey);
    if (actionsListString == null) return null;

    try {
      final actions =
          RoleActionsWrapperModel.fromJson(json.decode(actionsListString));

      return actions;
    } catch (_) {
      return null;
    }
  }

  Future<bool> get boundaryRefetched async {
    final isboundaryRefetchRequired =
        await storage.read(key: boundaryRefetchInKey);

    switch (isboundaryRefetchRequired) {
      case 'true':
        return false;
      default:
        return true;
    }
  }

  Future<void> setSelectedIndividual(String? individualId) async {
    if (individualId != null) {
      html.window.sessionStorage[selectedIndividualKey] = individualId;
    }

    await storage.write(
      key: selectedIndividualKey,
      value: individualId,
    );
  }

  // Note TO the app  as Trigger Manual Sync or Not
  Future<void> setManualSyncTrigger(bool isManualSync) async {
    await storage.write(
      key: manualSyncKey,
      value: isManualSync.toString(),
    );
  }

  Future<void> setAuthCredentials(AuthModel model) async {
    await storage.write(key: accessTokenKey, value: model.accessToken);
    await storage.write(key: refreshTokenKey, value: model.refreshToken);
    await storage.write(
      key: userObjectKey,
      value: json.encode(model.userRequestModel),
    );

    html.window.sessionStorage[userObjectKey] =
        json.encode(model.userRequestModel);
  }

  Future<void> setBoundaryRefetch(bool isboundaryRefetch) async {
    await storage.write(
      key: boundaryRefetchInKey,
      value: isboundaryRefetch.toString(),
    );

    html.window.sessionStorage[boundaryRefetchInKey] =
        json.encode(isboundaryRefetch.toString());
  }

  Future<void> setRoleActions(RoleActionsWrapperModel actions) async {
    await storage.write(
      key: actionsListkey,
      value: json.encode(actions),
    );

    html.window.sessionStorage[actionsListkey] =
        json.encode(json.encode(actions));
  }

  Future<void> setBackgroundService(bool isRunning) async {
    await storage.write(key: backgroundServiceKey, value: isRunning.toString());
  }

  Future<void> setHasAppRunBefore(bool hasRunBefore) async {
    await storage.write(key: hasAppRunBeforeKey, value: '$hasRunBefore');
  }

  // Note TO the app is in closed state or not
  Future<void> setAppInActive(bool isRunning) async {
    await storage.write(key: isAppInActiveKey, value: isRunning.toString());
  }

  Future<bool> get hasAppRunBefore async {
    final hasRun = await storage.read(key: hasAppRunBeforeKey);

    switch (hasRun) {
      case 'true':
        return true;
      default:
        return false;
    }
  }

  Future<void> deleteAll() async {
    await storage.deleteAll();
  }

  /*Sets the bool value of project setup as true once project data is downloaded*/
  Future<void> setProjectSetUpComplete(String key, bool value) async {
    await storage.write(
      key: key,
      value: value.toString(),
    );
    html.window.sessionStorage[key] = json.encode(value.toString());
  }

  Future<void> setSelectedProject(ProjectModel projectModel) async {
    print("SELECT the CODE");
    await storage.write(
      key: selectedProjectKey,
      value: projectModel.toJson(),
    );
    html.window.sessionStorage[selectedProjectKey] =
        json.encode(projectModel.toJson());
  }

  /*Checks for project data loaded or not*/
  Future<bool> isProjectSetUpComplete(String projectId) async {

    print(html.window.sessionStorage[selectedProjectKey]);
    print("--------------");
    final isProjectSetUpComplete = kIsWeb ?  html.window.sessionStorage[selectedProjectKey] != null  :  await storage.read(key: projectId);
print(isProjectSetUpComplete);
 
 return  (isProjectSetUpComplete != null) ? true: false ;
  }
}
