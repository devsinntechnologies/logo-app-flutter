import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logo_app_flutter/config/environment.dart';
import 'package:logo_app_flutter/provider/business_info_provider.dart';
import 'package:logo_app_flutter/provider/gallery_provider.dart';
import 'package:logo_app_flutter/provider/logo_design_provider.dart';
import 'package:logo_app_flutter/provider/logo_generation_provider.dart';
import 'package:logo_app_flutter/provider/logo_results_provider.dart';
import 'package:logo_app_flutter/provider/locale_provider.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/theme_provider.dart';
import 'package:logo_app_flutter/screens/dashboard_screen.dart';
import 'package:logo_app_flutter/screens/home_screen.dart';
import 'package:logo_app_flutter/screens/splash_screen.dart';
import 'package:logo_app_flutter/services/internet_checker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate environment configuration
  Environment.validate();
  Environment.printConfig();

  // Initialize Mobile Ads (only on supported platforms)
  if (!kIsWeb) {
    MobileAds.instance.initialize();

    // Configure test devices only in development mode
    if (!Environment.isProduction && Environment.testDeviceIds.isNotEmpty) {
      final requestConfig = RequestConfiguration(
        testDeviceIds: Environment.testDeviceIds,
      );
      MobileAds.instance.updateRequestConfiguration(requestConfig);
    }
  }

  // Initialize Supabase with environment configuration
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _supabase = Supabase.instance.client;
  late final StreamSubscription<AuthState> _authSubscription;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _session = _supabase.auth.currentSession;

    _authSubscription = _supabase.auth.onAuthStateChange.listen((authState) {
      final session = authState.session;

      setState(() {
        // _session = session;
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedColorProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BusinessInfoProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => LogoDesignProvider()),
        ChangeNotifierProvider(create: (_) => LogoGenerationProvider()),
        ChangeNotifierProvider(create: (_) => LogoResultsProvider()),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.dark().textTheme,
            ),
          ),
          themeMode: context.watch<ThemeProvider>().themeMode,
          debugShowCheckedModeBanner: false,
          title: 'Auto Design Module',
          locale: context.watch<LocaleProvider>().locale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: InternetChecker(
            // child: HomeScreen(),
            // child: HomeScreen(),
            child: DashboardScreen(),
            // child: SignUpScreen(),
          ),
          // home: SplashScreen(),
        );
      }),
    );
  }
}
