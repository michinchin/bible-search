import 'package:flutter/material.dart';
import '../Model/search_result.dart';

class ResultCard extends StatefulWidget {
  final SearchResult result;

  ResultCard({Key key, this.result}) : super(key: key);

  @override
  _ResultCardState createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {

  @override
  Widget build(BuildContext context) {
    
    var text = widget.result.verses[0].verseContent;

    return Container(
      child: Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.book),
            title: Text(widget.result.ref),
            subtitle: Text(text),
          ),
          ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text('CONTEXT'),
                  onPressed: () { 
                    setState(() {
                      text = 'hello';
                    });/* ... */ }, // set state here
                ),
                FlatButton(
                  child: const Text('COMPARE'),
                  onPressed: () { /* ... */ },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }
}