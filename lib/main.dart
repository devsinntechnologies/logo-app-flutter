import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logo_app_flutter/config/environment.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/screens/Splash_screen.dart';
import 'package:logo_app_flutter/screens/home_screen.dart';
import 'package:logo_app_flutter/services/internet_checker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Validate environment configuration
  Environment.validate();
  Environment.printConfig();
  
  // Initialize Mobile Ads
  MobileAds.instance.initialize();
  
  // Configure test devices only in development mode
  if (!Environment.isProduction && Environment.testDeviceIds.isNotEmpty) {
    final requestConfig = RequestConfiguration(
      testDeviceIds: Environment.testDeviceIds,
    );
    MobileAds.instance.updateRequestConfiguration(requestConfig);
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
  @override
  void initState() {
    super.initState();

    _session = _supabase.auth.currentSession;

    _authSubscription = _supabase.auth.onAuthStateChange.listen((authState) {
      final session = authState.session;

      setState(() {
        _session = session;
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
      ],
      child: MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        darkTheme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        title: 'Auto Design Module',
        home: InternetChecker(
          child: HomeScreen(),
          // child: SignUpScreen(),
        ),
        // home: SplashScreen(),
      ),
    );
  }
}
