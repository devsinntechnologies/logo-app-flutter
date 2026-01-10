import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static void initialize() {
    MobileAds.instance.initialize();
  }

  // ✅ Banner Ad
  static BannerAd bannerAd({
    required AdSize size,
    required void Function(Ad ad) onLoaded,
  }) {
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
  static String get _bannerId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // test banner
      : '';

// Interstitial
  static String get _interstitialId =>
      Platform.isAndroid ? 'ca-app-pub-3940256099942544/1033173712' : '';

// Rewarded
  static String get _rewardedId =>
      Platform.isAndroid ? 'ca-app-pub-3940256099942544/5224354917' : '';
}
