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

  ResultsPage({Key key, this.keywords,this.searchController}) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {

  var _searchResults = <SearchResult>[];
  bool _isSubmitting = false;
  bool _isInSelectionMode = false;

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return TranslationBookFilterPage(words: widget.searchController.text);
      },
      fullscreenDialog: true
    ));
  }

  void _updateSearchResults(String keywords) {
    searchQueries[keywords] = '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}';
    _isSubmitting = !_isSubmitting;
  }

  void _changeToSelectionMode() {
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
    });
  }

  void _shareSelection() {
    var text = "";
    for (final each in _searchResults) {
      final currVerse = each.verses[each.currentVerseIndex];
      text += each.isSelected ? "${each.ref} (${currVerse.a})\n${currVerse.verseContent}\n\n" : "";
    }
    //print(text);
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilt ${DateTime.now().second}');
    // why does it rebuild every time enters textEditController

    return !_isInSelectionMode ? 
    FutureBuilder<SearchResults>(
          future: SearchResults.fetch(widget.searchController.text, translations),
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildView(_loadingView);
            }
            //snapshot.connectionState switch statement
            if (snapshot.hasData && snapshot.data.data.length == 0) {
              _searchResults = [];
              return _buildView(_buildNoResults("No results ☹️"));
            } else if (snapshot.hasData) {
              _searchResults = snapshot.data.data;
              return _buildView(_buildCardView());
            } 
            return _buildView(_loadingView);
          }
    ) : _buildSelectionView(_buildCardView());
  }

  Widget _buildSelectionView(Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selection Mode"),
        leading: IconButton(
          onPressed: _changeToSelectionMode,
          icon: Icon(Icons.close)
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareSelection,
          )
        ],
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _buildView(Widget body) {
    return Scaffold(
      appBar:  SearchAppBar(
        title: widget.keywords,
        navigator: _navigateToFilter,
        searchController: widget.searchController,
        update: _updateSearchResults,
        changeSelectionMode: _changeToSelectionMode,
      ),
      body: SafeArea(child:body),
    );
  }
  Widget _loadingView = Center(child: CircularProgressIndicator(),);

  Widget _buildNoResults(String text) {
    return Center(child: Text(text, style: Theme.of(context).textTheme.title,),);
  }

  Widget _buildCardView() {
    final res = _searchResults;
   return Container(
     padding: EdgeInsets.all(10.0),
     child: ListView.custom(
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return ResultCard(
            result: res[index], 
            text: res[index].verses[0].verseContent,
            verses: res[index].verses,
            toggleSelectionMode: _changeToSelectionMode,
            currState: _isInSelectionMode,
          );
        },
        childCount: res.length,
      ),
   ));

  }
}

