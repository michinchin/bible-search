import 'dart:async';
import 'dart:io';

import 'package:bible_search/containers/initial_search_components/home_drawer.dart';
import 'package:bible_search/labels.dart';
import 'package:flutter/material.dart';

import 'package:bible_search/containers/is_components.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:url_launcher/url_launcher.dart' as launcher;

import 'package:flutter_redux/flutter_redux.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:redux/redux.dart';

import 'package:bible_search/data/votd_image.dart';
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
  StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    final purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen(_handlePurchaseUpdates);
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetails) {
    debugPrint(purchaseDetails.first.status == PurchaseStatus.purchased
        ? 'purchased'
        : 'not purchased');
    if (purchaseDetails.first.status == PurchaseStatus.purchased) {
      tec.Prefs.shared.setBool(removedAdsPref, true);
    }
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
          final searchHistoryList = Container(
            child: ListView.builder(
                itemBuilder: (context, index) {
                  final words = vm.searchHistory.reversed.toList();
                  return ListTileTheme(
                    child: Dismissible(
                      key: Key(words[index]),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                            backgroundColor: Theme.of(context).cardColor,
                            content: Text(
                              'The search term "${words[index]}" has been removed',
                              style: Theme.of(context).textTheme.body1,
                            )));
                        words.removeWhere((w) => (w == words[index]));
                        vm.updateSearchHistory(words.reversed.toList());
                      },
                      background: Container(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.delete)),
                        color: Colors.red,
                      ),
                      child: ListTile(
                        title: Text(
                          '${words[index]}',
                        ),
                        leading: Icon(Icons.access_time),
                        onTap: () {
                          vm.onSearchEntered(words[index]);
                          Navigator.of(context).pushNamed('/results');
                        },
                      ),
                    ),
                  );
                },
                itemCount: vm.searchHistory?.length ?? 0),
          );

          final gradientAppBarImage = GradientOverlayImage(
            fromOnline: vm.votdImage != null,
            path: vm.votdImage?.url ?? 'assets/appimage.jpg',
            width: _imageWidth,
            height: _imageHeight,
            topColor: Colors.black,
            bottomColor: Colors.transparent,
          );

          final searchBox = InitialSearchBox(
            orientation: _orientation,
            height: _searchBarHeight,
            imageHeight: _imageHeight,
            updateSearch: vm.onSearchEntered,
          );

          final searchHistoryTitle = Container(
            padding: const EdgeInsets.only(
              left: 20.0,
              top: _searchBarHeight / 4,
            ),
            color: Colors.transparent,
            child: Text(
              'SEARCH HISTORY',
              style: TextStyle(
                color: vm.isDarkTheme ? Colors.grey[300] : Colors.grey[800],
                fontFamily: 'Roboto',
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          );

          final seachHistoryListWithTitle = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              searchHistoryTitle,
              Expanded(child: searchHistoryList),
            ],
          );

          final ps = Size.fromHeight(_orientation == Orientation.portrait
              ? _imageHeight
              : _imageHeight + _searchBarHeight / 2);

          final appBar = PreferredSize(
              preferredSize: ps,
              child: Stack(
                children: <Widget>[
                  gradientAppBarImage,
                  ExtendedAppBar(
                    height: _imageHeight,
                  ),
                  searchBox,
                ],
              ));

          return Scaffold(
            appBar: appBar,
            drawer: HomeDrawer(vm),
            body: seachHistoryListWithTitle,
          );
        });
  }
}

class InitialSearchViewModel {
  final Store<AppState> store;
  VOTDImage votdImage;
  List<String> searchHistory;
  bool isDarkTheme;
  void Function(String term) onSearchEntered;
  void Function(List<String> searchQueries) updateSearchHistory;
  Future<void> Function(BuildContext c) emailFeedback;
  void Function(bool isDarkTheme) changeTheme;

  InitialSearchViewModel(this.store) {
    votdImage = store.state.votdImage;
    searchHistory = store.state.searchHistory;
    isDarkTheme = store.state.isDarkTheme;
    onSearchEntered = _onSearchEntered;
    updateSearchHistory = _updateSearchHistory;
    changeTheme = _changeTheme;
    emailFeedback = _emailFeedback;
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

    final subject = 'Feedback regarding Bible Search! '
        'with ${tec.DeviceInfo.os}';

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
      votdImage == other.votdImage &&
      searchHistory == other.searchHistory &&
      isDarkTheme == other.isDarkTheme;

  @override
  int get hashCode =>
      votdImage.hashCode ^ searchHistory.hashCode ^ isDarkTheme.hashCode;
}
