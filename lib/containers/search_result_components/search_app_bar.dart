import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/models/search_model.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:bible_search/presentation/search_result_screen.dart';
import 'package:bible_search/presentation/translation_book_filter_screen.dart';
import 'package:flutter/scheduler.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ResultsViewModel model;
  final VoidCallback showSearch;

  const SearchAppBar({Key key, @required this.model, @required this.showSearch})
      : super(key: key);

  @override
  Size get preferredSize {
    return Size.fromHeight(kToolbarHeight);
  }

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  // only expose a getter to prevent bad usage
  bool _isInSelectionMode;
  SearchModel sm;

  @override
  void initState() {
    super.initState();
    _isInSelectionMode = widget.model.isInSelectionMode;
    sm = SearchModel();
  }

  @override
  void didUpdateWidget(SearchAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isInSelectionMode = widget.model.isInSelectionMode;
  }

  void _changeToSelectionMode() {
    if (!_isInSelectionMode) {
      TecToast.show(context,
        'Entered Selection Mode',
      );
    }
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
      widget.model.changeToSelectionMode();
    });
  }

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push<MaterialPageRoute>(MaterialPageRoute(
        builder: (context) => TranslationBookFilterScreen(tabValue: 0),
        fullscreenDialog: true));
  }

  Future<bool> _onDismiss(int idx) async {
    final futureFeatures = featureIds.getRange(idx + 1, featureIds.length);
    FeatureDiscovery.discoverFeatures(context, futureFeatures.toSet());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return !_isInSelectionMode
        ? Stack(children: [
            AppBar(
                elevation: 0.0,
                brightness: Theme.of(context).brightness,
                backgroundColor: Colors.transparent,
                bottomOpacity: 0.0,
                toolbarOpacity: 0.0,
                leading: null),
            SafeArea(
              minimum: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Container(
                height: widget.preferredSize.height,
                width: widget.preferredSize.width,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black12
                            : Colors.black26,
                        offset: const Offset(0, 10),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ]),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: IconButton(
                    tooltip: 'Menu',
                    icon: Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  title: InkWell(
                      onTap: widget.showSearch,
                      child: AutoSizeText(
                        widget.model.searchQuery ?? 'Search Here',
                        minFontSize: minFontSizeDescription,
                        semanticsLabel:
                            'Current Search Text is ${widget.model.searchQuery}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (!widget.model.isVerseRefSearch)
                      DescribedFeatureOverlay(
                        featureId: featureIds[0],
                        onDismiss: () => _onDismiss(0),
                        tapTarget: Icon(
                          Icons.check_circle_outline,
                          color: Colors.black,
                        ),
                        title: const Text('Selection Mode'),
                        description: const Text(
                            'Tap here to enter selection mode. Select multiple scripture verses to copy or share!'),
                        child: IconButton(
                          tooltip: 'Selection Mode',
                          icon: Icon(Icons.check_circle_outline),
                          onPressed: _changeToSelectionMode,
                        ),
                      ),
                    DescribedFeatureOverlay(
                      featureId: featureIds[1],
                      tapTarget: Icon(
                        Icons.filter_list,
                        color: Colors.black,
                      ),
                      onDismiss: () => _onDismiss(1),
                      title: const Text('Filter'),
                      description: const Text(
                          'Check out the filter page! Filter search results by translation and books of the Bible'),
                      child: IconButton(
                        tooltip: 'Filter',
                        icon: Icon(Icons.filter_list),
                        onPressed: () => _navigateToFilter(context),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ])
        : AppBar(
            title: AutoSizeText('${widget.model.numSelected}'),
            leading: IconButton(
              tooltip: 'Exit Selection Mode',
              icon: Icon(Icons.close),
              onPressed: _changeToSelectionMode,
            ),
            actions: <Widget>[
              IconButton(
                  tooltip: 'Copy Selected',
                  icon: Icon(Icons.content_copy),
                  onPressed: () async {
                    // final hasfinishedCopy =
                    await sm.shareSelection(
                        context: context,
                        verse: ShareVerse(
                            books: widget.model.bookNames,
                            results: widget.model.filteredRes),
                        isCopy: true);
                    // if (hasfinishedCopy) {
                    //   _changeToSelectionMode();
                    // }
                  }),
              IconButton(
                  tooltip: 'Share Selected',
                  icon: Icon(Icons.share),
                  onPressed: () async {
                    // final hasFinishedShare =
                    await sm.shareSelection(
                        context: context,
                        verse: ShareVerse(
                            books: widget.model.bookNames,
                            results: widget.model.filteredRes));
                    // if (hasFinishedShare) {
                    //   _changeToSelectionMode();
                    // }
                  })
            ],
          );
  }
}
