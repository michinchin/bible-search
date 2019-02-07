import 'package:flutter/material.dart';
import '../Model/search_result.dart';
import '../UI/result_card.dart';
import '../UI/app_bar.dart';
import '../Screens/translation_book_filter.dart';
import '../Model/singleton.dart';

class ResultsPage extends StatefulWidget {
  final String keywords;
  final TextEditingController searchController;

  ResultsPage({Key key, this.keywords,this.searchController}) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();



}

class _ResultsPageState extends State<ResultsPage> {

  bool submitting = false;
  bool isInSelectionMode = false;

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return TranslationBookFilterPage(update: _updateSearchResults, words: widget.keywords);
      },
      fullscreenDialog: true
    ));
  }

  void _updateSearchResults(String keywords) {
    setState(() {
      searchQueries[keywords] = '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}';
      searchResults = SearchResults.fetch(keywords, translations);
      //submitting = !submitting;
    });
  }


  void _changeToSelectionMode() {
    setState(() {
      isInSelectionMode = !isInSelectionMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateSearchResults(widget.searchController.text);
  
    return FutureBuilder<SearchResults>(
          future: searchResults,
          builder: (context, snapshot) {
            //snapshot.connectionState switch statement
            if (snapshot.hasData && snapshot.data.data.length == 0) {
              return _buildView(_buildNoResults("No results ☹️"));
            } else if (snapshot.hasData) {
              return _buildView(_buildCardView(snapshot.data));
            } 
            return _buildView(_buildLoading());
          }
    );
  }

  Widget _buildView(Widget body) {
    return Scaffold(
      appBar:  SearchAppBar(
        title: widget.keywords,
        navigator: _navigateToFilter,
        searchController: widget.searchController,
        update: _updateSearchResults,
      ),
      body: SafeArea(child:body),
    );
  }
  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator(),);
  }

  Widget _buildNoResults(String text) {
    return Center(child: Text(text, style: Theme.of(context).textTheme.title,),);
  }

  Widget _buildCardView(SearchResults res) {
   return Padding(
     padding: EdgeInsets.all(10.0),
     child: ListView.custom(
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return 
          ResultCard(
            result: res.data[index], 
            text: res.data[index].verses[0].verseContent,
            verses: res.data[index].verses,
            toggleSelectionMode: _changeToSelectionMode,
            currState: isInSelectionMode,
          );
        },
        childCount: res.data.length,
      ),
   ));

  }
}

