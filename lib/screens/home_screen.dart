import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logo_app_flutter/components/GridButtons/auto_design_button.dart';
import 'package:logo_app_flutter/components/GridButtons/create_logo_button.dart';
import 'package:logo_app_flutter/components/GridButtons/my_design_button.dart';
import 'package:logo_app_flutter/components/GridButtons/my_logo_button.dart';
import 'package:logo_app_flutter/components/drawer_items.dart';
import 'package:logo_app_flutter/provider/banner_ad_provider.dart';
import 'package:logo_app_flutter/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  BannerAd? _bannerAd;

  @override
  Widget build(BuildContext context) {
    final bannerProvider = Provider.of<BannerAdProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        ),
        title: Text(
          'Logo Maker',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color:
                      themeProvider.isDarkMode ? Colors.yellow : Colors.grey[700],
                  size: 28,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        themeProvider.isDarkMode
                            ? 'Dark mode enabled'
                            : 'Light mode enabled',
                      ),
                      duration: const Duration(milliseconds: 1000),
                    ),
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Image.asset("assets/icons/crown.png", width: 28, height: 28),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [const Color(0xFF424242), const Color(0xFF616161)]
                      : [const Color(0xFFB388FF), const Color(0xFF8E24AA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/icons/award.png", width: 100),
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Logo Maker",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const DrawerItem(icon: Icons.workspace_premium, text: "Get PRO"),
            const DrawerItem(icon: Icons.image, text: "My Logo"),
            const DrawerItem(icon: Icons.design_services, text: "My Design"),
            const DrawerItem(icon: Icons.language, text: "Language"),
            const DrawerItem(icon: Icons.apps, text: "More Apps"),
            const DrawerItem(icon: Icons.share, text: "Share"),
            const DrawerItem(icon: Icons.privacy_tip, text: "Privacy Policy"),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              SnackBar snackBar = const SnackBar(
                content: Text('Template button pressed!'),
                duration: Duration(milliseconds: 100),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: Container(
              width: 330,
              height: 100,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF96C8B), Color(0xFFF99FBC)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 3,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset('assets/icons/color-palette.png',
                      width: 40, height: 40),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Template',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Edit and Save Logo Template',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [CreateLogoButton(), AutoDesignButton()],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [MyLogoButton(), MyDesignButton()],
          ),
        ],
      ),
      bottomNavigationBar: bannerProvider.isLoaded && bannerProvider.bannerAd != null
          ? SizedBox(
              height: bannerProvider.bannerAd!.size.height.toDouble(),
              width: bannerProvider.bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: bannerProvider.bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
