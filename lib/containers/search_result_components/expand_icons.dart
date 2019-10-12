import 'package:bible_search/containers/sr_components.dart';
import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/verse.dart';
import 'package:bible_search/models/search_model.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:bible_search/presentation/all_translations_screen.dart';

class CardIcons extends StatefulWidget {
  final ResultCardModel model;
  final SearchResult res;
  final bool expanded;
  final List<Book> bookNames;
  final VoidCallback onExpanded;
  final VoidCallback onContext;
  final Future<void> Function(Verse, int) onTranslationChanged;
  final int currTag;
  const CardIcons(
      {@required this.model,
      @required this.res,
      @required this.expanded,
      @required this.bookNames,
      @required this.onExpanded,
      @required this.onContext,
      @required this.onTranslationChanged,
      @required this.currTag});
  @override
  _CardIconsState createState() => _CardIconsState();
}

class _CardIconsState extends State<CardIcons> {
  SearchModel searchModel;
  GlobalKey<EnsureVisibleState> ensureVisibleGlobalKey;

  @override
  void initState() {
    searchModel = SearchModel();
    ensureVisibleGlobalKey = GlobalKey<EnsureVisibleState>();
    super.initState();
  }

  Future<bool> _onDismiss(String id) {
    FeatureDiscovery.markStepComplete(context, id);
    return Future.value(false);
  }

  void _onCopy() => searchModel.shareSelection(
      context: context,
      verse: ShareVerse(
        books: widget.bookNames,
        results: [widget.res.copyWith(isSelected: true)],
      ),
      isCopy: true);

  void _onShare() => searchModel.shareSelection(
      context: context,
      verse: ShareVerse(
          books: widget.bookNames,
          results: [widget.res.copyWith(isSelected: true)]));

  void _openInTB() => searchModel.openTB(
        a: widget.res.verses[widget.res.currentVerseIndex].a,
        id: widget.res.verses[widget.res.currentVerseIndex].id,
        bookId: widget.res.bookId,
        chapterId: widget.res.chapterId,
        verseId: widget.res.verseId,
        context: context,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.expanded
          ? [
              Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                        child: widget.model.formattedTitle,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: widget.model.formattedText,
                      )),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(0),
                    color: widget.model.iconColor,
                    icon: Icon(
                      Icons.expand_less,
                    ),
                    onPressed: widget.onExpanded,
                  ),
                ],
              ),
              Stack(children: [
                ButtonBar(alignment: MainAxisAlignment.start, children: [
                  DescribedFeatureOverlay(
                    onDismiss: () => _onDismiss('context'),
                    onOpen: () async {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ensureVisibleGlobalKey.currentState.ensureVisible();
                      });
                      return true;
                    },
                    featureId: 'context',
                    title: const Text('Give Context'),
                    description: const Text(
                        'Tap here to view the surrounding verses of this scripture'),
                    tapTarget: RotatedBox(
                      quarterTurns: 1,
                      child: Icon(Icons.unfold_more, color: Colors.black),
                    ),
                    child: EnsureVisible(
                      key: ensureVisibleGlobalKey,
                      child: IconButton(
                        tooltip: 'Context',
                        color: widget.model.iconColor,
                        icon: RotatedBox(
                          quarterTurns: 1,
                          child: widget.res.contextExpanded
                              ? Icon(Icons.unfold_less)
                              : Icon(Icons.unfold_more),
                        ),
                        onPressed: widget.onContext,
                      ),
                    ),
                  ),
                ]),
                ButtonBar(
                  children: <Widget>[
                    IconButton(
                        color: widget.model.iconColor,
                        icon: Icon(Icons.content_copy),
                        onPressed: _onCopy),
                    IconButton(
                        color: widget.model.iconColor,
                        icon: Icon(Icons.share),
                        onPressed: _onShare),
                    DescribedFeatureOverlay(
                      featureId: 'open_in_TB',
                      title: const Text('Open in Tecarta Bible'),
                      description: const Text(
                          'Need more study tools? Quickly flip over to Tecarta Bible to read full chapters, '
                          'take notes, explore maps, listen to audio and get help with verse explanations!'),
                      tapTarget: Icon(Icons.exit_to_app, color: Colors.black),
                      child: IconButton(
                          color: widget.model.iconColor,
                          icon: Icon(Icons.exit_to_app),
                          onPressed: _openInTB),
                    ),
                  ],
                ),
              ]),
              _TranslationSelector(
                res: widget.res,
                model: widget.model,
                onTranslationChanged: widget.onTranslationChanged,
                currTag: widget.currTag,
              ),
            ]
          : [
              Stack(alignment: Alignment.bottomRight, children: [
                ListTile(
                  title: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: widget.model.formattedTitle),
                  subtitle: Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: widget.model.formattedText),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(0),
                  color: widget.model.iconColor,
                  icon: Icon(
                    Icons.expand_more,
                  ),
                  onPressed: widget.onExpanded,
                ),
              ])
            ],
    );
  }
}

class _TranslationSelector extends StatefulWidget {
  final SearchResult res;
  final ResultCardModel model;
  final Future<void> Function(Verse, int) onTranslationChanged;
  final int currTag;

  const _TranslationSelector(
      {@required this.res,
      @required this.model,
      @required this.onTranslationChanged,
      @required this.currTag});
  @override
  __TranslationSelectorState createState() => __TranslationSelectorState();
}

class __TranslationSelectorState extends State<_TranslationSelector> {
  @override
  Widget build(BuildContext context) {
    final allButton = ButtonTheme(
        minWidth: 50,
        child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Text('ALL'),
          onPressed: () {
            Navigator.of(context).push<void>(MaterialPageRoute(
                builder: (context) {
                  return AllTranslationsScreen(
                    res: widget.res,
                    bcv: <int>[
                      widget.res.bookId,
                      widget.res.chapterId,
                      widget.res.verseId
                    ],
                    model: SearchModel(),
                    keywords: widget.model.keywords,
                  );
                },
                fullscreenDialog: true));
          },
          textColor: widget.res.isSelected
              ? widget.model.colorScheme
              : widget.model.oppColorScheme,
          splashColor: widget.res.isSelected
              ? Colors.transparent
              : Theme.of(context).accentColor,
        ));

    final buttons = <ButtonTheme>[];
    for (var i = 0; i < widget.res.verses.length; i++) {
      final each = widget.res.verses[i];
      Color buttonColor;
      Color textColor;
      if (widget.res.isSelected) {
        buttonColor = widget.currTag == each.id
            ? Theme.of(context).cardColor
            : Theme.of(context).accentColor;
        textColor = widget.currTag == each.id
            ? widget.model.oppColorScheme
            : widget.model.colorScheme;
      } else {
        buttonColor = widget.currTag == each.id
            ? Theme.of(context).accentColor
            : Colors.transparent;
        textColor = widget.currTag == each.id
            ? Theme.of(context).cardColor
            : widget.model.oppColorScheme;
      }

      buttons.add(ButtonTheme(
        minWidth: 50,
        child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text(each.a),
          textColor: textColor,
          color: buttonColor, //currently chosen, pass tag
          onPressed: () => widget.onTranslationChanged(each, i),
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Wrap(
          alignment: WrapAlignment.spaceAround,
          children: buttons..add(allButton)),
    );
  }
}
