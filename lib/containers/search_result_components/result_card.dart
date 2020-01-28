import 'dart:core';

import 'package:tec_util/tec_util.dart' as tec;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/containers/search_result_components/expand_icons.dart';
import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/context.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/verse.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/models/search_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class ResultCard extends StatefulWidget {
  final bool isInSelectionMode;
  final SearchResult res;
  final VoidCallback toggleSelectionMode;
  final String keywords;
  final Function(int, bool) selectCard;
  final List<Book> bookNames;
  final int index;

  const ResultCard({
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
  SearchModel searchModel;
  int _currTag;
  SearchResult _res;

  @override
  void initState() {
    searchModel = SearchModel();
    _res = searchModel.orderByDefaultTranslation(widget.res);
    _currTag = _res.verses[_res.currentVerseIndex].id;
    super.initState();
  }

  void _contextButtonPressed() {
    if (_res.verses[_res.currentVerseIndex].contextText.isEmpty) {
      Context.fetch(
        translation: _res.verses[_res.currentVerseIndex].id,
        book: _res.bookId,
        chapter: _res.chapterId,
        verse: _res.verseId,
        content: _res.verses[_res.currentVerseIndex].verseContent,
      ).then((context) {
        _res.verses[_res.currentVerseIndex].contextText = context.text;
        _res.verses[_res.currentVerseIndex].verseIdx = [
          context.initialVerse,
          context.finalVerse
        ];
      }).then((_) {
        setState(() {
          _res.contextExpanded = !_res.contextExpanded;
        });
      });
    } else {
      setState(() {
        _res.contextExpanded = !_res.contextExpanded;
      });
    }
  }

  void _expandButtonPressed() {
    setState(() {
      _res.isExpanded = !_res.isExpanded;
    });
  }

  void _selectionModeEnabled() {
    widget.toggleSelectionMode();
    _selectCard();
  }

  void _selectCard() {
    setState(() {
      _res.isSelected = !_res.isSelected;
      widget.selectCard(widget.index, _res.isSelected);
    });
  }

  Future<void> _translationChanged(Verse each, int index) async {
    _res.currentVerseIndex = index;

    if (_res.contextExpanded &&
        _res.verses[_res.currentVerseIndex].contextText.isEmpty) {
      final context = await Context.fetch(
        translation: _res.verses[_res.currentVerseIndex].id,
        book: _res.bookId,
        chapter: _res.chapterId,
        verse: _res.verseId,
        content: _res.verses[_res.currentVerseIndex].verseContent,
      );
      _res.verses[_res.currentVerseIndex].contextText = context.text;
      _res.verses[_res.currentVerseIndex].verseIdx = [
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
      res: _res,
      keywords: widget.keywords,
      bookNames: widget.bookNames,
      context: context,
      formatWords: searchModel.formatWords,
    );

    return Container(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: () =>
            !widget.isInSelectionMode ? _expandButtonPressed() : _selectCard(),
        onLongPress: () {
          if (!widget.isInSelectionMode) _selectionModeEnabled();
        },
        child: Container(
          decoration: BoxDecoration(
            color: _res.isSelected
                ? Theme.of(context).accentColor
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black12
                    : Colors.black26,
                offset: const Offset(0, 10),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ],
          ),
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: _res.isSelected
                    ? Theme.of(context).accentColor
                    : Theme.of(context).cardColor,
                child: CardIcons(
                  bookNames: widget.bookNames,
                  model: model,
                  expanded: _res.isExpanded,
                  res: _res,
                  onExpanded: _expandButtonPressed,
                  onContext: _contextButtonPressed,
                  onTranslationChanged: _translationChanged,
                  currTag: _currTag,
                ),
              )),
        ),
      ),
    );
  }
}

class ResultCardModel {
  final SearchResult res;
  final List<Book> bookNames;
  final BuildContext context;
  final List<TextSpan> Function(String, String) formatWords;
  final String keywords;
  List<int> defaultTranslationIds;
  AutoSizeText nonContextTitle;
  AutoSizeText contextTitle;
  String content;
  Text formattedTitle;
  AutoSizeText formattedText;
  Color colorScheme;
  Color oppColorScheme;
  Color iconColor;

  ResultCardModel(
      {this.res,
      this.keywords,
      this.defaultTranslationIds,
      this.bookNames,
      this.context,
      this.formatWords}) {
    final defaults =
        tec.Prefs.shared.getString(defaultTranslationsPref, defaultValue: '');
    defaultTranslationIds = defaults.split('|').map(int.tryParse).toList();
    nonContextTitle = AutoSizeText(
      '${res.verses[res.currentVerseIndex].title} ${res.verses[res.currentVerseIndex].a}',
      minFontSize: minFontSizeTitle,
    );
    final bookTitleWithVerses =
        res.verses[res.currentVerseIndex].title.split(' ');
    final bookTitle =
        bookTitleWithVerses.take(bookTitleWithVerses.length - 1).join(' ');

    contextTitle = AutoSizeText(
      '$bookTitle ${res.chapterId}:'
      '${res.verses[res.currentVerseIndex].verseIdx[0]}-${res.verses[res.currentVerseIndex].verseIdx[1]}'
      ' ${res.verses[res.currentVerseIndex].a}',
      minFontSize: minFontSizeTitle,
    );
    content = !res.contextExpanded
        ? res.verses[res.currentVerseIndex].verseContent
        : res.verses[res.currentVerseIndex].contextText;

    colorScheme = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    oppColorScheme = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xffe6e6e6)
        : Colors.black;
    formattedTitle = Text(
      res.contextExpanded ? contextTitle.data : nonContextTitle.data,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: res.isSelected ? colorScheme : oppColorScheme),
    );

    formattedText = AutoSizeText.rich(
      TextSpan(
        style: !res.isSelected
            ? Theme.of(context).textTheme.body1
            : TextStyle(
                color: colorScheme,
              ),
        children: formatWords(content, keywords),
      ),
      minFontSize: minFontSizeDescription,
    );
    iconColor = res.isSelected ? colorScheme : oppColorScheme;
  }
}
