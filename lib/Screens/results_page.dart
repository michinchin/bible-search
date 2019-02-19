import 'package:flutter/material.dart';
import '../Model/search_result.dart';
import '../UI/result_card.dart';
import '../UI/app_bar.dart';
import '../Screens/translation_book_filter.dart';
import '../Model/singleton.dart';
import 'package:share/share.dart';

class ResultsPage extends StatefulWidget {
  final String keywords;
  final TextEditingController searchController;
  final updateSearchHistory;
  ResultsPage({Key key, this.keywords, this.searchController, this.updateSearchHistory})
      : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _isSubmitting = false;
  bool _isInSelectionMode = false;
  var future;

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return TranslationBookFilterPage(words: widget.searchController.text);
        },
        fullscreenDialog: true));
  }

  void _updateSearchResults(String keywords) {
    // searchQueries[keywords] =
    //     '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}';
    searchQueries.add(keywords);
    widget.updateSearchHistory();
    _isSubmitting = !_isSubmitting;
  }

  List<SearchResult> _filterByBook(List<SearchResult> searchRes){
    // loop through search results and filter only books that are selected
    final sr = searchRes.where((res){
      for (final each in bookNames) {
        if (each.id == res.bookId && each.isSelected) {
          return true;
        }
      }
      return false;
    }).toList();
    return sr;
  }

  void _changeToSelectionMode() {
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Selection Mode"),
              leading: IconButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  icon: Icon(Icons.close)),
              actions: <Widget>[
                Builder(
                  builder: (context) => IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () => _shareSelection(context),
                      ),
                ),
              ],
            ),
            body: Container(
              child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return ResultCard(
                  res: searchResults[index],
                  currState: true,
                );
              },
              itemCount: searchResults.length,
            )),
          );
        });
  }

  void _shareSelection(BuildContext context) {
    var text = "";
    for (final each in searchResults) {
      final currVerse = each.verses[each.currentVerseIndex];
      text += each.isSelected
          ? "${each.ref} (${currVerse.a})\n${currVerse.verseContent}\n\n"
          : "";
    }
    if (text.length > 0) {
      Share.share(text);
    } else {
      _showToast(context);
    }
    //print(text);
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Please make a selection'),
        action: SnackBarAction(
            label: 'CLOSE', onPressed: scaffold.hideCurrentSnackBar),
        // duration: Duration(seconds: 1),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    print('rebuilt ${DateTime.now().second}');
    // why does it rebuild every time enters textEditController
    future = SearchResults.fetch(widget.searchController.text);
    return _buildView(_buildCardView());

  }

  Widget _buildView(Widget body) {
    return Scaffold(
      appBar: SearchAppBar(
        title: widget.keywords,
        navigator: _navigateToFilter,
        searchController: widget.searchController,
        update: _updateSearchResults,
        changeSelectionMode: _changeToSelectionMode,
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _loadingView = Center(
    child: CircularProgressIndicator(),
  );

  Widget _buildNoResults(String text) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  Widget _buildCardView() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder<List<SearchResult>>(
            future: future,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return new Container(
                    padding: const EdgeInsets.all(10.0),
                    child: new Placeholder(fallbackHeight: 100.0, fallbackWidth: 100.0,),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return _buildNoResults("No Results");
                  } else {
                    searchResults = _filterByBook(snapshot.data);
                    return ResultCard(
                      res: searchResults[index],
                      toggleSelectionMode: _changeToSelectionMode,
                      currState: _isInSelectionMode,
                    );
                  }
              }
            },
          );
        },
      ),
    );
  }
}
