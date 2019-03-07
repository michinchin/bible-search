import 'package:flutter/material.dart';
import '../Model/search_result.dart';
import '../UI/result_card.dart';
import '../UI/app_bar.dart';
import '../Screens/translation_book_filter.dart';
import '../Model/singleton.dart';
import 'package:share/share.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';


class ResultsPage extends StatefulWidget {
  final String keywords;
  final TextEditingController searchController;
  final VoidCallback updateSearchHistory;
  ResultsPage(
      {Key key, this.keywords, this.searchController, this.updateSearchHistory})
      : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _isInSelectionMode = false;
  var future;
  int idx = 0;
  bool _hasUpdated = true;
  var numSelected = 0;

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return TranslationBookFilterPage(tabValue: 0);
        },
        fullscreenDialog: true));
  }

  void _updateSearchResults(String keywords) {
    searchQueries.add(keywords);
    widget.updateSearchHistory();
    widget.searchController.text =keywords;
    _hasUpdated = true;
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
      _isInSelectionMode = !_isInSelectionMode;
  }

  void _shareSelection(BuildContext context) {
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
      Share.share(text);
      _deselectAll();
    } else {
      _showToast(context);
    }
  }

  void _deselectAll(){
    for (final each in searchResults) {
      each.isSelected = false;
    }
    setState(() {
    });
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).cardColor,
        content:  Text(
          'Please make a selection',
          style: Theme.of(context).textTheme.body1
        
        ),
        action: SnackBarAction(
            label: 'CLOSE', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void _selectCard(){
    setState(() {
      numSelected = searchResults.where((t)=>t.isSelected).toList().length;
    });
  }

  Widget _loadingView = 
  Container(
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
    
     if (!_hasUpdated && searchResults.length != 0) {
      searchResults = _filterByBook(searchResults);
      return _buildView(_buildCardView());
    } else {
      future = SearchResults.fetch(widget.searchController.text);
      _hasUpdated = false;
      return FutureBuilder<List<SearchResult>>(
          future: future,
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
  }

  Widget _buildView(Widget body) {
    return Scaffold(
        appBar: SearchAppBar(
          title: widget.searchController.text,
          navigator: _navigateToFilter,
          update: _updateSearchResults,
          shareSelection: _shareSelection,
        ),
        body: SafeArea(child: body));
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
      key: PageStorageKey(widget.searchController.text + '${searchResults[0].ref}' + '${searchResults.length}'),
      padding: EdgeInsets.all(10.0),
      child: DraggableScrollbar.semicircle(
        backgroundColor: Theme.of(context).cardColor,
        controller: _controller,
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
                              text: '${widget.searchController.text}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              }
              index -= 1;
              searchResults[index].isSelected = false;
              return Container(
                padding: EdgeInsets.all(5.0),
                child: ResultCard(
                  res: searchResults[index],
                  toggleSelectionMode: _changeToSelectionMode,
                  keywords: widget.searchController.text,
                ),
              );
            },
          ),
      ),
    );
    return container;
  }
}
