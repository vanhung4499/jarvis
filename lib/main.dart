import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/data/migrate.dart';
import 'package:jarvis/helper/constant.dart';
import 'package:jarvis/helper/http.dart' as httpx;
import 'package:jarvis/helper/logger.dart';
import 'package:jarvis/helper/path.dart';
import 'package:jarvis/helper/platform.dart';
import 'package:jarvis/lang/lang.dart';
import 'package:jarvis/page/auth/forgot_password.dart';
import 'package:jarvis/page/auth/reset_password.dart';
import 'package:jarvis/page/auth/signin_screen.dart';
import 'package:jarvis/page/auth/signup_screen.dart';
import 'package:jarvis/page/auth/verify_code.dart';
import 'package:jarvis/page/component/theme/custom_theme.dart';
import 'package:jarvis/page/component/theme/theme.dart';
import 'package:jarvis/page/component/transition_resolver.dart';
import 'package:jarvis/repo/cache_repo.dart';
import 'package:jarvis/repo/data/cache_data.dart';
import 'package:jarvis/repo/data/setting_data.dart';
import 'package:jarvis/repo/setting_repo.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  httpx.HttpClient.init();

  // Initialize the path and obtain system-related documents and cache directories
  await PathHelper().init();

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.library == 'rendering library' ||
        details.library == 'image resource service') {
      return;
    }

    Logger.instance.e(
      details.summary,
      error: details.exception,
      stackTrace: details.stack,
    );
    Logger.instance.d(details.stack);
  };

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    if (PlatformTool.isWindows() ||
        PlatformTool.isLinux() ||
        PlatformTool.isMacOS()) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      var path = absolute(join(PathHelper().getHomePath, 'databases'));
      databaseFactory.setDatabasesPath(path);
    }
  }

  // Database connection
  final db = await databaseFactory.openDatabase('system.db',
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onCreate: initDatabase,
        onOpen: (db) async {
          Logger.instance.i('Database storage opened: ${db.path}');
        },
      ));

  // Loading setting
  final settingProvider = SettingDataProvider(db);
  await settingProvider.loadSettings();

  // Crate data repository
  final settingRepo = SettingRepository(settingProvider);
  final cacheRepo = CacheRepository(CacheDataProvider(db));

  runApp(Phoenix(
    child: MyApp(
      settingRepo: settingRepo,
      cacheRepo: cacheRepo,
    ),
  ));
}

class MyApp extends StatefulWidget {
  // Page Routing
  late final GoRouter _router;

  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();
  final FlutterLocalization localization = FlutterLocalization.instance;

  MyApp({
    super.key,
    required this.settingRepo,
    required this.cacheRepo,
  }) {
    var apiServerToken = settingRepo.get(settingAPIServerToken);

    final shouldLogin = (apiServerToken == null || apiServerToken == '');

    _router = GoRouter(
      initialLocation: shouldLogin ? '/login' : '/',
      observers: [
        BotToastNavigatorObserver(),
      ],
      navigatorKey: _rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              transitionResolver(SignInScreen(setting: settingRepo)),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => transitionResolver(
            SignupScreen(
              setting: settingRepo,
              email: state.queryParameters['email'],
            ),
          ),
        ),
        GoRoute(
          path: '/forgot-password',
          pageBuilder: (context, state) => transitionResolver(
            ForgotPasswordScreen(
              setting: settingRepo,
              email: state.queryParameters['email'],
            ),
          ),
        ),
        GoRoute(
          path: '/reset-password',
          pageBuilder: (context, state) => transitionResolver(
            ResetPasswordScreen(
              setting: settingRepo,
            ),
          ),
        ),
        GoRoute(
          path: '/verify-code',
          pageBuilder: (context, state) => transitionResolver(
            VerifyCodeScreen(
              setting: settingRepo,
            ),
          ),
        ),
      ],
    );
  }

  final SettingRepository settingRepo;
  final CacheRepository cacheRepo;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    widget.localization.init(
      mapLocales: [
        const MapLocale('vi', AppLocale.vi),
        const MapLocale('en', AppLocale.en),
      ],
      // initLanguageCode: initLanguage == '' ? defaultLanguage : initLanguage,
      initLanguageCode: 'zh-CHS',
    );

    widget.localization.onTranslatedLanguage = (Locale? locale) {
      setState(() {});
    };

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
            create: (context) => widget.settingRepo),
        RepositoryProvider<CacheRepository>(
            create: (context) => widget.cacheRepo),
      ],
      child: ChangeNotifierProvider(
          create: (context) => AppTheme.get()
            ..mode = AppTheme.themeModeFormString(
                widget.settingRepo.stringDefault(settingThemeMode, 'system')),
          builder: (context, _) {
            final appTheme = context.watch<AppTheme>();
            return Sizer(
              builder: (context, orientation, deviceType) {
                return MaterialApp.router(
                  title: 'Jarvis',
                  themeMode: appTheme.mode,
                  theme: createLightThemeData(),
                  darkTheme: createDarkThemeData(),
                  debugShowCheckedModeBanner: false,
                  builder: (context, child) {
                    // The global font fixed size is set here and does not change with the system settings.
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: TextScaler.noScaling),
                      child: BotToastInit()(context, child),
                    );
                  },
                  routerConfig: widget._router,
                  supportedLocales: widget.localization.supportedLocales,
                  localizationsDelegates:
                      widget.localization.localizationsDelegates,
                );
              },
            );
          }),
    );
  }
}

ThemeData createLightThemeData() {
  return ThemeData.light(useMaterial3: true).copyWith(
    extensions: [CustomColors.light],
    appBarTheme: const AppBarTheme(
      // backgroundColor: Color.fromARGB(255, 250, 250, 250),
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    iconButtonTheme: PlatformTool.isMacOS()
        ? IconButtonThemeData(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
          )
        : null,
    dividerColor: Colors.transparent,
    dialogBackgroundColor: Colors.white,
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(
            255, 9, 185, 85), // This is a custom color variable
      ),
    ),
  );
}

ThemeData createDarkThemeData() {
  return ThemeData.dark(useMaterial3: true).copyWith(
    extensions: [CustomColors.dark],
    appBarTheme: const AppBarTheme(
      // backgroundColor: Color.fromARGB(255, 48, 48, 48),
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    iconButtonTheme: PlatformTool.isMacOS()
        ? IconButtonThemeData(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
          )
        : null,
    dividerColor: Colors.transparent,
    dialogBackgroundColor: const Color.fromARGB(255, 48, 48, 48),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(
            255, 9, 185, 85), // This is a custom color variable
      ),
    ),
  );
}
