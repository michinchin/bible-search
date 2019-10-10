import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/presentation/initial_search_screen.dart';
import 'package:bible_search/presentation/search_result_screen.dart';
import 'package:bible_search/redux/actions.dart';
import 'package:bible_search/labels.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:bible_search/redux/reducers.dart';
import 'package:bible_search/redux/middleware.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:firebase_admob/firebase_admob.dart';

import 'package:tec_util/tec_util.dart' as tec;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load preferences.
  await tec.Prefs.shared.load();

  // Load device info
  final di = await tec.DeviceInfo.fetch();
  print('Running on ${di.productName} with ${tec.DeviceInfo.os} ${di.version}');

  await FirebaseAdMob.instance.initialize(appId: prefAdmobAppId);

  final store = Store<AppState>(
    reducers,
    initialState:
        AppState.initial(deviceInfo: di, state: AppLifecycleState.inactive),
    middleware: middleware,
  )
    ..dispatch(InitHomeAction())
    ..dispatch(InitFilterAction());

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
          child: DynamicTheme(
              defaultBrightness: Brightness.light,
              data: (brightness) => ThemeData(
                    primarySwatch: Colors.orange,
                    primaryColorBrightness:
                        darkTheme ? Brightness.dark : Brightness.light,
                    brightness: darkTheme ? Brightness.dark : Brightness.light,
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
    if (tec.Prefs.shared.getBool(removedAdsPref, defaultValue: false)) {
      final dt = DateTime.parse(
          tec.Prefs.shared.getString(removedAdsExpirePref,
              defaultValue: (DateTime.now().add(const Duration(days: 365)))
                  .toString()));

      if (DateTime.now().isAfter(dt)) {
        tec.Prefs.shared.setBool(removedAdsPref, false);
      }
    }

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
