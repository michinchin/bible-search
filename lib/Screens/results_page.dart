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

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return TranslationBookFilterPage();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SearchResults>(
          future: searchResults,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data.data.length == 0) {
              return _buildView(_buildNoResults());
            } else if (snapshot.hasData) {
              return _buildView(_buildCardView(snapshot.data));
            } 
            return _buildView(_buildLoading());
          }
    );
  }

  Widget _buildView(Widget body) {
    return Scaffold(
      appBar:  SearchAppBar(title: widget.keywords, navigator: _navigateToFilter,searchController: widget.searchController,),
      body: body,
    );
  }
  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator(),);
  }

  Widget _buildNoResults() {
    return Center(child: Text("No results ☹️", style: Theme.of(context).textTheme.title,),);
  }

  Widget _buildCardView(SearchResults res) {
    return Container(
      padding: EdgeInsets.all(10),
      child: CustomScrollView(
        slivers: [
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 2.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ResultCard(result: res.data[index]);
              },
              childCount: res.data.length,
            ),
          ),
        ]),
    );
  }
}