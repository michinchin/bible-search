import 'dart:io';

import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/presentation/initial_search_screen.dart';
import 'package:bible_search/presentation/search_result_screen.dart';
import 'package:bible_search/redux/actions.dart';
import 'package:bible_search/labels.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pedantic/pedantic.dart';
import 'package:redux/redux.dart';
import 'package:bible_search/redux/reducers.dart';
import 'package:bible_search/redux/middleware.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:tec_native_ad/tec_native_ad.dart';
import 'package:tec_user_account/tec_user_account.dart';

import 'package:tec_util/tec_util.dart' as tec;

import 'models/iap.dart';
import 'models/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load preferences.
  await tec.Prefs.shared.load();

  // Load device info
  final di = await tec.DeviceInfo.fetch();
  print('Running on ${di.productName} with ${tec.DeviceInfo.os} ${di.version}');

  final kvStore = KVStore();
  // ignore: prefer_interpolation_to_compose_strings
  final appPrefix = (Platform.isAndroid ? 'PLAY_' : 'IOS_') + 'BibleSearch';
  final userAccount = await UserAccount.init(
    kvStore: kvStore,
    deviceUid: di.deviceUid,
    appPrefix: appPrefix,
    itemTypesToSync: [UserItemType.license],
  );

  final store = Store<AppState>(
    reducers,
    initialState: AppState.initial(
        deviceInfo: di,
        state: AppLifecycleState.inactive,
        userAccount: userAccount),
    middleware: middleware,
  )..dispatch(InitHomeAction());

  // init loading of ads...
  unawaited(userAccount.userDb.hasLicenseToFullVolume(removeAdsVolumeId).then((
      hasAccess) {
    if (!hasAccess) {
      NativeAdController.instance.loadAds(adUnitId: prefAdMobNativeAdId);
    }
  }));

  // Initialize in app purchases
  InAppPurchases.init(UserModel.purchaseHandler, userAccount);
  if (Platform.isAndroid) {
    InAppPurchases.restorePurchases();
  }

  return runApp(BibleSearchApp(
    store: store,
  ));
}

class BibleSearchApp extends StatelessWidget {
  final Store<AppState> store;

  const BibleSearchApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkTheme = store.state.isDarkTheme;

    return StoreProvider<AppState>(
        store: store,
        child: FeatureDiscovery(
          child: OKToast(
            child: DynamicTheme(
                defaultBrightness: Brightness.light,
                data: (brightness) => ThemeData(
                      primarySwatch: Colors.orange,
                      primaryColorBrightness:
                          darkTheme ? Brightness.dark : Brightness.light,
                      brightness:
                          darkTheme ? Brightness.dark : Brightness.light,
                    ),
                themedWidgetBuilder: (context, theme) {
                  return MaterialApp(
                    initialRoute: '/',
                    debugShowCheckedModeBanner: false,
                    routes: <String, WidgetBuilder>{
                      '/results': (context) => const SearchResultScreen(),
                    },
                    title: 'Bible Search',
                    theme: theme,
                    home: _AppBindingObserver(store),
                  );
                }),
          ),
        ));
  }
}

class _AppBindingObserver extends StatefulWidget {
  final Store<AppState> store;
  const _AppBindingObserver(this.store);
  @override
  _AppBindingObserverState createState() => _AppBindingObserverState();
}

class _AppBindingObserverState extends State<_AppBindingObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    // reset ads...
    // if (tec.Prefs.shared.getBool(removedAdsPref, defaultValue: false)) {
    //   var dts = tec.Prefs.shared.getString(removedAdsExpirePref);

    //   // if this is an old app that doesn't have this value set - add a year
    //   if (dts == null) {
    //     dts = DateTime.now().add(const Duration(days: 365)).toString();
    //     tec.Prefs.shared.setString(removedAdsExpirePref, dts);
    //   }

    //   if (DateTime.now().isAfter(DateTime.parse(dts))) {
    //     tec.Prefs.shared.setBool(removedAdsPref, false);
    //   }
    // }

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App state changed to $state');
    widget.store.dispatch(StateChangeAction(state: state));
  }

  @override
  Widget build(BuildContext context) => InitialSearchScreen();
}

class KVStore with UserAccountKVStore {
  KVStore() : prefs = <String, String>{};

  final Map<String, String> prefs;

  @override
  String getString(String key, {String defaultValue}) {
    return tec.Prefs.shared.getString(key, defaultValue: defaultValue);
  }

  @override
  Future<bool> setString(String key, String value) async {
    return tec.Prefs.shared.setString(key, value);
  }
}
