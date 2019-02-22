import 'package:flutter/material.dart';
import '../Model/search_result.dart';
import '../Model/verse.dart';
import '../Screens/all.dart';
import '../Model/context.dart';
import '../Model/singleton.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';


class ResultCard extends StatefulWidget {
  final SearchResult res;
  final toggleSelectionMode;
  final currState;
  var currText;
  final String keywords;

  ResultCard({Key key, this.res, this.toggleSelectionMode, this.currState, this.keywords}) : super(key: key);

  @override
  _ResultCardState createState() => _ResultCardState();
  
}

class _ResultCardState extends State<ResultCard> {
  var _currTag;

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
    });
  }

  _openTB() async {
      var url = Platform.isIOS ? 'bible://${widget.res.verses[widget.res.currentVerseIndex].a}' +
      '/${widget.res.bookId}/${widget.res.chapterId}/${widget.res.verseId}' 
      : '';
      
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        //couldn't launch, open app store
        print('Could not launch $url');
        _showAppStoreDialog();
      }
    }

  void _showAppStoreDialog() {
    // final navigatorKey = GlobalKey<NavigatorState>();
    // final context = navigatorKey.currentState.overlay.context;
    final dialog = AlertDialog(
      title: Text('Download TecartaBible'),
      content: Text('Easily navigate to scriptures in the Bible by downloading our Bible app.'),
      actions: [
        FlatButton(child: Text('No Thanks'),
        onPressed: () {
          Navigator.of(context).pop();
        },),
        FlatButton(child: Text('Okay'),
        onPressed: () async{
          var url = Platform.isIOS ? 'itms-apps://itunes.apple.com/app/id325955298' : '';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            Navigator.of(context).pop();
            throw "Couldn't launch $url";
          }
        },)
      ],
    );
    showDialog(context: context, builder: (x) => dialog);
  }

  List<TextSpan> _formatWords(String paragraph) {
    final List<String> contentText = paragraph.split(' ');
    List<TextSpan> content = contentText.map((s)=> TextSpan(text: s)).toList();
    var contentCopy = <TextSpan>[];
    final keywords = widget.keywords.toLowerCase().split(' ');
    //convert each contentText item to a TextSpan
    // if matches a keyword, change to bold TextSpan
    for (var i = 0; i < content.length; i++) {
      var text = <TextSpan>[];
      final w = content[i].text;
      for (final search in keywords) {
        if (w.toLowerCase().contains(search)) {
          final start = w.toLowerCase().indexOf(search);
          final end = start + search.length;
          final prefix = w.substring(0, start);
          final suffix = w.substring(end, w.length);
          if (prefix.length > 0) {
            text.add(TextSpan(text: prefix));
          }
          if (prefix.length == 0 && suffix.length == 0){
            text.add(TextSpan(text: w + ' ', style: TextStyle(fontWeight: FontWeight.bold)));
          } else {
            suffix.length > 0 ? text.add(TextSpan(text: search, style: TextStyle(fontWeight: FontWeight.bold))) : 
            text.add(TextSpan(text: search + ' ', style: TextStyle(fontWeight: FontWeight.bold)));
          }
          if (suffix.length > 0) {
            text.add(TextSpan(text: suffix + ' '));
          }
        }
      }
      (text.length > 0) ?
      text.forEach((ts){contentCopy.add(ts);}):contentCopy.add(TextSpan(text: w + ' '));
    }
    return contentCopy;
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
              formatWords:_formatWords,
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

  final Text nonContextTitle = Text('${widget.res.ref} ${widget.res.verses[widget.res.currentVerseIndex].a}');
  final Text contextTitle = Text('${bookNames.where((book)=>book.id == widget.res.bookId).first.name} '+
                              '${widget.res.chapterId}:'+
                              '${widget.res.verses[widget.res.currentVerseIndex].verseIdx[0]}'+
                              '-${widget.res.verses[widget.res.currentVerseIndex].verseIdx[1]} '+
                              '${widget.res.verses[widget.res.currentVerseIndex].a}');
  final String content = !widget.res.contextExpanded ? widget.res.verses[widget.res.currentVerseIndex].verseContent:
                                      widget.res.verses[widget.res.currentVerseIndex].contextText;

  final _formattedText = RichText(
    text: TextSpan(
      style: Theme.of(context).textTheme.body1,
      children: _formatWords(content),
    ),
  );

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
                    title: !widget.res.contextExpanded ? nonContextTitle : contextTitle,
                    subtitle: _formattedText, 
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
                title: Align(
                  alignment: Alignment.topLeft,
                  child: FlatButton(
                  onPressed: ()=>_openTB(),
                  child: !widget.res.contextExpanded ? nonContextTitle : contextTitle,
                )),
                subtitle: _formattedText,
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