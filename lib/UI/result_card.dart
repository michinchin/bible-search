import 'package:flutter/material.dart';
import '../Model/search_result.dart';
import '../Model/verse.dart';
import '../Screens/all.dart';
import '../Model/context.dart';
import '../Model/singleton.dart';


class ResultCard extends StatefulWidget {
  final SearchResult res;
  final toggleSelectionMode;
  final currState;
  var currText;

  ResultCard({Key key, this.res, this.toggleSelectionMode, this.currState}) : super(key: key);

  @override
  _ResultCardState createState() => _ResultCardState();
  
}

class _ResultCardState extends State<ResultCard> {
  var _currTag;

  @override
  void initState(){
    super.initState();
    widget.currText = widget.res.verses[widget.res.currentVerseIndex].verseContent;
  }

  _compareButtonPressed(){
    setState(() {
      widget.res.compareExpanded = !widget.res.compareExpanded;
      //on opening compare menu for first time show specified translation
      _currTag = widget.res.verses[widget.res.currentVerseIndex].id; 
    });
  }

  _contextButtonPressed() async{
    
    if(widget.res.verses[widget.res.currentVerseIndex].contextText.length == 0){
      final context = await Context.fetch(
        translation: widget.res.verses[widget.res.currentVerseIndex].id,
        book: widget.res.bookId,
        chapter: widget.res.chapterId,
        verse: widget.res.verseId,
      );
      widget.res.verses[widget.res.currentVerseIndex].contextText = context.text;
      widget.res.verses[widget.res.currentVerseIndex].verseIdx = [context.initialVerse,context.finalVerse];
    }
    
    setState(() {
      widget.res.contextExpanded = !widget.res.contextExpanded;
      widget.currText = !widget.res.contextExpanded ? widget.res.verses[widget.res.currentVerseIndex].verseContent
      : widget.res.verses[widget.res.currentVerseIndex].contextText;
    });
  }

  _translationChanged(Verse each, int index) async {
    widget.res.currentVerseIndex = index;

   if(widget.res.contextExpanded && widget.res.verses[widget.res.currentVerseIndex].contextText.length == 0){
      final context = await Context.fetch(
        translation: widget.res.verses[widget.res.currentVerseIndex].id,
        book: widget.res.bookId,
        chapter: widget.res.chapterId,
        verse: widget.res.verseId,
      );
      widget.res.verses[widget.res.currentVerseIndex].contextText = context.text;
      widget.res.verses[widget.res.currentVerseIndex].verseIdx = [context.initialVerse,context.finalVerse];
  }

    setState(() {
      _currTag = each.id;
      widget.currText = !widget.res.contextExpanded ? widget.res.verses[widget.res.currentVerseIndex].verseContent
      : widget.res.verses[widget.res.currentVerseIndex].contextText;
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
              title: widget.res.ref,
              bcv: [widget.res.bookId, widget.res.chapterId, widget.res.verseId],
            );
          });

      },
      textColor: Theme.of(context).hintColor,
      splashColor: Theme.of(context).accentColor,
    );

    Widget _buildButtonStack() {
      var buttons = <FlatButton>[];
      for (int i = 0; i < widget.res.verses.length; i++) {
        final each = widget.res.verses[i];
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
      
    Widget _compareButtonWidget = !widget.res.compareExpanded ? Container() : _buildButtonStack();

    final _selectionModeCard = InkWell(
        child: Card(
          child:
              Container(
                padding: EdgeInsets.all(10.0),
                child: CheckboxListTile(
                  value: widget.res.isSelected,
                  onChanged: (bool b) {
                    setState(() {
                      widget.res.isSelected = b;
                    });
                  },
                  controlAffinity:  ListTileControlAffinity.leading,
                  title: Text('${widget.res.ref} ${widget.res.verses[widget.res.currentVerseIndex].a}'),
                  subtitle: Text(widget.res.verses[widget.res.currentVerseIndex].verseContent),
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
                  child: !widget.res.contextExpanded ? 
                        Text('${widget.res.ref} ${widget.res.verses[widget.res.currentVerseIndex].a}'):
                        Text('${bookNames.where((book)=>book.id == widget.res.bookId).first.name} '+
                              '${widget.res.chapterId}:'+
                              '${widget.res.verses[widget.res.currentVerseIndex].verseIdx[0]}'+
                              '-${widget.res.verses[widget.res.currentVerseIndex].verseIdx[1]} '+
                              '${widget.res.verses[widget.res.currentVerseIndex].a}'),
                )),
                subtitle: Text(widget.currText),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      textColor: widget.res.contextExpanded ? Theme.of(context).accentColor : Theme.of(context).hintColor,
                      child: const Text('CONTEXT'),
                      onPressed:  _contextButtonPressed, // set state here
                    ),
                    FlatButton(
                      textColor: widget.res.compareExpanded ? Theme.of(context).accentColor : Theme.of(context).hintColor,
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