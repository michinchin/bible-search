import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/presentation/initial_search.dart';
import 'package:bible_search/presentation/results_page.dart';
import 'package:bible_search/redux/actions.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:redux/redux.dart';
import 'package:bible_search/redux/reducers.dart';
import 'package:bible_search/redux/middleware.dart';
import 'package:flutter_redux/flutter_redux.dart';

final store = Store<AppState>(
  reducers,
  initialState: AppState.initial(),
  middleware: middleware,
);

// final appId = 'ca-app-pub-5279916355700267~3348273170';
// MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//   keywords: <String>['flutterio', 'beautiful apps'],
//   contentUrl: 'https://flutter.io',
//   childDirected: false,
//   testDevices: <String>[], // Android emulators are considered test devices
// );
//   BannerAd myBanner =BannerAd(
//     adUnitId: BannerAd.testAdUnitId,
//   size: AdSize.smartBanner,
//   targetingInfo: targetingInfo,
//   listener: (MobileAdEvent event) {
//     print("BannerAd event is $event");
//   });

void main() {
  // FirebaseAdMob.instance.initialize(appId: appId);
  
  store.dispatch(InitHomeAction());
  store.dispatch(InitFilterAction());
  return runApp(BibleSearchApp(
    store: store,
  ));
}

class BibleSearchApp extends StatelessWidget {
  final Store<AppState> store;

  BibleSearchApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: DynamicTheme(
            defaultBrightness: Brightness.light,
            data: (brightness) => ThemeData(
                  primarySwatch: Colors.orange,
                  primaryColorBrightness: Brightness.light,
                  brightness: store.state.isDarkTheme
                      ? Brightness.dark
                      : Brightness.light,
                ),
            themedWidgetBuilder: (context, theme) {
              return MaterialApp(
                initialRoute: '/',
                routes: <String, WidgetBuilder>{
                  '/results': (BuildContext context) => ResultsPage(),
                },
                title: 'Bible Search',
                theme: theme,
                home: InitialSearchPage(),
              );
            }));
  }
}
