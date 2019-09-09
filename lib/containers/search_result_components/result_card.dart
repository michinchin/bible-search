import 'dart:core';
import 'dart:math' as math;

import 'package:bible_search/data/context.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/verse.dart';
import 'package:bible_search/models/search_model.dart';
import 'package:bible_search/presentation/all_translations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';


class ResultCard extends StatefulWidget {
  final bool isInSelectionMode;
  final SearchResult res;
  final toggleSelectionMode;
  final String keywords;
  final Function(int, bool) selectCard;
  final bookNames;
  final int index;

  ResultCard({
    Key key,
    @required this.res,
    @required this.toggleSelectionMode,
    @required this.index,
    @required this.keywords,
    @required this.isInSelectionMode,
    @required this.selectCard,
    @required this.bookNames,
  }) : super(key: key);

  @override
  _ResultCardState createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  var searchModel;
  var _currTag;

  @override
  initState(){
    searchModel = SearchModel();
    super.initState();
  }

  _contextButtonPressed() {
    if (widget.res.verses[widget.res.currentVerseIndex].contextText.length ==
        0) {
      Context.fetch(
        translation: widget.res.verses[widget.res.currentVerseIndex].id,
        book: widget.res.bookId,
        chapter: widget.res.chapterId,
        verse: widget.res.verseId,
      ).then((context) {
        widget.res.verses[widget.res.currentVerseIndex].contextText =
            context.text;
        widget.res.verses[widget.res.currentVerseIndex].verseIdx = [
          context.initialVerse,
          context.finalVerse
        ];
      }).then((_) {
        setState(() {
          widget.res.contextExpanded = !widget.res.contextExpanded;
        });
      });
    } else {
      setState(() {
        widget.res.contextExpanded = !widget.res.contextExpanded;
      });
    }
  }

  _expandButtonPressed() {
    setState(() {
      widget.res.isExpanded = !widget.res.isExpanded;
    });
  }

  _selectionModeEnabled() {
    widget.toggleSelectionMode();
    _selectCard();
  }

  _selectCard() {
    setState(() {
      widget.res.isSelected = !widget.res.isSelected;
      widget.selectCard(widget.index, widget.res.isSelected);
    });
  }

  _translationChanged(Verse each, int index) async {
    widget.res.currentVerseIndex = index;

    if (widget.res.contextExpanded &&
        widget.res.verses[widget.res.currentVerseIndex].contextText.length ==
            0) {
      final context = await Context.fetch(
        translation: widget.res.verses[widget.res.currentVerseIndex].id,
        book: widget.res.bookId,
        chapter: widget.res.chapterId,
        verse: widget.res.verseId,
      );
      widget.res.verses[widget.res.currentVerseIndex].contextText =
          context.text;
      widget.res.verses[widget.res.currentVerseIndex].verseIdx = [
        context.initialVerse,
        context.finalVerse
      ];
    }

    setState(() {
      _currTag = each.id;
    });
  }

 

  
  @override
  Widget build(BuildContext context) {
    final model = ResultCardModel(
      res: widget.res,
      keywords: widget.keywords,
      bookNames: widget.bookNames,
      context: context,
      formatWords: searchModel.formatWords,
    );

    final allButton = FlatButton(
      child: Text('ALL'),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute<dynamic>(
            builder: (context) {
              return AllTranslationsScreen(
                res: widget.res,
                bcv: [
                  widget.res.bookId,
                  widget.res.chapterId,
                  widget.res.verseId
                ],
                model:searchModel,
                keywords: widget.keywords,
              );
            },
            fullscreenDialog: true));
      },
      textColor: widget.res.isSelected ? model.colorScheme : model.oppColorScheme,
      splashColor: widget.res.isSelected
          ? Colors.transparent
          : Theme.of(context).accentColor,
    );

    Widget _buildButtonStack() {
      _currTag = widget.res.verses[widget.res.currentVerseIndex].id;

      var buttons = <FlatButton>[];
      for (int i = 0; i < widget.res.verses.length; i++) {
        final each = widget.res.verses[i];
        Color buttonColor;
        Color textColor;
        if (widget.res.isSelected) {
          buttonColor = _currTag == each.id
              ? Theme.of(context).cardColor
              : Theme.of(context).accentColor;
          textColor = _currTag == each.id ? model.oppColorScheme : model.colorScheme;
        } else {
          buttonColor = _currTag == each.id
              ? Theme.of(context).accentColor
              : Colors.transparent;
          textColor = _currTag == each.id
              ? Theme.of(context).cardColor
              : model.oppColorScheme;
        }

        buttons.add(FlatButton(
          child: Text(each.a),
          textColor: textColor,
          color: buttonColor, //currently chosen, pass tag
          onPressed: () => _translationChanged(each, i),
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
        rows.add(Row(
          children: currButtons,
        ));
        rows.add(Row(children: [allButton]));
      } else {
        currButtons.add(Expanded(child: allButton));
        rows.add(Row(
          children: currButtons,
        ));
      }
      //if already at its max then don't add allButton, add allButton to the next line
      return Center(
          child: Column(
        children: rows,
      ));
    }

    List<Widget> _expandIcons = [
      ListTile(
        title: Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: model.formattedTitle),
        subtitle: model.formattedText,
      ),
      Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            color: model.iconColor,
            icon: Icon(Icons.expand_less),
            onPressed: _expandButtonPressed,
          )),
      Stack(children: [
        ButtonTheme.bar(
          child: ButtonBar(alignment: MainAxisAlignment.start, children: [
            IconButton(
              tooltip: "Context",
              color: model.iconColor,
              icon: Transform(
                transform: new Matrix4.rotationZ(math.pi / 2),
                alignment: FractionalOffset.center,
                child: widget.res.contextExpanded
                    ? Icon(Icons.unfold_less)
                    : Icon(Icons.unfold_more),
              ),
              onPressed: () {
                _contextButtonPressed();
              },
            ),
          ]),
        ),
        ButtonTheme.bar(
          child: ButtonBar(
            children: <Widget>[
              IconButton(
                color: model.iconColor,
                icon: Icon(Icons.content_copy),
                onPressed: () => searchModel.copyPressed(text: model.formattedTitle.data + '\n' + model.content,context: context), // set state here
              ),
              IconButton(
                color: model.iconColor,
                icon: Icon(Icons.share),
                onPressed: () {
                  String verseContent = widget.res.contextExpanded
                      ? model.contextTitle.data +
                          '\n' +
                          widget.res.verses[widget.res.currentVerseIndex]
                              .contextText
                      : model.nonContextTitle.data +
                          '\n' +
                          widget.res.verses[widget.res.currentVerseIndex]
                              .verseContent;
                  Share.share(verseContent);
                }, 
              ),
              IconButton(
                color: model.iconColor,
                icon: Icon(Icons.exit_to_app),
                onPressed: () => searchModel.openTB(
                  a: widget.res.verses[widget.res.currentVerseIndex].a,
                  id: widget.res.verses[widget.res.currentVerseIndex].id,
                  bookId: widget.res.bookId,
                  chapterId: widget.res.chapterId,
                  verseId: widget.res.verseId,
                  context: context,
                ), 
              ),
            ],
          ),
        ),
      ]),
      _buildButtonStack(),
    ];

    List<Widget> _unexpandIcons = [
      ListTile(
        title: Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: model.formattedTitle),
        subtitle: model.formattedText,
      ),
      Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            color: model.iconColor,
            icon: Icon(Icons.expand_more),
            onPressed: () => _expandButtonPressed(),
          ))
    ];

    return InkWell(
      borderRadius: BorderRadius.circular(15.0),
      onTap: () =>
          !widget.isInSelectionMode ? _expandButtonPressed() : _selectCard(),
      onLongPress: () =>
          !widget.isInSelectionMode ? _selectionModeEnabled() : {},
      child: Card(
        elevation: 2.0,
        color: widget.res.isSelected
            ? Theme.of(context).accentColor
            : Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.res.isExpanded ? _expandIcons : _unexpandIcons,
          ),
        ),
      ),
    );
  }
}

class ResultCardModel{
  final SearchResult res;
  final List bookNames;
  final BuildContext context;
  final List<TextSpan> Function(String, String) formatWords;
  final String keywords;
  Text nonContextTitle;
  Text contextTitle;
  String content;
  Text formattedTitle;
  RichText formattedText;
  Color colorScheme;
  Color oppColorScheme;
  Color iconColor;

  ResultCardModel({this.res, this.keywords, this.bookNames, this.context, this.formatWords}){
    nonContextTitle = Text(
        '${res.ref} ${res.verses[res.currentVerseIndex].a}');
    contextTitle = Text(
        '${bookNames.where((book) => book.id == res.bookId).first.name} ' +
            '${res.chapterId}:' +
            '${res.verses[res.currentVerseIndex].verseIdx[0]}' +
            '-${res.verses[res.currentVerseIndex].verseIdx[1]} ' +
            '${res.verses[res.currentVerseIndex].a}');
    content  = !res.contextExpanded
        ? res.verses[res.currentVerseIndex].verseContent
        : res.verses[res.currentVerseIndex].contextText;

  colorScheme = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

     oppColorScheme = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    formattedTitle = Text(
      res.contextExpanded ? contextTitle.data : nonContextTitle.data,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: res.isSelected ? colorScheme : oppColorScheme),
    );

    formattedText = RichText(
      text: TextSpan(
        style: !res.isSelected
            ? Theme.of(context).textTheme.body1
            : TextStyle(
                color: colorScheme,
              ),
        children: formatWords(content,keywords),
      ),
    );

      iconColor = res.isSelected ? colorScheme : oppColorScheme;
  }
}