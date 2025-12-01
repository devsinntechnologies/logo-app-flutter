import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/screens/Splash_screen.dart';
import 'package:logo_app_flutter/screens/home_screen.dart';
import 'package:logo_app_flutter/services/internet_checker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://sobkonycxgkklpmxpphn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvYmtvbnljeGdra2xwbXhwcGhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5NjY2NDAsImV4cCI6MjA3OTU0MjY0MH0.oGf4XMlK73KrVVE1EULXMoZlwN4kf5gWUdz5sKZaGcw',
    
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
        debugShowCheckedModeBanner: false,
        title: 'Auto Design Module',
        home: InternetChecker(
            child:  HomeScreen(),
        ),
        // home: VideoSplashScreen(),

      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:logo_app_flutter/provider/selected_color_provider.dart';
// import 'package:logo_app_flutter/screens/home_screen.dart';
// import 'package:logo_app_flutter/services/internet_checker.dart';
// import 'package:provider/provider.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => SelectedColorProvider()),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Auto Design Module',
//         home: InternetChecker(
//             child: const HomeScreen()
//         ),
//       ),
//     );
//   }
// }