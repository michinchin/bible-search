import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Model/search_result.dart';
import '../UI/result_card.dart';
import '../UI/app_bar.dart';
import '../Screens/translation_book_filter.dart';
import '../Model/singleton.dart';
import 'package:share/share.dart';

class ResultsPage extends StatefulWidget {
  final String keywords;
  final VoidCallback updateSearchHistory;
  ResultsPage({Key key, this.keywords, this.updateSearchHistory})
      : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _isInSelectionMode = false;
  var _future;
  int idx = 0;
  var _numSelected = 0;
  SearchAppBar _appbar;
  String _keywords;

  @override
  void initState() {
    _keywords = widget.keywords;
    _future = SearchResults.fetch(widget.keywords);
    _appbar = SearchAppBar(
      title: _keywords,
      navigator: _navigateToFilter,
      update: _updateSearchResults,
      shareSelection: _shareSelection,
      changeToSelectionMode: _changeToSelectionMode,
      numSelected: _numSelected,
    );
    super.initState();
  }

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return TranslationBookFilterPage(
              tabValue: 0, updateTranslations: _updateTranslations);
        },
        fullscreenDialog: true));
  }

  void _updateSearchResults(String keywords) {
    if (keywords.length > 0) {
      searchQueries.add(keywords);
      widget.updateSearchHistory();
    }

    setState(() {
      _keywords = keywords;
      _future = SearchResults.fetch(_keywords);
      // SearchAppBar.of(context).onFieldChange(_keywords);
    });
  }

  void _updateTranslations() {
    setState(() {
      _future = SearchResults.fetch(_keywords);
    });
  }

  // loop through search results and filter only books that are selected
  List<SearchResult> _filterByBook(List<SearchResult> searchRes) {
    final sr = searchRes.where((res) {
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
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
      if (!_isInSelectionMode) {
        _deselectAll();
      }
      _appbar = SearchAppBar(
        title: _keywords,
        navigator: _navigateToFilter,
        update: _updateSearchResults,
        shareSelection: _shareSelection,
        isInSelectionMode: _isInSelectionMode,
        changeToSelectionMode: _changeToSelectionMode,
        numSelected: _numSelected,
      );
    });
  }

  void _shareSelection(BuildContext context, bool isCopy) async {
    var text = "";
    for (final each in searchResults) {
      final currVerse = each.verses[each.currentVerseIndex];
      if (each.isSelected && each.contextExpanded) {
        text +=
            '${bookNames.where((book) => book.id == each.bookId).first.name} ' +
                '${each.chapterId}:' +
                '${each.verses[each.currentVerseIndex].verseIdx[0]}' +
                '-${each.verses[each.currentVerseIndex].verseIdx[1]} ' +
                '(${each.verses[each.currentVerseIndex].a})' +
                '\n${currVerse.contextText}\n\n';
      } else if (each.isSelected) {
        text += "${each.ref} (${currVerse.a})\n${currVerse.verseContent}\n\n";
      } else {
        text += "";
      }
    }
    if (text.length > 0) {
      !isCopy
          ? Share.share(text)
          : await Clipboard.setData(ClipboardData(text: text)).then((x) {
              _showToast(context, 'Copied!');
            });
    } else {
      _showToast(context, 'Please make a selection');
    }
  }

  void _deselectAll() {
    _numSelected = 0;
    for (final each in searchResults) {
      each.isSelected = false;
    }
  }

  void _showToast(BuildContext context, String label) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).cardColor,
        content: Text(label, style: Theme.of(context).textTheme.body1),
        action: SnackBarAction(
            label: 'CLOSE', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void _selectCard(bool select) {
    setState(() {
      select ? _numSelected++ : _numSelected--;
      if (_numSelected == 0) {
        _changeToSelectionMode();
      } else {
        _appbar = SearchAppBar(
          title: _keywords,
          navigator: _navigateToFilter,
          update: _updateSearchResults,
          shareSelection: _shareSelection,
          isInSelectionMode: _isInSelectionMode,
          changeToSelectionMode: _changeToSelectionMode,
          numSelected: _numSelected,
        );
      }
    });
  }

  final _loadingView = Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(children: [
        ListView.builder(
          itemCount: 15,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.all(10.0),
              child: Placeholder(
                color: Theme.of(context).accentColor.withAlpha(100),
                fallbackWidth: MediaQuery.of(context).size.width - 30,
                fallbackHeight: MediaQuery.of(context).size.height / 5,
              ),
            );
          },
        ),
        Center(
          child: CircularProgressIndicator(),
        )
      ]));

  @override
  Widget build(BuildContext context) {
    //on translation change, the view should reload
    print('rebuilt ${DateTime.now().second}');

    return FutureBuilder<List<SearchResult>>(
        future: _future,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return _buildView(
                  _buildNoResults("Please Connect to the Internet ☹️"));
            case ConnectionState.waiting:
              return _buildView(_loadingView);
            case ConnectionState.active:
            case ConnectionState.done:
              if ((snapshot.hasData && snapshot.data.length == 0) ||
                  snapshot.data == null) {
                return _buildView(_buildNoResults("No results ☹️"));
              } else if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return _buildView(_buildNoResults("No results ☹️"));
                }
                searchResults = _filterByBook(snapshot.data);
                return searchResults.length > 0
                    ? _buildView(_buildCardView())
                    : _buildView(_buildNoResults(
                        "No results with Current Book Filter ☹️"));
              }
          }
        });
  }

  Widget _buildView(Widget body) {
    return Scaffold(
        appBar: _appbar,
        body: SafeArea(
            child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: body)));
  }

  Widget _buildNoResults(String text) {
    searchResults = [];
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.title,
        ),
      ),
    );
  }

  Widget _buildCardView() {
    var _controller = ScrollController();
    var container = Container(
      key: PageStorageKey(
          _keywords + '${searchResults[0].ref}' + '${searchResults.length}'),
      padding: EdgeInsets.all(10.0),
      child: ListView.builder(
        itemCount: searchResults == null ? 1 : searchResults.length + 1,
        controller: _controller,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.caption,
                    children: [
                      TextSpan(
                        text: 'Showing ${searchResults.length} results for ',
                      ),
                      TextSpan(
                          text: '$_keywords',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            );
          }
          index -= 1;
          // if(_isInSelectionMode) {searchResults[index].isSelected = false;}
          return Container(
            padding: EdgeInsets.all(5.0),
            child: ResultCard(
              res: searchResults[index],
              toggleSelectionMode: _changeToSelectionMode,
              keywords: _keywords,
              isInSelectionMode: _isInSelectionMode,
              selectCard: _selectCard,
            ),
          );
        },
      ),
    );
    return container;
  }
}
