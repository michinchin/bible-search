import 'dart:core';
import 'dart:io';
import 'dart:math' as math;

import 'package:bible_search/presentation/all.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/context.dart';
import '../data/search_result.dart';
import '../data/verse.dart';

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
  var _currTag;

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
      widget.selectCard(widget.index,widget.res.isSelected);
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

  _openTB() async {
    var url = Platform.isIOS
        ? 'bible://${widget.res.verses[widget.res.currentVerseIndex].a}' +
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
      content: Text(
          'Easily navigate to scriptures in the Bible by downloading our Bible app.'),
      actions: [
        FlatButton(
          child: Text('No Thanks'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Okay'),
          onPressed: () async {
            var url = Platform.isIOS
                ? 'itms-apps://itunes.apple.com/app/id325955298'
                : '';
            if (await canLaunch(url)) {
              try {
                await launch(url);
              } catch (e) {
                Navigator.of(context).pop();
                print(e);
              }
            } else {
              Navigator.of(context).pop();
            }
          },
        )
      ],
    );
    showDialog(context: context, builder: (x) => dialog);
  }

  List<TextSpan> _formatWords(String paragraph) {
    final List<String> contentText = paragraph.split(' ');
    List<TextSpan> content = contentText.map((s) => TextSpan(text: s)).toList();
    var contentCopy = <TextSpan>[];
    var keywords = widget.keywords;
    urlEncodingExceptions
        .forEach((k, v) => keywords = keywords.replaceAll(RegExp(k), v));
    final formattedKeywords = keywords.toLowerCase().split(' ');

    //convert each contentText item to a TextSpan
    // if matches a keyword, change to bold TextSpan
    for (var i = 0; i < content.length; i++) {
      var text = <TextSpan>[];
      final w = content[i].text;
      for (final search in formattedKeywords) {
        if (w.toLowerCase().contains(search)) {
          final start = w.toLowerCase().indexOf(search);
          final end = start + search.length;
          final prefix = w.substring(0, start);
          final suffix = w.substring(end, w.length);
          if (prefix.length > 0) {
            text.add(TextSpan(text: prefix));
          }
          if (prefix.length == 0 && suffix.length == 0) {
            text.add(TextSpan(
                text: w + ' ', style: TextStyle(fontWeight: FontWeight.bold)));
          } else {
            suffix.length > 0
                ? text.add(TextSpan(
                    text: search,
                    style: TextStyle(fontWeight: FontWeight.bold)))
                : text.add(TextSpan(
                    text: search + ' ',
                    style: TextStyle(fontWeight: FontWeight.bold)));
          }
          if (suffix.length > 0) {
            text.add(TextSpan(text: suffix + ' '));
          }
        }
      }
      (text.length > 0)
          ? text.forEach((ts) {
              contentCopy.add(ts);
            })
          : contentCopy.add(TextSpan(text: w + ' '));
    }
    return contentCopy;
  }

  @override
  Widget build(BuildContext context) {
    final Text nonContextTitle = Text(
        '${widget.res.ref} ${widget.res.verses[widget.res.currentVerseIndex].a}');
    final Text contextTitle = Text(
        '${widget.bookNames.where((book) => book.id == widget.res.bookId).first.name} ' +
            '${widget.res.chapterId}:' +
            '${widget.res.verses[widget.res.currentVerseIndex].verseIdx[0]}' +
            '-${widget.res.verses[widget.res.currentVerseIndex].verseIdx[1]} ' +
            '${widget.res.verses[widget.res.currentVerseIndex].a}');
    final String content = !widget.res.contextExpanded
        ? widget.res.verses[widget.res.currentVerseIndex].verseContent
        : widget.res.verses[widget.res.currentVerseIndex].contextText;

    final colorScheme = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    final oppColorScheme = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    final _formattedTitle = Text(
      widget.res.contextExpanded ? contextTitle.data : nonContextTitle.data,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: widget.res.isSelected ? colorScheme : oppColorScheme),
    );

    final _formattedText = RichText(
      text: TextSpan(
        style: !widget.res.isSelected
            ? Theme.of(context).textTheme.body1
            : TextStyle(
                color: colorScheme,
              ),
        children: _formatWords(content),
      ),
    );

    final _iconColor = widget.res.isSelected ? colorScheme : oppColorScheme;

    final allButton = FlatButton(
      child: Text('ALL'),
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute<dynamic>(builder: (context) {
          return AllPage(
              title: widget.res.ref,
              bcv: [
                widget.res.bookId,
                widget.res.chapterId,
                widget.res.verseId
              ],
              formatWords: _formatWords,
            );
        }));
      },
      textColor: widget.res.isSelected ? colorScheme : oppColorScheme,
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
          textColor = _currTag == each.id ? oppColorScheme : colorScheme;
        } else {
          buttonColor = _currTag == each.id
              ? Theme.of(context).accentColor
              : Colors.transparent;
          textColor = _currTag == each.id
              ? Theme.of(context).cardColor
              : oppColorScheme;
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
            child: _formattedTitle),
        subtitle: _formattedText,
      ),
      Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            color: _iconColor,
            icon: Icon(Icons.expand_less),
            onPressed: _expandButtonPressed,
          )),
      Stack(children: [
        ButtonTheme.bar(
          child: ButtonBar(alignment: MainAxisAlignment.start, children: [
            IconButton(
              color: _iconColor,
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
                color: _iconColor,
                icon: Icon(Icons.content_copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                          text: _formattedTitle.data + '\n' + content))
                      .then((_) {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Successfully Copied!')));
                  });
                }, // set state here
              ),
              IconButton(
                color: _iconColor,
                icon: Icon(Icons.share),
                onPressed: () {
                   String verseContent = widget.res.contextExpanded
                      ? contextTitle.data +
                          '\n' +
                          widget.res.verses[widget.res.currentVerseIndex]
                              .contextText
                      : nonContextTitle.data +
                          '\n' +
                          widget.res.verses[widget.res.currentVerseIndex]
                              .verseContent;
                  Share.share(verseContent);
                }, // set state here
              ),
              IconButton(
                color: _iconColor,
                icon: Icon(Icons.exit_to_app),
                onPressed: _openTB, // set state here
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
            child: _formattedTitle),
        subtitle: _formattedText,
      ),
      Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            color: _iconColor,
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