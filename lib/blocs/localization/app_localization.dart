import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hcm_digit/blocs/localization/localization.dart';
import 'package:universal_html/html.dart' as html;

import '../../models/localization/localization_model.dart';
import '../../services/local_storage.dart';
import 'app_localizations_delegate.dart';

class AppLocalizations {
  final Locale? locale;
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  AppLocalizations(this.locale);
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static List<LocalizationMessageModel> localizedStrings =
      <LocalizationMessageModel>[];
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  Future<List<LocalizationMessageModel>?> getLocalizationLabels() async {
    dynamic localLabelResponse;
    if (kIsWeb) {
      localLabelResponse = html.window.sessionStorage[
          '${locale?.languageCode}_${locale?.countryCode}' ?? ''];
    } else {
      localLabelResponse = await storage.read(
          key: '${locale?.languageCode}_${locale?.countryCode}');
    }
    await Future.delayed(const Duration(seconds: 1));
    if (localLabelResponse != null && localLabelResponse.trim().isNotEmpty) {
 

      return localizedStrings = jsonDecode(localLabelResponse)
          .map<LocalizationMessageModel>(
              (e) => LocalizationMessageModel.fromJson(e))
          .toList();
    } else {
      if(scaffoldMessengerKey.currentContext != null){
      localizedStrings = BlocProvider.of<LocalizationBloc>(
                  scaffoldMessengerKey.currentContext!)
              .state
              .maybeWhen(
                  orElse: () => [],
                  loaded: (List<LocalizationMessageModel>? localization) {
                    return localization;
                  }) ??
          [];

      return localizedStrings;
      }
    }
  }

  Future<bool> load() async {
    if (true) {
      await getLocalizationLabels();
      return true;
    } 
  }

  translate(
    String localizedValues,
  ) {
    

    var index =
        localizedStrings.indexWhere((medium) => medium.code == localizedValues);
    return index != -1 ? localizedStrings[index].message : localizedValues;
  }
}
