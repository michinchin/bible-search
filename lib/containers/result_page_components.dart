import 'dart:async';

import 'package:bible_search/containers/result_card.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/presentation/translation_book_filter.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bible_search/presentation/results_page.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ResultsViewModel model;
  final Function(BuildContext, bool, String) shareSelection;

  SearchAppBar({
    Key key,
    @required this.model,
    @required this.shareSelection,
  }) : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  // only expose a getter to prevent bad usage
  bool _isInSelectionMode;

  @override
  initState() {
    _isInSelectionMode = widget.model.isInSelectionMode;
    super.initState();
  }

  @override
  void didUpdateWidget(SearchAppBar oldWidget) {
    _isInSelectionMode = widget.model.isInSelectionMode;
    super.didUpdateWidget(oldWidget);
  }

  void _showSearch() {
    showSearch(
      query: widget.model.searchQuery,
      context: context,
      delegate: BibleSearchDelegate(
          searchHistory: widget.model.searchHistory,
          search: widget.model.updateSearchResults),
    );
  }

  void _changeToSelectionMode() {
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
      widget.model.changeToSelectionMode();
    });
  }

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return TranslationBookFilterPage(tabValue: 0);
        },
        fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    return !_isInSelectionMode
        ? Stack(children: [
            AppBar(
              elevation: 0.0,
              brightness: Brightness.light,
              backgroundColor: Theme.of(context).canvasColor,
              bottomOpacity: 0.0,
              toolbarOpacity: 0.0,
            ),
            SafeArea(
                minimum: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Container(
                    height: widget.preferredSize.height,
                    width: widget.preferredSize.width,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10.0),
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            offset: Offset(0, 5.0),
                            blurRadius: 5.0,
                          ),
                        ]),
                    child: Center(
                      child: TextField(
                        enableInteractiveSelection: false,
                        focusNode: FocusNode(),
                        onTap: () => _showSearch(),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          hintText: widget.model.searchQuery ?? 'Search Here',
                          prefixIcon: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          border: InputBorder.none,
                          suffixIcon: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      end: 40.0),
                                  child: IconButton(
                                    icon: Icon(Icons.filter_list),
                                    onPressed: () => _navigateToFilter(context),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 0.0),
                                    child: IconButton(
                                      icon: Icon(Icons.more_horiz),
                                      onPressed: ()  {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (BuildContext c) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.check_circle),
                                                        title: Text(
                                                            'Selection Mode'),
                                                        onTap: () =>
                                                            _changeToSelectionMode(),
                                                      ),
                                                      SwitchListTile(
                                                          secondary: Icon(Icons
                                                              .lightbulb_outline),
                                                          value: widget
                                                              .model
                                                              .state
                                                              .isDarkTheme,
                                                          title: Text(
                                                              'Light/Dark Mode'),
                                                          onChanged: (b) {
                                                            DynamicTheme.of(
                                                                    context)
                                                                .setThemeData(
                                                                    ThemeData(
                                                              primarySwatch: b
                                                                  ? Colors.teal
                                                                  : Colors
                                                                      .orange,
                                                              primaryColorBrightness:
                                                                  Brightness
                                                                      .dark,
                                                              brightness: b
                                                                  ? Brightness
                                                                      .dark
                                                                  : Brightness
                                                                      .light,
                                                            ));
                                                            widget.model
                                                                .changeTheme(b);
                                                          }),
                                                    ],
                                                  );
                                                });
                                          },
                                    )),
                              ]),
                        ),
                      ),
                    ))),
          ])
        : AppBar(
            title: Text('${widget.model.state.numSelected}'),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => _changeToSelectionMode(),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.content_copy),
                onPressed: () => widget.shareSelection(
                    context, true, widget.model.getSelectedText()),
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => widget.shareSelection(
                    context, false, widget.model.getSelectedText()),
              )
            ],
          );
  }
}

class CardView extends StatefulWidget {
  final ResultsViewModel vm;
  CardView(this.vm);

  @override
  State<StatefulWidget> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  // NativeAdController nativeAdController;
  final _adIndex = 3;

  @override
  void initState() {
    super.initState();
    // nativeAdController = NativeAdController(
    //     adUnitId: 'ca-app-pub-5279916355700267/7203757709',
    //     numberOfAds: 1,
    //   );
  }

  @override
  Widget build(BuildContext context) {
    var res = widget.vm.filteredRes;
    var container = Container(
        key: PageStorageKey(
            widget.vm.searchQuery + '${res[0].ref}' + '${res.length}'),
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemBuilder: (context, i) {
            if (i == 0) {
              return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.caption,
                        children: [
                          TextSpan(
                            text: 'Showing ${res.length} results for ',
                          ),
                          TextSpan(
                              text: '${widget.vm.searchQuery}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ));
            } 
            // else if (i == _adIndex &&
            //     (nativeAdController?.adCount ?? 0) > 0 &&
            //     res.length > _adIndex) {
            //   return TecNativeAd();
            // }
            i -= 1;
            // if (i >= _adIndex && (nativeAdController?.adCount ?? 0) > 0) {
            //   i -= 1;
            // }
            if (i < res.length) {
              return _buildRow(res[i], i);
            }
          },
        ));
    return container;
  }

  Widget _buildRow(SearchResult res, int i) {
    return ResultCard(
      index: i,
      res: res,
      keywords: widget.vm.searchQuery,
      isInSelectionMode: widget.vm.isInSelectionMode,
      selectCard: widget.vm.selectCard,
      bookNames: widget.vm.bookNames,
      toggleSelectionMode: widget.vm.changeToSelectionMode,
    );
  }
}

class BibleSearchDelegate extends SearchDelegate {
  final List<String> searchHistory;
  final Function(String) search;
  var _closeButton;

  BibleSearchDelegate({this.searchHistory, this.search});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context)
        : super.appBarTheme(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return query.length > 0
        ? [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                query = '';
              },
            )
          ]
        : [];
  }

  @override
  Widget buildLeading(BuildContext context) {
    _closeButton = IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        close(context, searchHistory.last);
      },
    );
    return _closeButton;
  }

  @override
  Widget buildResults(BuildContext context) {
    Future.delayed(Duration(microseconds: 10), () {
      search(query);
      close(context, null);
    });
    return Container();
  }

  Widget _getFormattedSearchQueries(
      String outer, String inner, BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final arr = outer.split(inner);
    List<TextSpan> spans = [];
    for (final each in arr) {
      spans.add(TextSpan(
          text: each,
          style:
              TextStyle(color: isDarkTheme ? Colors.grey[200] : Colors.grey)));
      spans.add(TextSpan(
          text: inner,
          style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold)));
    }
    spans.removeLast();
    return RichText(
      text: TextSpan(
        children: spans,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List results = searchHistory
        .where((a) => (a?.toLowerCase() ?? '').contains(query))
        .toList()
        .reversed
        .toList();
    return ListView(
      children: results
          .map<ListTile>((a) => ListTile(
                title: query.length == 0
                    ? Text(a)
                    : _getFormattedSearchQueries(a, query, context),
                onTap: () {
                  query = a;
                  search(query);
                  close(context, null);
                },
              ))
          .toList(),
    );
  }
}
