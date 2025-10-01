import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logo_app_flutter/provider/banner_ad_provider.dart';
import 'package:logo_app_flutter/provider/interestitial_ad.dart';
import 'package:logo_app_flutter/provider/selected_color_provider.dart';
import 'package:logo_app_flutter/provider/theme_provider.dart';
import 'package:logo_app_flutter/provider/undo_provider.dart' show UndoProvider;
import 'package:logo_app_flutter/screens/home_screen.dart';
import 'package:logo_app_flutter/services/internet_checker.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logo_app_flutter/provider/smart_interstitial_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //! They halts running app on web
  //? Ensures Binding For Widgets in
  //? flutter is initalized before app runs
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['A56FA8A635767673855076C2769DCF57']),
  );
  //? Google Mobile Ads SDK initalizer
  await MobileAds.instance.initialize();
  runApp(
    // DevicePreview(
      // builder: (context) =>
    MyApp(),
    // enabled: !kReleaseMode )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UndoProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BannerAdProvider()),
        ChangeNotifierProvider(create: (_) => InterestitialAdProvider()),
        ChangeNotifierProvider(create: (_) => SmartInterstitialManager()),
        ChangeNotifierProxyProvider<UndoProvider, SelectedColorProvider>(
          create: (context) {
            final undoProvider = Provider.of<UndoProvider>(
              context,
              listen: false,
            );
            final colorProvider = SelectedColorProvider();
            colorProvider.setUndoProvider(undoProvider);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              colorProvider.initializeUndoSystem();
              Provider.of<SmartInterstitialManager>(
                context,
                listen: false,
              ).initialize();
            });
            return colorProvider;
          },
          update: (context, undoProvider, colorProvider) {
            colorProvider?.setUndoProvider(undoProvider);
            return colorProvider!;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Auto Design Module',
            theme: value.currentTheme,
            home: InternetChecker(child: HomeScreen()),
          );
        },
      ),
    );
  }
}
