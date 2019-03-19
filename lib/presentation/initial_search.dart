import 'package:bible_search/data/votd_image.dart';
import 'package:bible_search/main.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/redux/actions.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../containers/initial_search_components.dart';

// Initial Search Route (screen)
//
// This is the 'home' screen of the Bible Search app. It shows an app bar, a search bar,
// and a list of recent searches.

class InitialSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _imageWidth = MediaQuery.of(context).size.width;
    final _imageHeight = MediaQuery.of(context).size.height / 3;
    final _orientation = MediaQuery.of(context).orientation;
    final _searchBarHeight = 50.0;

    return StoreConnector<AppState, InitialSearchViewModel>(
        distinct: true,
        converter: (store) {
          return InitialSearchViewModel.fromStore(store);
        },
        builder: (BuildContext context, InitialSearchViewModel vm) {
          final searchHistoryList = Container(
            child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  List<String> words = vm.searchHistory.reversed.toList();
                  return ListTileTheme(
                    child: Dismissible(
                      key: Key(words[index]),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'The search term "${words[index]}" has been removed')));
                        words.removeWhere((w) => (w == words[index]));
                        vm.updateSearchHistory(words.reversed.toList());
                      },
                      background: Container(
                        padding: EdgeInsets.only(right: 15.0),
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
            padding: EdgeInsets.only(
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

          final _settingsList = ListView(
            children: <Widget>[
              DrawerHeader(
                child: new Text('Settings'),
              ),
              SwitchListTile(
                  secondary: Icon(Icons.lightbulb_outline),
                  value: vm.isDarkTheme,
                  title: Text('Light/Dark Mode'),
                  onChanged: (b) {
                    DynamicTheme.of(context).setThemeData(ThemeData(
                      primarySwatch: b ? Colors.teal : Colors.orange,
                      primaryColorBrightness: Brightness.dark,
                      brightness: b ? Brightness.dark : Brightness.light,
                    ));
                    vm.changeTheme(b);
                  }),
              ListTile(
                leading: Icon(Icons.more),
                title: Text('About'),
                onTap: () {
                  showAboutDialog(context: context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.remove_circle),
                title: Text('Remove Ads'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('Clear Search History'),
                onTap: () {
                  vm.updateSearchHistory([]);
                },
              ),
            ],
          );

          return Scaffold(
            appBar: appBar,
            drawer: Drawer(
              child: _settingsList,
            ),
            body: Stack(
              children: [
                SafeArea(
                  child: seachHistoryListWithTitle,
                ),
              ],
            ),
          );
        });
  }
}

class InitialSearchViewModel {
  final VOTDImage votdImage;
  final List<String> searchHistory;
  final bool isDarkTheme;
  final void Function(String term) onSearchEntered;
  final void Function(List<String> searchQueries) updateSearchHistory;
  final void Function(bool isDarkTheme) changeTheme;

  InitialSearchViewModel({
    this.votdImage,
    this.searchHistory,
    this.isDarkTheme,
    this.onSearchEntered,
    this.updateSearchHistory,
    this.changeTheme,
  });

  static InitialSearchViewModel fromStore(Store<AppState> store) {
    return InitialSearchViewModel(
      votdImage: store.state.votdImage,
      searchHistory: store.state.searchHistory,
      isDarkTheme: store.state.isDarkTheme,
      onSearchEntered: (term) {
        if (term.trim().length > 0) {
          store.dispatch(SearchAction(term));
        }
      },
      updateSearchHistory: (searchQueries) => store.dispatch(
          SetSearchHistoryAction(
              searchQuery: store.state.searchQuery,
              searchQueries: searchQueries)),
      changeTheme: (isDarkTheme) => store.dispatch(SetThemeAction(isDarkTheme)),
    );
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
