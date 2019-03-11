import 'package:flutter/material.dart';
import '../UI/initial_search_components.dart';
import '../Model/votd_image.dart';
import 'package:scoped_model/scoped_model.dart';
import '../Model/search_model.dart';

// Initial Search Route (screen)
//
// This is the 'home' screen of the Bible Search app. It shows an app bar, a search bar,
// and a list of recent searches.

class InitialSearchPage extends StatelessWidget {
  final Future<VOTDImage> votd;

  const InitialSearchPage({this.votd});

  @override
  Widget build(BuildContext context) {
    var model = ScopedModel.of<SearchModel>(context);
    final _imageWidth = MediaQuery.of(context).size.width;
    final _imageHeight = MediaQuery.of(context).size.height / 3;
    final _orientation = MediaQuery.of(context).orientation;
    final _searchBarHeight = 50.0;

    final searchHistoryList = Container(
        color: Colors.white,
        child: ScopedModelDescendant<SearchModel>(
            builder: (BuildContext context, Widget child, SearchModel model) {
          return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                final words = model.searchQueries.reversed.toList();
                return ListTileTheme(
                  textColor: Colors.black,
                  iconColor: Colors.black,
                  child: Dismissible(
                    key: Key(words[index]),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'The search term "${words[index]}" has been removed')));
                      model.searchQueries
                          .removeWhere((w) => (w == words[index]));
                      model.updateSearchHistory();
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
                      // subtitle: Text('${dates[index]}'),
                      leading: Icon(Icons.access_time),
                      onTap: () {
                        model.updateSearchAndNavigateToResults(
                            context, words[index]);
                      },
                    ),
                  ),
                );
              },
              itemCount: model.searchQueries?.length ?? 0);
        }));

    final gradientAppBarImage = GradientOverlayImage(
      width: _imageWidth,
      height: _imageHeight,
      votd: votd,
      topColor: Colors.black,
      bottomColor: Colors.transparent,
    );

    final searchBox = InitialSearchBox(
      orientation: _orientation,
      height: _searchBarHeight,
      imageHeight: _imageHeight,
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
          color: Colors.grey[800],
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
            ExtendedAppBar(height: _imageHeight),
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
            value: model.isDarkTheme,
            title: Text('Light/Dark Mode'),
            onChanged: (b) {
              model.changeTheme(b, context);
            }),
        ListTile(
          leading: Icon(Icons.more),
          title: Text('About'),
          onTap: () {},
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
        ScopedModelDescendant<SearchModel>(
            builder: (BuildContext context, Widget child, SearchModel model) {
          return ListTile(
            leading: Icon(Icons.clear_all),
            title: Text('Clear Search History'),
            onTap: () {
              model.clearSearchQueries();
            },
          );
        }),
      ],
    );

    if (model.searchQueries == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading'),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
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
    }
  }
}
