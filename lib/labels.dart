import 'dart:io';

const String kTBStreamServer = 'cf-stream.tecartabible.com';
const String kTBApiVersion = '7';
const String kTBApiServer = 'api.tecartabible.com';
const String kTBkey = 'toomanysecrets';

// bs = Bible Search
const String adCounterPref = 'bs_adCounter';
const String themePref = 'bs_theme';
const String translationsPref = 'bs_translations';
const String searchHistoryPref = 'bs_searchHistory';

const int maxSearchesBeforeAd = 5;

final prefInterstitialAdId = Platform.isAndroid
    ? 'ca-app-pub-5279916355700267/3575410635'
    : 'ca-app-pub-5279916355700267/9566103912';

final prefAdmobAppId = Platform.isAndroid
    ? 'ca-app-pub-5279916355700267~6403892871'
    : 'ca-app-pub-5279916355700267~3348273170';