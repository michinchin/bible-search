import 'package:flutter/material.dart';
import '../Model/search_result.dart';
import '../Model/verse.dart';

class ResultCard extends StatefulWidget {
  final SearchResult result;
  String text;
  List<Verse> verses;
  final toggleSelectionMode;
  final currState;

  ResultCard({Key key, this.result, this.text,this.verses, this.toggleSelectionMode, this.currState}) : super(key: key);

  @override
  _ResultCardState createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  var _currTag;

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

  _translationChanged(Verse each){
    setState(() {
      widget.text = each.verseContent;
      _currTag = each.id;
    });
  }

  @override
  Widget build(BuildContext context) {

    final allButton = FlatButton(
      child: Text('ALL'), 
      onPressed: ()=>{},
      textColor: Theme.of(context).hintColor,
      splashColor: Theme.of(context).accentColor,
    );
    //not working yet
    Widget _buildButtonStack() {
      var buttons = <FlatButton>[];
      for (final each in widget.verses) {
        buttons.add(FlatButton(
          child: Text(each.a),
          textColor:  _currTag == each.id ? Theme.of(context).canvasColor : Theme.of(context).hintColor,
          color: _currTag == each.id ? Theme.of(context).accentColor : Colors.transparent, //currently chosen, pass tag
          onPressed: () =>_translationChanged(each), 
        ));
      }
      var rows = <Row>[];
      var width = MediaQuery.of(context).size.width;
      double currWidth = 0;
      var currButtons = <Expanded>[];
      for (final each in buttons) {
        currWidth += 100;
        if (currWidth >= width) {
          currWidth = 0;
          rows.add(Row(
            children: currButtons,
          ));
          currButtons = <Expanded>[];
        } else {
          currButtons.add(Expanded(child: each));
        } 
      }
      
      currWidth += 100;
      if (currWidth >= width) {
        rows.add(Row(children: currButtons,));
        rows.add(Row(children: [allButton]));
      } else {
        currButtons.add(Expanded(child:allButton));
        rows.add(Row(children: currButtons,));
      }
      //if already at its max then don't add allButton, add allButton to the next line
      return Center(
        child: Column(
        children: rows,
        )
      );
    }
      
    Widget _compareButtonWidget = !widget.result.compareExpanded ? Container() : _buildButtonStack();

    final _selectionModeCard = InkWell(
      onLongPress: widget.toggleSelectionMode,
        child: Card(
          child:
              Container(
                padding: EdgeInsets.all(10.0),
                child: CheckboxListTile(
                  value: widget.result.isSelected,
                  onChanged: (bool b) {
                    setState(() {
                      widget.result.isSelected = b;
                    });
                  },
                  controlAffinity:  ListTileControlAffinity.leading,
                  title: Text(widget.result.ref),
                  subtitle: Text(widget.text),
                ),
              ),
          
        ),
    
  
    );

    return widget.currState ? _selectionModeCard :
    InkWell(
      onLongPress: widget.toggleSelectionMode,
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
                      onPressed:  _contextButtonPressed, // set state here
                    ),
                    FlatButton(
                      child: const Text('COMPARE'),
                      onPressed: _compareButtonPressed,
                    ),
                  ],
                ),
              ),
              _compareButtonWidget,
            ],
          ),
        ),
      ),
  
    );
  
  
  }
}