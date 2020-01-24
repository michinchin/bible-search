import 'dart:async';
import 'dart:io';

import 'package:bible_search/containers/initial_search_components/home_drawer.dart';
import 'package:bible_search/labels.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:flutter/material.dart';

import 'package:bible_search/containers/is_components.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tec_util/tec_util.dart' as tec;

import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/redux/actions.dart';

// Initial Search Route (screen)
//
// This is the 'home' screen of the Bible Search app. It shows an app bar, a search bar,
// and a list of recent searches.

class InitialSearchScreen extends StatefulWidget {
  @override
  _InitialSearchScreenState createState() => _InitialSearchScreenState();
}

class _InitialSearchScreenState extends State<InitialSearchScreen> {
  GlobalKey<ScaffoldState> _globalKey;
  DateTime currentBackPressTime;

  @override
  void initState() {
    _globalKey = GlobalKey();
    rateApp();
    super.initState();
  }

  void rateApp() {
    if (tec.Prefs.shared.getBool(prefRateApp, defaultValue: true)) {
      final rateMyApp = RateMyApp(
          preferencesPrefix: prefRateApp, minLaunches: 3, minDays: 3);

      rateMyApp.init().then((_) {
        WidgetsBinding.instance.addPostFrameCallback((d) {
          if (rateMyApp.shouldOpenDialog) {
            rateMyApp
              ..showRateDialog(context,
                  title: 'Rate App',
                  appIcon: Image.asset(
                    'assets/appIcon.png',
                    width: 100,
                  ),
                  message: 'Enjoying Bible Search!?')
              ..reset();
            tec.Prefs.shared.setBool(prefRateApp, false);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> onWillPop() {
    if (Platform.isAndroid && !_globalKey.currentState.isDrawerOpen) {
      final now = DateTime.now();
      const seconds = 3;

      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) >
              const Duration(seconds: seconds)) {
        currentBackPressTime = now;
        TecToast.show(context, 'Tap back again to exit');
        return Future.value(false);
      }
    }

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    final _imageWidth = MediaQuery.of(context).size.width;
    final _imageHeight = MediaQuery.of(context).size.height / 3;
    final _orientation = MediaQuery.of(context).orientation;
    const _searchBarHeight = 50.0;

    return StoreConnector<AppState, InitialSearchViewModel>(
        distinct: true,
        converter: (store) => InitialSearchViewModel(store),
        builder: (context, vm) {
          final ps = Size.fromHeight(_orientation == Orientation.portrait
              ? _imageHeight
              : _imageHeight + _searchBarHeight / 2);
          final appBar = PreferredSize(
              preferredSize: ps,
              child: Stack(
                children: <Widget>[
                  GradientOverlayImage(
                    fromOnline: false,
                    path: vm.votdString,
                    width: _imageWidth,
                    height: _imageHeight,
                    topColor: Colors.black,
                    bottomColor: Colors.transparent,
                  ),
                  ExtendedAppBar(
                    height: _imageHeight,
                  ),
                  InitialSearchBox(
                    orientation: _orientation,
                    height: _searchBarHeight,
                    imageHeight: _imageHeight,
                    updateSearch: vm.onSearchEntered,
                  ),
                ],
              ));

          return Scaffold(
            key: _globalKey,
            appBar: appBar,
            drawer: const HomeDrawer(),
            body: WillPopScope(
                onWillPop: onWillPop,
                child: SafeArea(
                    bottom: false,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SearchHistoryTitle(_searchBarHeight),
                          Expanded(
                              child: SearchHistoryList(
                                  searchHistory: vm.searchHistory,
                                  onSearchEntered: vm.onSearchEntered,
                                  updateSearchHistory: vm.updateSearchHistory))
                        ]))),
          );
        });
  }
}

class InitialSearchViewModel {
  final Store<AppState> store;
  // VOTDImage votdImage;
  String votdString;
  List<String> searchHistory;
  void Function(String term) onSearchEntered;
  void Function(List<String> searchQueries) updateSearchHistory;

  InitialSearchViewModel(this.store) {
    // votdImage = store.state.votdImage;
    votdString = _ordinalDayAsset();
    searchHistory = store.state.searchHistory;
    onSearchEntered = _onSearchEntered;
    updateSearchHistory = _updateSearchHistory;
  }

  String _ordinalDayAsset() {
    final _year = DateTime.now().year;
    final _jan1 = DateTime.utc(_year, 1, 1);
    final _ordinalDay = DateTime.now().difference(_jan1).inDays;
    return 'assets/$_ordinalDay.jpg';
  }

  void _onSearchEntered(String term) {
    if (term.trim().isNotEmpty) {
      store.dispatch(SearchAction(term));
    }
  }

  void _updateSearchHistory(List<String> searchQueries) =>
      store.dispatch(SetSearchHistoryAction(
          searchQuery: store.state.searchQuery, searchQueries: searchQueries));

  /// override == operator so flutter only rebuilds widgets that need rebuilding
  @override
  bool operator ==(dynamic other) =>
      // votdImage == other.votdImage &&
      searchHistory == other.searchHistory;

  @override
  int get hashCode =>
      // votdImage.hashCode ^
      searchHistory.hashCode;
}
