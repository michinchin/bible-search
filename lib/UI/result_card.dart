import 'package:flutter/material.dart';
import '../Model/search_result.dart';
import '../Model/verse.dart';

class ResultCard extends StatefulWidget {
  final SearchResult result;
  String text;
  List<Verse> verses;

  ResultCard({Key key, this.result, this.text,this.verses}) : super(key: key);

  @override
  _ResultCardState createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {

  _compareButtonPressed(){
    setState(() {
      widget.result.compareExpanded = !widget.result.compareExpanded;
    });
  }

  _contextButtonPressed(){
    setState(() {
      widget.text = widget.result.contextExpanded ? widget.result.verses[widget.result.currentVerseIndex].verseContent
      : widget.result.verses[widget.result.currentVerseIndex].contextText;
      widget.result.contextExpanded = !widget.result.contextExpanded;
    });
  }

  

  @override
  Widget build(BuildContext context) {

  //not working yet
  Widget _buildButtonStack() {
    var buttons = <FlatButton>[];
    for (final each in widget.verses) {
      buttons.add(FlatButton(
        child: Text(each.a),
        onPressed: () => {}, 
      ));
    }
    var rows = <Row>[];
    var width = MediaQuery.of(context).size.width;
    double currWidth = 0;
    var currButtons = <FlatButton>[];
    for (final each in buttons) {
      if (currWidth >= width) {
        currWidth = 0;
        rows.add(Row(
          children: currButtons,
        ));
        currButtons = <FlatButton>[];
      } else {
        currButtons.add(each);
      } 
      currWidth += 50;
    }
    return Column(
      children: rows,
    );
  }
    
  Widget _compareButtonWidget(){
    return Container();

    // return !widget.result.compareExpanded ? Container() : _buildButtonStack();

    // ButtonTheme(
    //   child: ButtonBar(
    //     alignment: MainAxisAlignment.start,
    //     children: List.generate(widget.verses.length, (index) {
    //     return FlatButton(
    //       child: Text(widget.verses[index].a),
    //       onPressed: () => {},  
    //     );
    //   })
    //   ),
    // );
  }

    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Card(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.book),
              title: Text(widget.result.ref),
              subtitle: Text(widget.text),
            ),
            ButtonTheme.bar( // make buttons use the appropriate styles for cards
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('CONTEXT'),
                    onPressed: () => _contextButtonPressed(), // set state here
                  ),
                  FlatButton(
                    child: const Text('COMPARE'),
                    onPressed: () => _compareButtonPressed(),
                  ),
                ],
              ),
            ),
            _compareButtonWidget(),
          ],
        ),
      ),
    ),
  );
  
  
  }
}