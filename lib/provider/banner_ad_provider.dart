import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdProvider with ChangeNotifier {
  BannerAd? _bannerAd;
  bool _isloaded = false;

  BannerAdProvider() {
    _loadBannerAd();
  }

  BannerAd? get bannerAd => _bannerAd;
  bool get isLoaded => _isloaded;

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isloaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isloaded = false;
          notifyListeners();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
