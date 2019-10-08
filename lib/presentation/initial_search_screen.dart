import 'dart:async';
import 'dart:io';

import 'package:bible_search/containers/initial_search_components/home_drawer.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/models/iap.dart';
import 'package:bible_search/version.dart';
import 'package:flutter/material.dart';

import 'package:bible_search/containers/is_components.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share/share.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:url_launcher/url_launcher.dart' as launcher;

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

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
    InAppPurchases.init(_purchaseHandler);

    if (Platform.isAndroid) {
      InAppPurchases.restorePurchases();
    }

    super.initState();
  }

  void _purchaseHandler(String inAppId) {
    if (inAppId == removeAdsId) {
      tec.Prefs.shared.setBool(removedAdsPref, true);
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
        tecShowToast('Tap back again to exit');
        return Future.value(false);
      }
    }

    return Future.value(true);
  }

  void tecShowToast(String message) {
    final widget = Container(
      margin: const EdgeInsets.only(
          left: 50.0, right: 50.0, top: 50.0, bottom: 0.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(235, 0, 134, 248),
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: ClipRect(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );

    showToastWidget(widget, position: ToastPosition.bottom);
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
  bool isDarkTheme;
  void Function(String term) onSearchEntered;
  void Function(List<String> searchQueries) updateSearchHistory;
  Future<void> Function(BuildContext c) emailFeedback;
  Future<void> Function(BuildContext c) shareApp;
  void Function(bool isDarkTheme) changeTheme;

  InitialSearchViewModel(this.store) {
    // votdImage = store.state.votdImage;
    votdString = _ordinalDayAsset();
    searchHistory = store.state.searchHistory;
    isDarkTheme = store.state.isDarkTheme;
    onSearchEntered = _onSearchEntered;
    updateSearchHistory = _updateSearchHistory;
    changeTheme = _changeTheme;
    emailFeedback = _emailFeedback;
    shareApp = _shareApp;
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

  void _changeTheme(bool isDarkTheme) =>
      store.dispatch(SetThemeAction(isDarkTheme: isDarkTheme));

  void _updateSearchHistory(List<String> searchQueries) =>
      store.dispatch(SetSearchHistoryAction(
          searchQuery: store.state.searchQuery, searchQueries: searchQueries));

  /// Opens the native email UI with an email for questions or comments.
  Future<void> _emailFeedback(BuildContext context) async {
    var email = 'biblesupport@tecarta.com';
    if (!Platform.isIOS) {
      email = 'androidsupport@tecarta.com';
    }
    final di = await tec.DeviceInfo.fetch();
    print(
        'Running on ${di.productName} with ${tec.DeviceInfo.os} ${di.version}');
    final version =
        (appVersion == 'DEBUG-VERSION' ? '(debug version)' : 'v$appVersion');
    final subject = 'Feedback regarding Bible Search! $version '
        'with ${di.productName} ${tec.DeviceInfo.os} ${di.version}';
    const body = 'I have the following question or comment:\n\n\n';

    final url = Uri.encodeFull('mailto:$email?subject=$subject&body=$body');

    try {
      if (await launcher.canLaunch(url)) {
        await launcher.launch(url, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      final msg = 'Error emailing: ${e.toString()}';
      showSnackBarMessage(context, msg);
      print(msg);
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    String storeUrl;
    if (Platform.isAndroid) {
      storeUrl =
          'https://play.google.com/store/apps/details?id=com.tecarta.biblesearch';
    } else if (Platform.isIOS) {
      storeUrl = 'https://apps.apple.com/us/app/bible-search/id1436076950';
    } else {
      return;
    }
    final shortUrl = await tec.shortenUrl(storeUrl);
    await Share.share(shortUrl);
  }

  /// Shows a snack bar message.
  void showSnackBarMessage(BuildContext context, String message) {
    Navigator.pop(context); // Dismiss the drawer.
    if (message == null) return;
    Scaffold.of(context)?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  /// override == operator so flutter only rebuilds widgets that need rebuilding
  @override
  bool operator ==(dynamic other) =>
      // votdImage == other.votdImage &&
      searchHistory == other.searchHistory && isDarkTheme == other.isDarkTheme;

  @override
  int get hashCode =>
      // votdImage.hashCode ^
      searchHistory.hashCode ^ isDarkTheme.hashCode;
}
