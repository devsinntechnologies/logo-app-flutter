import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/screens/download_logo.dart';
import 'package:logo_app_flutter/screens/home_screen.dart';
import 'package:logo_app_flutter/services/internet_checker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            child: 
        // DownloadLogo(svgLogo: "svgLogo", companyName: "companyName", sloganName: "sloganName")
            const HomeScreen()
        ),
      ),
    );
  }
}