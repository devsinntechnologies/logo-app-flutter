import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logo_app_flutter/components/GridButtons/auto_design_button.dart';
import 'package:logo_app_flutter/components/GridButtons/create_logo_button.dart';
import 'package:logo_app_flutter/components/GridButtons/my_design_button.dart';
import 'package:logo_app_flutter/components/GridButtons/my_logo_button.dart';
import 'package:logo_app_flutter/components/drawer_items.dart';
import 'package:logo_app_flutter/components/google_alert.dart';
import 'package:logo_app_flutter/components/show_language_dialog.dart';
import 'package:logo_app_flutter/components/show_theme_dialog.dart';
import 'package:logo_app_flutter/generated/l10n.dart';

import 'package:logo_app_flutter/screens/design_input_screen.dart';
import 'package:logo_app_flutter/screens/download_logo.dart';
import 'package:logo_app_flutter/screens/google_sign_in_button.dart';
import 'package:logo_app_flutter/screens/my_account_screen.dart';
import 'package:logo_app_flutter/screens/my_design_screen.dart';
import 'package:logo_app_flutter/services/ad_mob_service.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();

    // 🔹 Load banner from service (only on supported platforms)
    _bannerAd = AdMobService.bannerAd(
      size: AdSize.banner,
      onLoaded: (_) {
        setState(() {
          _isBannerLoaded = true;
        });
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              height: (MediaQuery.of(context).size.height > 500) ? 260 : 150,
              decoration: BoxDecoration(
                  // color: Color(0xff16182D),

                  // gradient: LinearGradient(
                  //   colors: [
                  //     Color(0xFF16182D),
                  //     Color(0xFF2A2D4F),
                  //   ],
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  // ),
                  gradient: ThemeColors.customGradient),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  SizedBox(height: 30),
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage(
                      "assets/icons/SmartLogoMaker.png",
                    ),
                    // child: Image.asset(
                    //   "assets/icons/SmartLogoMaker.png",
                    //   width:
                    //       (MediaQuery.of(context).size.height > 500) ? 100 : 70,
                    // ),
                  ),
                  // if(MediaQuery.of(context).size.height > 500)
                  // const SizedBox(height: 30),
                  // if(MediaQuery.of(context).size.height > 500)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            S.of(context).smartLogoMakerText,
                            style: Theme.of(
                              context,
                            )
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  // DrawerItem(icon: Icons.workspace_premium, text: "Get PRO"),
                  // DrawerItem(icon: Icons.image, text: "My Logo"),

                  DrawerItem(
                    icon: Icons.design_services,
                    text: S.of(context).myDesign,
                    onTap: () {
                      final user = Supabase.instance.client.auth.currentUser;
                      final GlobalKey canvasKey = GlobalKey();

                      if (user != null) {
                        // User is logged in → navigate normally
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MyDesignScreen(canvasKey: canvasKey),
                          ),
                        );

                        // Show interstitial ad
                        AdMobService.loadInterstitial(
                          onLoaded: (InterstitialAd ad) {
                            ad.fullScreenContentCallback =
                                FullScreenContentCallback(
                              onAdDismissedFullScreenContent: (ad) =>
                                  ad.dispose(),
                              onAdFailedToShowFullScreenContent: (ad, error) =>
                                  ad.dispose(),
                            );
                            ad.show();
                          },
                        );
                      } else {
                        // User not logged in → show login/signup dialog
                        showCustomGoogleDialog(context);
                      }
                    },
                  ),

                  DrawerItem(
                    icon: Icons.create,
                    text: S.of(context).createLogo,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DownloadLogo(
                                  svgLogo: "",
                                  companyName: "",
                                  sloganName: "")));
                    },
                  ),
                  DrawerItem(
                    icon: Icons.auto_awesome,
                    text: S.of(context).autoDesign,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DesignInputScreen()),
                      );
                    },
                  ),
                  DrawerItem(
                    icon: Icons.language,
                    text: S.of(context).language,
                    onTap: () => showLanguageDialog(context),
                  ),
                  // DrawerItem(icon: Icons.apps, text: "More Apps"),
                  DrawerItem(
                    icon: Icons.share,
                    text: S.of(context).share,
                    onTap: () {
                      const appLink =
                          'https://play.google.com/store/apps/details?id=com.devsinntechnologies.smartlogomaker&hl=en-US&ah=ZazxD_acLcZzxhvUTOIRv42CZBY';
                      Share.share('Check out this app: $appLink');
                    },
                  ),

                  DrawerItem(
                    icon: Icons.privacy_tip,
                    text: S.of(context).privacyPolicy,
                    onTap: () async {
                      final url = Uri.parse(
                          'https://docs.google.com/document/d/1HEu-XJJL8pMcrqdekHDNO4w3CESBqzvWmHdrHWTcOT4/edit?usp=sharing');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      } else {
                        // optional: handle error
                        print('Could not launch $url');
                      }
                    },
                  ),
                  DrawerItem(
                    icon: Icons.palette,
                    text: S.of(context).theme ?? "Theme",
                    onTap: () => showThemeDialog(context),
                  ),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: Image.asset(
                        "assets/icons/menu.png",
                        width: 30,
                        height: 30,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // horizontal scroll
                      child: Row(
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/logo_app.png',
                            height: 30,
                          ),
                          const SizedBox(
                              width: 5), // spacing between icon and text
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  0.45, // max 60% of screen
                            ),
                            child: Text(
                              S.of(context).smartLogoMaker,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withOpacity(0.87) ??
                                    Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GoogleSignInButton(),
                ],
              ),
              const SizedBox(height: 23),
              // GestureDetector(
              //   onTap: () {
              //     SnackBar snackBar = const SnackBar(
              //       content: Text('Template button pressed!'),
              //       duration: Duration(milliseconds: 100),
              //     );
              //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
              //   },
              //   child: Container(
              //     width: 330,
              //     height: 100,
              //     padding: const EdgeInsets.all(20),
              //     decoration: BoxDecoration(
              //       // color: const Color(0xFF5FD3F3),
              //       gradient: LinearGradient(
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //         colors: [
              //           Color(0xFFF96C8B), // Pinkish red
              //           Color(0xFFF99FBC),
              //         ],
              //       ),
              //       borderRadius: BorderRadius.circular(30),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.25),
              //           blurRadius: 10,
              //           spreadRadius: 3,
              //           offset: const Offset(2, 4),
              //         ),
              //       ],
              //     ),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.center, // optional
              //       children: [
              //         Row(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             Image.asset(
              //               'assets/icons/color-palette.png',
              //               width: 40,
              //               height: 40,
              //             ),
              //             SizedBox(width: 20),
              //             Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   textAlign: TextAlign.start,
              //                   'Template',
              //                   style: GoogleFonts.poppins(
              //                     color: Colors.white,
              //                     fontWeight: FontWeight.w600,
              //                     fontSize: 13,
              //                   ),
              //                 ),
              //                 Text(
              //                   'Edit and Save Logo Template',
              //                   style: GoogleFonts.poppins(
              //                     color: Colors.white,
              //                     fontWeight: FontWeight.normal,
              //                     fontSize: 13,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ],
              //         ),
              //         const Spacer(),
              //         Column(
              //           children: [
              //             const Icon(Icons.chevron_right, color: Colors.white),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              AutoDesignButton(),
              SizedBox(height: 4),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: CreateLogoButton()),
                    SizedBox(width: 10),
                    Expanded(child: MyDesignButton())
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [MyLogoButton(), MyDesignButton()],
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isBannerLoaded && _bannerAd != null
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }
}
