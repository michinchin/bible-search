import 'package:flutter/material.dart';
import 'package:bible_search/Model/all_result.dart';

class AllPage extends StatelessWidget {
  final String title;
  final List bcv;
  final formatWords;

  AllPage({this.bcv,this.title, this.formatWords});

  @override
  Widget build(BuildContext context) {
    var book = bcv[0];
    var chapter = bcv[1];
    var verse = bcv[2];
    

    Widget _buildAllPageView(List<AllResult> allResults) { 
      return Dialog(
        child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(true),
            icon: Icon(Icons.close)
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: allResults.length,
            itemBuilder:(BuildContext context, int index){
              return ListTile(
                title: Text(
                  allResults[index].a,
                  style: Theme.of(context).textTheme.subtitle
                ),
                subtitle: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.body1,
                    children: formatWords(allResults[index].text),
                  ),
                )
              );
            }),
        ),
      )
    );
    }
    return FutureBuilder<AllResults>(
      future: AllResults.fetch(
        book: book,
        chapter: chapter,
        verse: verse,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.data.length == 0) {
          return _buildAllPageView(snapshot.data.data);
        } else if (snapshot.hasData) {
          return _buildAllPageView(snapshot.data.data);
        } 
        return _buildAllPageView([]);
      }
    );
  }
}