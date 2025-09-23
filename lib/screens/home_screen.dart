import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logo_app_flutter/components/GridButtons/auto_design_button.dart';
import 'package:logo_app_flutter/components/GridButtons/create_logo_button.dart';
import 'package:logo_app_flutter/components/GridButtons/my_design_button.dart';
import 'package:logo_app_flutter/components/GridButtons/my_logo_button.dart';
import 'package:logo_app_flutter/components/drawer_items.dart';
import 'package:logo_app_flutter/models/logo_state_data.dart';
import 'package:logo_app_flutter/provider/banner_ad_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});


  BannerAd? _bannerAd;

  @override
  Widget build(BuildContext context) {
    final bannerProvider = Provider.of<BannerAdProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB388FF), Color(0xFF8E24AA)],
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
                        icon: Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Logo Maker",
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: const [
                  DrawerItem(icon: Icons.workspace_premium, text: "Get PRO"),
                  DrawerItem(icon: Icons.image, text: "My Logo"),
                  DrawerItem(icon: Icons.design_services, text: "My Design"),
                  DrawerItem(icon: Icons.language, text: "Language"),
                  DrawerItem(icon: Icons.apps, text: "More Apps"),
                  DrawerItem(icon: Icons.share, text: "Share"),
                  DrawerItem(icon: Icons.privacy_tip, text: "Privacy Policy"),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder:
                    (context) => IconButton(
                      icon: Image.asset(
                        "assets/icons/menu.png",
                        width: 30,
                        height: 30,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
              ),
              Center(
                child: Text(
                  'Logo Maker',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Image.asset("assets/icons/crown.png", width: 30, height: 30),
              // SizedBox(width: 1),
            ],
          ),
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
                // color: const Color(0xFF5FD3F3),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF96C8B), // Pinkish red
                    Color(0xFFF99FBC),
                  ],
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
                crossAxisAlignment: CrossAxisAlignment.center, // optional
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/color-palette.png',
                        width: 40,
                        height: 40,
                      ),
                      SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            textAlign: TextAlign.start,
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
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CreateLogoButton(),
              AutoDesignButton(),
            ],
          ),
          SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [MyLogoButton(), MyDesignButton()],
          ),
        ],
      ),
      bottomNavigationBar:
          bannerProvider.isLoaded && bannerProvider.bannerAd != null
              ? SizedBox(
                height: bannerProvider.bannerAd!.size.height.toDouble(),
                width: bannerProvider.bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: bannerProvider.bannerAd!),
              )
              : SizedBox.shrink(),
    );
  }
}
