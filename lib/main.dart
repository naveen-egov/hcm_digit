import 'dart:html';

import 'package:digit_components/digit_components.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hcm_digit/app.dart';
import 'package:hcm_digit/button.dart';
import 'package:hcm_digit/data/local_store/app_shared_preferences.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/app_configuration.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/localization.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/project.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/row_versions.dart';
import 'package:hcm_digit/data/local_store/no_sql/schema/service_registry.dart';
import 'package:hcm_digit/router/app_navigator_observer.dart';
import 'package:hcm_digit/router/app_router.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:hcm_digit/user_profile.dart';
import 'package:hcm_digit/utils/environment_config.dart';
import 'package:hcm_digit/utils/utils.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'models/data_model.init.dart';

late Dio _dio;

late Box<ServiceRegistry> serviceBox;

late Box<AppConfiguration> appConfigBox;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSharedPreferences().init();
  DigitUi.instance.initThemeComponents();
  await Hive.initFlutter();
  await envConfig.initialize();
  await initializeAllMappers();
  Hive.registerAdapter(ServiceRegistryAdapter());
  Hive.registerAdapter(ActionsAdapter());
  Hive.registerAdapter(AppConfigurationAdapter());
  Hive.registerAdapter(LanguagesAdapter());
  Hive.registerAdapter(BackendInterfaceAdapter());
  Hive.registerAdapter(RowVersionListAdapter());
  Hive.registerAdapter(GenderOptionsAdapter());
  Hive.registerAdapter(InterfacesAdapter());
  Hive.registerAdapter(LocalizationWrapperAdapter());
  Hive.registerAdapter(LocalizationAdapter());
  Hive.registerAdapter(ProjectModelAdapter());

  // await Constants()I.initialize('');
  // Open all boxes
  print("---TWICW---");
  serviceBox = await Hive.openBox<ServiceRegistry>('serviceRegistryBox');
  await Hive.openBox<RowVersionList>('rowVersionBox');
  await Hive.openBox<LocalizationWrapper>('localizationBox');
  await Hive.openBox<ProjectModel>('projectBox');
  appConfigBox = await Hive.openBox<AppConfiguration>('AppConfigurationBox');
  // Open a box for storing `Actions` if you want to store them separately (optional)

  runApp(
    MainApplication(
      appRouter: AppRouter(),
      sbox: serviceBox,
      abox: appConfigBox,
    ),
  );
}

void extractPathParams(String url) async {
  // Parse the URL
  Uri uri = Uri.parse(url);

// print(uri);
  // Extract path segments
  List<String> pathSegments = uri.pathSegments;

  // Extract query parameters
  Map<String, String> queryParams = uri.queryParameters;
  print(queryParams.entries.lastOrNull?.value);
  if (queryParams.entries.lastOrNull?.value != null) {
    print("API ca;;");
    print(await postFetchUserInfo(
      queryParams.entries.lastOrNull!.value,
      '_UgkpFCOsqoxsbLfywjXFuVRYZaHeYK6l0GmxMg3Rg8',
      'http://localhost:3000/userprofile',
      'authorization_code',
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    extractPathParams(html.window.location.href);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SignInWithEsignetButton(
              buttonConfig: ButtonConfig(),
              oidcConfig: OidcConfig(
                authorizeUri: 'https://esignet.collab.mosip.net/authorize',
                redirectUri: 'http://localhost:3000/userprofile',
                clientId: '_UgkpFCOsqoxsbLfywjXFuVRYZaHeYK6l0GmxMg3Rg8',
                scope: 'openid profile',
              ),
            ),
          ],
        ),
      ),
//  / This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
