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
  bool _isInSelectionMode = false;
  var future;
  var _listViewController = ScrollController();


  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return TranslationBookFilterPage(words: widget.searchController.text);
        },
        fullscreenDialog: true));
  }

  void _updateSearchResults(String keywords) {
    searchQueries.add(keywords);
    widget.updateSearchHistory();
  }
  
  // loop through search results and filter only books that are selected
  List<SearchResult> _filterByBook(List<SearchResult> searchRes) {  
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
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
    });
  }

  void _shareSelection(BuildContext context) {
    var text = "";
    for (final each in searchResults) {
      final currVerse = each.verses[each.currentVerseIndex];
      if (each.isSelected && each.contextExpanded) {
        text += '${bookNames.where((book)=>book.id == each.bookId).first.name} '+
                '${each.chapterId}:'+
                '${each.verses[each.currentVerseIndex].verseIdx[0]}'+
                '-${each.verses[each.currentVerseIndex].verseIdx[1]} '+
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
    } else {
      _showToast(context);
    }
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Please make a selection'),
        action: SnackBarAction(
            label: 'CLOSE', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  Widget _loadingView = Stack(
    children: [
      ListView.builder(
          itemCount: 15,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.all(10.0),
              child: Placeholder(
                color:Theme.of(context).accentColor.withAlpha(100),
                fallbackWidth: MediaQuery.of(context).size.width - 30,
                fallbackHeight: MediaQuery.of(context).size.height/5,
              ),
            );
          },
      ),
      Center(
        child: CircularProgressIndicator(),
      )
  ]);

  @override
  Widget build(BuildContext context) {
    print('rebuilt ${DateTime.now().second}');
    future = SearchResults.fetch(widget.searchController.text);
    return !_isInSelectionMode ? 
    FutureBuilder<List<SearchResult>>(
      future: future,
      builder: (context, snapshot) {
        switch(snapshot.connectionState){
          case ConnectionState.none:
            return _buildView(_buildNoResults("Please Connect to the Internet ☹️"));
          case ConnectionState.waiting:
            return _buildView(_loadingView);
          case ConnectionState.active:
          case ConnectionState.done:
            if ((snapshot.hasData && snapshot.data.length == 0) || snapshot.data == null) {
              return _buildView(_buildNoResults("No results ☹️"));
            } else if (snapshot.hasData) {
              searchResults = _filterByBook(snapshot.data);
              return searchResults.length > 0 ? _buildView(_buildCardView()) : _buildView(_buildNoResults("No results with Current Book Filter ☹️"));
            }
        }
      }
    ): _buildSelectionView();
  }

  Widget _buildSelectionView(){
    return Scaffold(
      appBar: AppBar(
        title: Text("Selection Mode"),
        leading: IconButton(
            onPressed: () {
              for (final each in searchResults) {
                each.isSelected = false;
              }
              setState(() {
                _isInSelectionMode = !_isInSelectionMode;
              });
            } ,
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
          controller: _listViewController,
        itemBuilder: (BuildContext context, int index) {
          return ResultCard(
            res: searchResults[index],
            currState: true,
            keywords: widget.searchController.text,
          );
        },
        itemCount: searchResults.length,
      )),
    );
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
        itemCount: searchResults.length,
        itemBuilder: (BuildContext context, int index) {
          return ResultCard(
            res: searchResults[index],
            toggleSelectionMode: _changeToSelectionMode,
            currState: _isInSelectionMode,
            keywords: widget.searchController.text,
          ); 
        },
      ),
    );
  }
}
