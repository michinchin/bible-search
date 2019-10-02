import 'dart:io';

import 'package:bible_search/models/search_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:dynamic_theme/dynamic_theme.dart';

import 'package:bible_search/presentation/search_result_screen.dart';
import 'package:bible_search/presentation/translation_book_filter_screen.dart';

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
    _isInSelectionMode = widget.model.isInSelectionMode;
    sm = SearchModel();
    super.initState();
  }

  @override
  void didUpdateWidget(SearchAppBar oldWidget) {
    _isInSelectionMode = widget.model.isInSelectionMode;
    super.didUpdateWidget(oldWidget);
  }

  void _showModalSheet() {
    showModalBottomSheet<void>(
        context: context,
        builder: (c) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.check_circle),
                  title: const Text('Selection Mode'),
                  onTap: _changeToSelectionMode,
                ),
                SwitchListTile.adaptive(
                    secondary: Icon(Icons.lightbulb_outline),
                    value: widget.model.state.isDarkTheme,
                    title: Text(widget.model.state.isDarkTheme
                        ? 'Dark Mode'
                        : 'Light Mode'),
                    onChanged: (b) {
                      DynamicTheme.of(context).setThemeData(ThemeData(
                        primarySwatch: b ? Colors.teal : Colors.orange,
                        primaryColorBrightness: Brightness.dark,
                        brightness: b ? Brightness.dark : Brightness.light,
                      ));
                      widget.model.changeTheme(b);
                      Navigator.of(context).pop();
                    }),
              ],
            ));
  }

  void _changeToSelectionMode() {
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
      widget.model.changeToSelectionMode();
    });
    Navigator.of(context).pop();
  }

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push<MaterialPageRoute>(MaterialPageRoute(
        builder: (context) => TranslationBookFilterScreen(tabValue: 0),
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
                        color: Colors.black38,
                        offset: const Offset(0, 5.0),
                        blurRadius: 5.0,
                      ),
                    ]),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const BackButton(),
                  title: InkWell(
                      onTap: widget.showSearch,
                      child: Text(
                        widget.model.searchQuery ?? 'Search Here',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () => _navigateToFilter(context),
                    ),
                    IconButton(
                      icon: Platform.isAndroid
                          ? const Icon(Icons.more_vert)
                          : const Icon(Icons.more_horiz),
                      onPressed: _showModalSheet,
                    )
                  ]),
                ),
              ),
            ),
          ])
        : AppBar(
            title: Text('${widget.model.state.numSelected}'),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: _changeToSelectionMode,
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.content_copy),
                onPressed: () => sm.shareSelection(
                    context: context,
                    verse: ShareVerse(
                        books: widget.model.bookNames,
                        results: widget.model.filteredRes),
                    isCopy: true),
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => sm.shareSelection(
                    context: context,
                    verse: ShareVerse(
                        books: widget.model.bookNames,
                        results: widget.model.filteredRes)),
              )
            ],
          );
  }
}
