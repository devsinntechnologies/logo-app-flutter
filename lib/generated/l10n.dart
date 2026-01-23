// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `SmartLogoMaker`
  String get smartLogoMaker {
    return Intl.message(
      'SmartLogoMaker',
      name: 'smartLogoMaker',
      desc: '',
      args: [],
    );
  }

  /// `Auto Design`
  String get autoDesign {
    return Intl.message('Auto Design', name: 'autoDesign', desc: '', args: []);
  }

  /// `Create Logo`
  String get createLogo {
    return Intl.message('Create Logo', name: 'createLogo', desc: '', args: []);
  }

  /// `My Design`
  String get myDesign {
    return Intl.message('My Design', name: 'myDesign', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Smart Logo Maker`
  String get smartLogoMakerText {
    return Intl.message(
      'Smart Logo Maker',
      name: 'smartLogoMakerText',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Sign Up`
  String get signup {
    return Intl.message('Sign Up', name: 'signup', desc: '', args: []);
  }

  /// `Sign In With Google`
  String get SignInWithGoogle {
    return Intl.message(
      'Sign In With Google',
      name: 'SignInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get or {
    return Intl.message('OR', name: 'or', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Enter your email`
  String get enterEmail {
    return Intl.message(
      'Enter your email',
      name: 'enterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get enterPasswords {
    return Intl.message(
      'Enter your password',
      name: 'enterPasswords',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get noAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get name {
    return Intl.message('First Name', name: 'name', desc: '', args: []);
  }

  /// `Last Name`
  String get nameLast {
    return Intl.message('Last Name', name: 'nameLast', desc: '', args: []);
  }

  /// `Enter your first name`
  String get enterName {
    return Intl.message(
      'Enter your first name',
      name: 'enterName',
      desc: '',
      args: [],
    );
  }

  /// `Enter your last name`
  String get enterNameLast {
    return Intl.message(
      'Enter your last name',
      name: 'enterNameLast',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get passwordConfirm {
    return Intl.message(
      'Confirm Password',
      name: 'passwordConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Confirm your password`
  String get confirmYourPassword {
    return Intl.message(
      'Confirm your password',
      name: 'confirmYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `CHOOSE INDUSTRY`
  String get ChooseIndustry {
    return Intl.message(
      'CHOOSE INDUSTRY',
      name: 'ChooseIndustry',
      desc: '',
      args: [],
    );
  }

  /// `YOUR COMPANY NAME`
  String get companyName {
    return Intl.message(
      'YOUR COMPANY NAME',
      name: 'companyName',
      desc: '',
      args: [],
    );
  }

  /// `SLOGAN`
  String get sloganName {
    return Intl.message('SLOGAN', name: 'sloganName', desc: '', args: []);
  }

  /// `Enter your slogan`
  String get enterSlogan {
    return Intl.message(
      'Enter your slogan',
      name: 'enterSlogan',
      desc: '',
      args: [],
    );
  }

  /// `Enter your company name`
  String get enterCompany {
    return Intl.message(
      'Enter your company name',
      name: 'enterCompany',
      desc: '',
      args: [],
    );
  }

  /// `Information`
  String get information {
    return Intl.message('Information', name: 'information', desc: '', args: []);
  }

  /// `CHOOSE FONTS`
  String get chooseFonts {
    return Intl.message(
      'CHOOSE FONTS',
      name: 'chooseFonts',
      desc: '',
      args: [],
    );
  }

  /// `choose Fonts`
  String get chooseFontsSmall {
    return Intl.message(
      'choose Fonts',
      name: 'chooseFontsSmall',
      desc: '',
      args: [],
    );
  }

  /// `Template`
  String get template {
    return Intl.message('Template', name: 'template', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Automotive & Transportation`
  String get automotiveTransportation {
    return Intl.message(
      'Automotive & Transportation',
      name: 'automotiveTransportation',
      desc: '',
      args: [],
    );
  }

  /// `Beauty & Massage`
  String get beautyMassage {
    return Intl.message(
      'Beauty & Massage',
      name: 'beautyMassage',
      desc: '',
      args: [],
    );
  }

  /// `Business & Consulting`
  String get businessConsulting {
    return Intl.message(
      'Business & Consulting',
      name: 'businessConsulting',
      desc: '',
      args: [],
    );
  }

  /// `Children & Education`
  String get childrenEducation {
    return Intl.message(
      'Children & Education',
      name: 'childrenEducation',
      desc: '',
      args: [],
    );
  }

  /// `Entertainment, Art & Music`
  String get entertainmentArtMusic {
    return Intl.message(
      'Entertainment, Art & Music',
      name: 'entertainmentArtMusic',
      desc: '',
      args: [],
    );
  }

  /// `Family Services & Counseling`
  String get familyServicesCounseling {
    return Intl.message(
      'Family Services & Counseling',
      name: 'familyServicesCounseling',
      desc: '',
      args: [],
    );
  }

  /// `Finance & Insurance`
  String get financeInsurance {
    return Intl.message(
      'Finance & Insurance',
      name: 'financeInsurance',
      desc: '',
      args: [],
    );
  }

  /// `Food, Beverage & Restaurant`
  String get foodBeverageRestaurant {
    return Intl.message(
      'Food, Beverage & Restaurant',
      name: 'foodBeverageRestaurant',
      desc: '',
      args: [],
    );
  }

  /// `Health Care & Public Safety`
  String get healthCarePublicSafety {
    return Intl.message(
      'Health Care & Public Safety',
      name: 'healthCarePublicSafety',
      desc: '',
      args: [],
    );
  }

  /// `Holiday & Special Occasion`
  String get holidaySpecialOccasion {
    return Intl.message(
      'Holiday & Special Occasion',
      name: 'holidaySpecialOccasion',
      desc: '',
      args: [],
    );
  }

  /// `IT, Engineering & Science`
  String get itEngineeringScience {
    return Intl.message(
      'IT, Engineering & Science',
      name: 'itEngineeringScience',
      desc: '',
      args: [],
    );
  }

  /// `Legal & Politics`
  String get legalPolitics {
    return Intl.message(
      'Legal & Politics',
      name: 'legalPolitics',
      desc: '',
      args: [],
    );
  }

  /// `Pets & Animal`
  String get petsAnimal {
    return Intl.message(
      'Pets & Animal',
      name: 'petsAnimal',
      desc: '',
      args: [],
    );
  }

  /// `Photography`
  String get photography {
    return Intl.message('Photography', name: 'photography', desc: '', args: []);
  }

  /// `Sports & Fitness`
  String get sportsFitness {
    return Intl.message(
      'Sports & Fitness',
      name: 'sportsFitness',
      desc: '',
      args: [],
    );
  }

  /// `MODERN`
  String get modern {
    return Intl.message('MODERN', name: 'modern', desc: '', args: []);
  }

  /// `HANDWRITTEN`
  String get handwritten {
    return Intl.message('HANDWRITTEN', name: 'handwritten', desc: '', args: []);
  }

  /// `CONTEMPORARY`
  String get contemporary {
    return Intl.message(
      'CONTEMPORARY',
      name: 'contemporary',
      desc: '',
      args: [],
    );
  }

  /// `CALLIGRAPHY`
  String get calligraphy {
    return Intl.message('CALLIGRAPHY', name: 'calligraphy', desc: '', args: []);
  }

  /// `FANCY`
  String get fancy {
    return Intl.message('FANCY', name: 'fancy', desc: '', args: []);
  }

  /// `MINIMAL`
  String get minimal {
    return Intl.message('MINIMAL', name: 'minimal', desc: '', args: []);
  }

  /// `TECH`
  String get tech {
    return Intl.message('TECH', name: 'tech', desc: '', args: []);
  }

  /// `CLASSIC`
  String get classic {
    return Intl.message('CLASSIC', name: 'classic', desc: '', args: []);
  }

  /// `DISPLAY`
  String get display {
    return Intl.message('DISPLAY', name: 'display', desc: '', args: []);
  }

  /// `RETRO`
  String get retro {
    return Intl.message('RETRO', name: 'retro', desc: '', args: []);
  }

  /// `Logo Maker`
  String get logoMaker {
    return Intl.message('Logo Maker', name: 'logoMaker', desc: '', args: []);
  }

  /// `Background`
  String get background {
    return Intl.message('Background', name: 'background', desc: '', args: []);
  }

  /// `Art`
  String get art {
    return Intl.message('Art', name: 'art', desc: '', args: []);
  }

  /// `Text`
  String get text {
    return Intl.message('Text', name: 'text', desc: '', args: []);
  }

  /// `Effects`
  String get effects {
    return Intl.message('Effects', name: 'effects', desc: '', args: []);
  }

  /// `Palette`
  String get palette {
    return Intl.message('Palette', name: 'palette', desc: '', args: []);
  }

  /// `Images`
  String get images {
    return Intl.message('Images', name: 'images', desc: '', args: []);
  }

  /// `Lock All`
  String get lockAll {
    return Intl.message('Lock All', name: 'lockAll', desc: '', args: []);
  }

  /// `Save Logo`
  String get saveLogo {
    return Intl.message('Save Logo', name: 'saveLogo', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'ur'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
