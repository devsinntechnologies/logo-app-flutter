import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logo_app_flutter/components/google_alert.dart';
import 'package:logo_app_flutter/screens/my_design_screen.dart';
import 'package:logo_app_flutter/services/ad_mob_service.dart';
import 'package:logo_app_flutter/utils/theme_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyDesignButton extends StatelessWidget {
  const MyDesignButton({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final GlobalKey canvasKey = GlobalKey();
    return GestureDetector(
      onTap: () {
        if (user != null) {
          // User is logged in → navigate normally
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyDesignScreen(canvasKey: canvasKey),
            ),
          );
        } else {
          // User not logged in → show login/signup dialog
          showCustomGoogleDialog(context);
        }

        // SnackBar snackBar = const SnackBar(
        //   content: Text('My Design button pressed!'),
        //   duration: Duration(milliseconds: 100),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        AdMobService.loadInterstitial(
    onLoaded: (InterstitialAd ad) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
        },
      );
      ad.show();
    },
  );
      },
      child: Container(
        height: 160,
        // padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: ThemeColors.yellowOrangePink,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // optional
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/icons/myData.png', width: 40),
                  SizedBox(height: 20),
                  Text(
                    'My Design',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 35,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
