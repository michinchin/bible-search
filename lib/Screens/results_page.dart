import 'package:flutter/material.dart';
import '../Model/search_result.dart';
import '../UI/result_card.dart';

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
            if (snapshot.hasData) {
              return _buildCardView(snapshot.data);
            } else {
              return _createScaffold();
            }
          }
    );
  }

   Widget _createScaffold(){
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text(
          widget.keywords,
          style: Theme.of(context).textTheme.title,
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildCardView(SearchResults res) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text(
          widget.keywords,
          style: Theme.of(context).textTheme.title,
        ),
        centerTitle: true,
      ),
      body: Container(
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
      ),
    );
  }
}