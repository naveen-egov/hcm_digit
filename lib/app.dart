import 'package:digit_components/digit_components.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hcm_digit/blocs/app_initialization/app_initialization.dart';
import 'package:hcm_digit/blocs/auth/auth.dart';
import 'package:hcm_digit/blocs/delivery_intervention/deliver_intervention.dart';
import 'package:hcm_digit/blocs/localization/app_localization.dart';
import 'package:hcm_digit/blocs/localization/localization.dart';
import 'package:hcm_digit/data/local_store/app_shared_preferences.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/app_configuration.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/service_registry.dart';
import 'package:hcm_digit/data/remote_client.dart';
import 'package:hcm_digit/data/repositories/remote/auth.dart';
import 'package:hcm_digit/data/repositories/remote/localization.dart';
import 'package:hcm_digit/data/repositories/remote/mdms.dart';
import 'package:hcm_digit/main.dart';
import 'package:hcm_digit/router/app_navigator_observer.dart';
import 'package:hcm_digit/router/app_router.dart';
import 'package:hcm_digit/utils/constants.dart';
import 'package:hcm_digit/utils/environment_config.dart';
import 'package:hcm_digit/utils/remote_provider.dart';
import 'package:hcm_digit/utils/utils.dart';
import 'package:hcm_digit/widgets/network_manager_provider_wrapper.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'blocs/project_selection/project.dart';

class MainApplication extends StatefulWidget {
  final AppRouter appRouter;
  final Box<ServiceRegistry> sbox;
  final Box<AppConfiguration> abox;
  const MainApplication({
    super.key,
    required this.appRouter,
    required this.sbox,
    required this.abox
  });

  @override
  State<StatefulWidget> createState() {
    return MainApplicationState();
  }
}

class MainApplicationState extends State<MainApplication>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AppInitializationBloc(
              mdmsRepository: MdmsRepository(DioClient().dio,widget.sbox,),
              sbox:widget.sbox,
              abox:widget.abox
            )..add(const AppInitializationSetupEvent()),
        child: NetworkManagerProviderWrapper(
          dio: DioClient().dio,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) {
                  return UserBloc(
                    const UserEmptyState(),
                    userRemoteRepository: context
                        .read<RemoteRepository<UserModel, UserSearchModel>>(),
                  );
                },
              ),
                 BlocProvider(
                          create: (context) => ProductVariantBloc(
                            const ProductVariantEmptyState(),
                            context.read<RemoteRepository<ProductVariantModel,
                                ProductVariantSearchModel>>(),
                            context.read<RemoteRepository<ProjectResourceModel,
                                ProjectResourceSearchModel>>(),
                          ),
                        ),
                 BlocProvider(
                create: (context) =>  DeliverInterventionBloc(
                  const DeliverInterventionState(),
                  taskRepository: context.read<RemoteRepository<TaskModel, TaskSearchModel>>(),
                ),
              ),
    
              BlocProvider(
                create: (ctx) => BoundaryBloc(
                  const BoundaryState(),
                  boundaryRepository: BoundaryRemoteRepository(
                    DioClient().dio,
                    actionMap: Constants().getActionMap(widget.sbox.values.toList())[DataModelType.boundary],
                  ),
                ),
              ),
              BlocProvider(
                create: (ctx) => AuthBloc(
                  authRepository: ctx.read(),
                  mdmsRepository: MdmsRepository(DioClient().dio,widget.sbox ),
                  individualRemoteRepository: ctx.read<
                      RemoteRepository<IndividualModel,
                          IndividualSearchModel>>(),
                )..add(
                    AuthAutoLoginEvent(
                      tenantId: envConfig.variables.tenantId,
                    ),
                  ),
              ),
            ],
            child: BlocBuilder<AppInitializationBloc, AppInitializationState>(
              builder: (context, appConfigState) {
                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (appConfigState is! AppInitialized) {
                      return const MaterialApp(
                        home: Scaffold(
                          body: Center(
                            child: Text('Loading'),
                          ),
                        ),
                      );
                    }

                    final appConfig = appConfigState.appConfiguration;

                    final localizationModulesList = appConfig.backendInterface;
                    
             
           
                    var firstLanguage;
                    firstLanguage = appConfig.languages.last.value;
                     
                    final languages = appConfig.languages;
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                            create: (localizationModulesList != null &&
                                    firstLanguage != null)
                                ? (context) => LocalizationBloc(
                                      const LocalizationState.initial(),
                                      LocalizationRepository(DioClient().dio),
                                    )..add(LocalizationEvent.onLoadLocalization(
                                        module: localizationModulesList
                                            .interfaces
                                            .where((element) =>
                                                element.type ==
                                                Modules.localizationModule)
                                            .map((e) => e.name.toString())
                                            .join(',')
                                            .toString(),
                                        tenantId: 'mz',
                                        locale: firstLanguage,
                                      ))
                                : (context) => LocalizationBloc(
                                      const LocalizationState.initial(),
                                      LocalizationRepository(DioClient().dio),
                                    )),
                      ],
                      child: BlocBuilder<LocalizationBloc, LocalizationState>(
                        builder: (context, langState) {
                          final selectedLocale =
                              AppSharedPreferences().getSelectedLocale ??
                                  firstLanguage;

                          return MaterialApp.router(
                            debugShowCheckedModeBanner: false,
                            builder: (context, child) {
                              const SizedBox.shrink();

                              return Banner(
                                  message: '',
                                  location: BannerLocation.topEnd,
                                  color: Colors.red,
                                  child: child);
                            },
                            supportedLocales: languages != null
                                ? languages.map((e) {
                                    final results = e.value.split('_');
                       
                                    return results.isNotEmpty
                                        ? Locale(results.first, results.last)
                                        : firstLanguage;
                                  })
                                : [firstLanguage],
                            localizationsDelegates: [AppLocalizations.delegate],
                            locale: languages != null
                                ? Locale(
                                    selectedLocale!.split("_").first,
                                    selectedLocale.split("_").last,
                                  )
                                : firstLanguage,
                            theme: DigitTheme.instance.mobileTheme,
                            routeInformationParser:
                                widget.appRouter.defaultRouteParser(),
                            scaffoldMessengerKey:
                                GlobalKey<ScaffoldMessengerState>(),
                            routerDelegate: AutoRouterDelegate.declarative(
                              widget.appRouter,
                              navigatorObservers: () => [AppRouterObserver()],
                              routes: (handler) => authState.maybeWhen(
                                orElse: () => [
                                  const UnauthenticatedRouteWrapper(),
                                ],
                                authenticated: (_, __, ___, ____, _____) => [
                                  AuthenticatedRouteWrapper(
                                    sbox: widget.sbox,
                                    abox: widget.abox,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ));
  }
}
