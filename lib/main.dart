import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'ui_blocs/page_bloc.dart';
import 'ui_blocs/theme_cubit.dart';
import 'ui_blocs/mqtt_bloc.dart';
import 'ui_blocs/app_bloc.dart';
import 'ui_blocs/remote_ble_bloc.dart';
// import 'health_dashboard/bloc/health_bloc.dart';
// import 'health_dashboard/bloc/health_event.dart';services/ruuvi_b
import 'services/ruuvi_bloc/ruuvi_bloc.dart';
import 'services/ruuvi_analyzer.dart';
import 'pages/main_app_page.dart';
import 'gui_adapter/service_adapter.dart';
import 'check_platform.dart';

String API_KEY = "AIzaSyB9puHJBfrFuNNoFYBHXvUQFpO6kE7W4eQ";
String PROJECT_ID = "https://auth-2b7d3-default-rtdb.firebaseio.com";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceAdapter.initInstance();

 // final AuthRestService authService = AuthRestService(apiKey: API_KEY);
 // final TraceRestService userService = TraceRestService(baseUrl: PROJECT_ID, authService: authService);
 //
 //  final Map<String,dynamic> tokens = await authService.signInAnonymously();
 //  userService.setTokens(tokens["idToken"], tokens["refreshToken"]);

  // runApp(/*const*/ MyApp(authService: authService,userService: userService));
  runApp(const RemoteBleApp());
}

class RemoteBleApp extends StatelessWidget {

  // final AuthRestService authService;
  // final TraceRestService userService;
  //
  // const MyApp({super.key, required this.authService, required this.userService});
  const RemoteBleApp({super.key});

  @override
  Widget build(BuildContext context) {

    getAppInfo();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(create: (context) => AppBloc()),
          BlocProvider(create: (context) => PageBloc()),
          BlocProvider(create: (context) => MqttBloc()),
          BlocProvider(create: (context) => RemoteBleBloc()),
          //BlocProvider(create: (context) => TraceBloc()),
          //@BlocProvider(create: (context) => HealthBloc()..add(LoadHealthData())),
          BlocProvider(create: (context) =>RuuviBloc()),
          //BlocProvider(create: (context) => TraceDbBloc(userService)..add(LoadTraceDb())),
          // BlocProvider(
          //   create: (context) => TraceDbBloc(
          //     TraceRestService(
          //       baseUrl: 'https://auth-2b7d3-default-rtdb.firebaseio.com',
          //       secret: 'SApU4FSjuoIdx9M5uUrdqWMndbASnTWWpClHs61a',
          //     ),
          //   ),
          // ),
          //BlocProvider(create: (_) => TraceBloc()..add(LoadTraces())),
        ],
        //child: const MainAppPage(),
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'BLE Control Panel',
              debugShowCheckedModeBanner: false,
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              themeMode: themeMode,
              home: const MainAppPage(),
            );
          },
        ),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[50],
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }

  Future<void> getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String _appName = packageInfo.appName;
    String _packageName = packageInfo.packageName;
    String _version = packageInfo.version;
    String _buildNumber = packageInfo.buildNumber;
    String _buildSignature = packageInfo.buildSignature;
    String _installerStore = packageInfo.installerStore ?? 'not available';
    String _targetPlatform = platform();

    ServiceAdapter.instance()?.setAppInfo(_targetPlatform, _appName, _packageName, _version, _buildNumber, _buildSignature, _installerStore);

    print ('[$_appName][$_packageName][$_version][$_buildNumber][$_buildSignature][$_installerStore][$_targetPlatform]');
  }

}