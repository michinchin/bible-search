import 'package:flutter/material.dart';
import '../Model/search_result.dart';
import '../UI/result_card.dart';
import '../UI/app_bar.dart';

class ResultsPage extends StatefulWidget {
  final Future<SearchResults> searchResults;
  final String keywords;

  ResultsPage({Key key, this.searchResults, this.keywords}) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SearchResults>(
          future: widget.searchResults,
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
      appBar:  SearchAppBar(title: widget.keywords),
    
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