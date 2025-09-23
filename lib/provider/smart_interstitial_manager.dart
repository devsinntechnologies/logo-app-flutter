import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmartInterstitialManager extends ChangeNotifier {
  static final SmartInterstitialManager _instance =
      SmartInterstitialManager._internal();
  factory SmartInterstitialManager() => _instance;
  SmartInterstitialManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isShowingAd = false;

  int _buttonClickCount = 0;
  int _sessionActions = 0;
  DateTime _lastAdShown = DateTime.now();
  DateTime _sessionStart = DateTime.now();
  Timer? _randomTimer;
  Timer? _sessionTimer;

  static const int MIN_TIME_BETWEEN_ADS = 45; 
  static const int MAX_TIME_BETWEEN_ADS = 240; 
  static const int MIN_CLICKS_BEFORE_AD = 5;
  static const int MAX_CLICKS_BEFORE_AD = 15;
  static const int SESSION_ACTIONS_THRESHOLD = 20;

  Set<String> _firstTimeActions = <String>{};
  bool _hasShownWelcomeAd = false;

  static const String _adUnitId =
      'ca-app-pub-3940256099942544/1033173712'; 

  bool get isAdLoaded => _isAdLoaded;
  bool get isShowingAd => _isShowingAd;

  Future<void> initialize() async {
    await _loadFirstTimeActions();
    _startRandomTimers();
    _loadInterstitialAd();

    if (!_hasShownWelcomeAd) {
      Timer(const Duration(seconds: 10), () {
        showWelcomeAd();
      });
    }
  }

  void _startRandomTimers() {
    _scheduleNextRandomAd();

    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkSessionActivity();
    });
  }

  void _scheduleNextRandomAd() {
    _randomTimer?.cancel();

    final random = Random();
    final randomSeconds =
        MIN_TIME_BETWEEN_ADS +
        random.nextInt(MAX_TIME_BETWEEN_ADS - MIN_TIME_BETWEEN_ADS);

    _randomTimer = Timer(Duration(seconds: randomSeconds), () {
      if (_shouldShowTimeBasedAd()) {
        showRandomAd('random_timer');
      }
      _scheduleNextRandomAd(); 
    });

    print('Next random ad scheduled in $randomSeconds seconds');
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _setFullScreenContentCallback();
          print('Interstitial ad loaded successfully');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load interstitial ad: $error');
          _isAdLoaded = false;
          Timer(const Duration(seconds: 30), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void _setFullScreenContentCallback() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _isShowingAd = false;
        _lastAdShown = DateTime.now();
        ad.dispose();
        _loadInterstitialAd(); 
        print('Interstitial ad dismissed');
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _isShowingAd = false;
        ad.dispose();
        _loadInterstitialAd();
        print('Failed to show interstitial ad: $error');
      },
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        _isShowingAd = true;
        print('Interstitial ad showed');
      },
    );
  }

  void onButtonClick(String buttonName) {
    _buttonClickCount++;
    _sessionActions++;

    print('Button clicked: $buttonName (Total clicks: $_buttonClickCount)');

    final random = Random();
    if (_shouldShowClickBasedAd() && random.nextDouble() < 0.3) {
      showRandomAd('button_click_$buttonName');
      return;
    }

    if (_buttonClickCount >= MIN_CLICKS_BEFORE_AD &&
        random.nextDouble() < 0.5) {
      showRandomAd('click_threshold');
      _buttonClickCount = 0; 
    }
  }

  Future<void> onFirstTimeAction(String actionName) async {
    if (_firstTimeActions.contains(actionName)) return;

    _firstTimeActions.add(actionName);
    await _saveFirstTimeActions();

    print('First time action: $actionName');

    final importantActions = [
      'settings_opened',
      'download_attempted',
      'color_changed',
      'element_added',
      'font_changed',
    ];

    if (importantActions.contains(actionName)) {
      Timer(const Duration(seconds: 2), () {
        showRandomAd('first_time_$actionName');
      });
    }
  }

  Future<void> showRandomAd(String context) async {
    if (!_canShowAd()) return;

    print('Attempting to show ad for context: $context');

    if (_isAdLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
    } else {
      print('Ad not ready, loading new one...');
      _loadInterstitialAd();
    }
  }

  Future<void> showWelcomeAd() async {
    if (_hasShownWelcomeAd) return;

    final prefs = await SharedPreferences.getInstance();
    final hasShownBefore = prefs.getBool('welcome_ad_shown') ?? false;

    if (!hasShownBefore) {
      await showRandomAd('welcome');
      await prefs.setBool('welcome_ad_shown', true);
      _hasShownWelcomeAd = true;
    }
  }

  bool _canShowAd() {
    if (_isShowingAd) return false;

    final timeSinceLastAd = DateTime.now().difference(_lastAdShown).inSeconds;
    if (timeSinceLastAd < MIN_TIME_BETWEEN_ADS) {
      print('Too soon since last ad: ${timeSinceLastAd}s');
      return false;
    }

    return true;
  }

  bool _shouldShowTimeBasedAd() {
    return _canShowAd() && _sessionActions > 5;
  }

  bool _shouldShowClickBasedAd() {
    return _canShowAd() && _buttonClickCount > 3;
  }

  void _checkSessionActivity() {
    final sessionDuration = DateTime.now().difference(_sessionStart).inMinutes;

    if (_sessionActions > SESSION_ACTIONS_THRESHOLD && sessionDuration > 10) {
      showRandomAd('long_session');
      _sessionActions = 0; 
    }
  }

  Future<void> _loadFirstTimeActions() async {
    final prefs = await SharedPreferences.getInstance();
    final actionsJson = prefs.getStringList('first_time_actions') ?? [];
    _firstTimeActions = actionsJson.toSet();
    _hasShownWelcomeAd = prefs.getBool('welcome_ad_shown') ?? false;
  }

  Future<void> _saveFirstTimeActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('first_time_actions', _firstTimeActions.toList());
  }

  // Cleanup
  void dispose() {
    _randomTimer?.cancel();
    _sessionTimer?.cancel();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void onColorChanged() => onFirstTimeAction('color_changed');
  void onElementAdded() => onFirstTimeAction('element_added');
  void onFontChanged() => onFirstTimeAction('font_changed');
  void onDownloadAttempted() => onFirstTimeAction('download_attempted');
  void onSettingsOpened() => onFirstTimeAction('settings_opened');
  void onShapeAdded() => onFirstTimeAction('shape_added');
  void onTextAdded() => onFirstTimeAction('text_added');
}
