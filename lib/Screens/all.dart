import 'package:flutter/material.dart';
import 'package:bible_search/Model/all_result.dart';
import 'package:bible_search/Model/singleton.dart';

class AllPage extends StatelessWidget {
  final String title;
  final List bcv;
  AllPage({this.bcv,this.title});

  @override
  Widget build(BuildContext context) {
    var book = bcv[0];
    var chapter = bcv[1];
    var verse = bcv[2];
    

    Widget _buildAllPageView(List<AllResult> allResults) { 
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView.builder(
          itemCount: allResults.length,
          itemBuilder:(BuildContext context, int index){
            return ListTile(
              title: Text(allResults[index].a),
              subtitle: Text(allResults[index].text),
            );
          }),
      );
    }
    return FutureBuilder<AllResults>(
      future: AllResults.fetch(
        book: book,
        chapter: chapter,
        verse: verse,
        translations: translations,
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