import 'package:flutter/material.dart';
import '../Model/search_result.dart';
import '../Model/verse.dart';
import '../Screens/all.dart';
import '../Model/context.dart';
import '../Model/singleton.dart';


class ResultCard extends StatefulWidget {
  final int index;
  final toggleSelectionMode;
  final currState;
  var currText;

  ResultCard({Key key, this.index, this.toggleSelectionMode, this.currState}) : super(key: key);

  @override
  _ResultCardState createState() => _ResultCardState();
  
}

class _ResultCardState extends State<ResultCard> {
  var _currTag;

  @override
  void initState(){
    super.initState();
    widget.currText = searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].verseContent;
  }

  _compareButtonPressed(){
    setState(() {
      searchResults[widget.index].compareExpanded = !searchResults[widget.index].compareExpanded;
      //on opening compare menu for first time show specified translation
      _currTag = searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].id; 
    });
  }

  _contextButtonPressed() async{
    
    if(searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].contextText.length == 0){
      final context = await Context.fetch(
        translation: searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].id,
        book: searchResults[widget.index].bookId,
        chapter: searchResults[widget.index].chapterId,
        verse: searchResults[widget.index].verseId,
      );
      searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].contextText = context.text;
      searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].verseIdx = [context.initialVerse,context.finalVerse];
    }
    
    setState(() {
      searchResults[widget.index].contextExpanded = !searchResults[widget.index].contextExpanded;
      widget.currText = !searchResults[widget.index].contextExpanded ? searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].verseContent
      : searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].contextText;
    });
  }

  _translationChanged(Verse each, int index) async {
    searchResults[widget.index].currentVerseIndex = index;

   if(searchResults[widget.index].contextExpanded && searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].contextText.length == 0){
      final context = await Context.fetch(
        translation: searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].id,
        book: searchResults[widget.index].bookId,
        chapter: searchResults[widget.index].chapterId,
        verse: searchResults[widget.index].verseId,
      );
      searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].contextText = context.text;
      searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].verseIdx = [context.initialVerse,context.finalVerse];
  }

    setState(() {
      _currTag = each.id;
      widget.currText = !searchResults[widget.index].contextExpanded ? searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].verseContent
      : searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].contextText;
    });
  }

  void _show() {
    final navigatorKey = GlobalKey<NavigatorState>();
    final context = navigatorKey.currentState.overlay.context;
    final dialog = AlertDialog(
      content: Text('Test'),
    );
    showDialog(context: context, builder: (x) => dialog);
  }

  @override
  Widget build(BuildContext context) {
    final allButton = FlatButton(
      child: Text('ALL'), 
      onPressed: (){
         showDialog(
          context: context,
          builder: (BuildContext context) {
            return AllPage(
              title: searchResults[widget.index].ref,
              bcv: [searchResults[widget.index].bookId, searchResults[widget.index].chapterId, searchResults[widget.index].verseId],
            );
          });

      },
      textColor: Theme.of(context).hintColor,
      splashColor: Theme.of(context).accentColor,
    );

    Widget _buildButtonStack() {
      var buttons = <FlatButton>[];
      for (int i = 0; i < searchResults[widget.index].verses.length; i++) {
        final each = searchResults[widget.index].verses[i];
        buttons.add(FlatButton(
          child: Text(each.a),
          textColor:  _currTag == each.id ? Theme.of(context).canvasColor : Theme.of(context).hintColor,
          color: _currTag == each.id ? Theme.of(context).accentColor : Colors.transparent, //currently chosen, pass tag
          onPressed: () =>_translationChanged(each, i), 
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
      
    Widget _compareButtonWidget = !searchResults[widget.index].compareExpanded ? Container() : _buildButtonStack();

    final _selectionModeCard = InkWell(
        child: Card(
          child:
              Container(
                padding: EdgeInsets.all(10.0),
                child: CheckboxListTile(
                  value: searchResults[widget.index].isSelected,
                  onChanged: (bool b) {
                    setState(() {
                      searchResults[widget.index].isSelected = b;
                    });
                  },
                  controlAffinity:  ListTileControlAffinity.leading,
                  title: Text('${searchResults[widget.index].ref} ${searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].a}'),
                  subtitle: Text(searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].verseContent),
                ),
              ),
        ),
    );


    return widget.currState ? _selectionModeCard :
    InkWell(
      onLongPress: () => widget.toggleSelectionMode(),
        child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.book),
                title: Align(
                  alignment: Alignment.topLeft,
                  child: FlatButton(
                  onPressed: ()=>{},
                  child: !searchResults[widget.index].contextExpanded ? 
                        Text('${searchResults[widget.index].ref} ${searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].a}'):
                        Text('${bookNames.where((book)=>book.id == searchResults[widget.index].bookId).first.name} '+
                              '${searchResults[widget.index].chapterId}:'+
                              '${searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].verseIdx[0]}'+
                              '-${searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].verseIdx[1]} '+
                              '${searchResults[widget.index].verses[searchResults[widget.index].currentVerseIndex].a}'),
                )),
                subtitle: Text(widget.currText),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      textColor: searchResults[widget.index].contextExpanded ? Theme.of(context).accentColor : Theme.of(context).hintColor,
                      child: const Text('CONTEXT'),
                      onPressed:  _contextButtonPressed, // set state here
                    ),
                    FlatButton(
                      textColor: searchResults[widget.index].compareExpanded ? Theme.of(context).accentColor : Theme.of(context).hintColor,
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