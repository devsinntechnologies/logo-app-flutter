import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  // Check if ads are supported on this platform
  static bool get isSupported => !kIsWeb;

  static void initialize() {
    if (isSupported) {
      MobileAds.instance.initialize();
    }
  }

  // ✅ Banner Ad
  static BannerAd? bannerAd({
    required AdSize size,
    required void Function(Ad ad) onLoaded,
  }) {
    if (!isSupported) return null;

    return BannerAd(
      adUnitId: _bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
      ),
    )..load();
  }

  // ✅ Interstitial Ad
  static void loadInterstitial({
    required void Function(InterstitialAd ad) onLoaded,
  }) {
    if (!isSupported) return;

    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  // ✅ Rewarded Ad
  static void loadRewarded({
    required void Function(RewardedAd ad) onLoaded,
  }) {
    if (!isSupported) return;

    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  // 🔹 Test Ad IDs (SAFE)
  // Banner
  static String get _bannerId {
    if (kIsWeb) return '';
    return Platform.isAndroid
        ? 'ca-app-pub-8834178071297418/2453565991' // test banner
        : '';
  }

  // Interstitial
  static String get _interstitialId {
    if (kIsWeb) return '';
    return Platform.isAndroid ? 'ca-app-pub-8834178071297418/1431294211' : '';
  }

  // Rewarded
  static String get _rewardedId {
    if (kIsWeb) return '';
    return Platform.isAndroid ? 'ca-app-pub-8834178071297418/8579990644' : '';
  }
}
