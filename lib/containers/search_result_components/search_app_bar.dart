import 'package:bible_search/presentation/translation_book_filter_screen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bible_search/presentation/search_result_screen.dart';

import 'bible_search_delegate.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ResultsViewModel model;
  final Function(BuildContext, bool, String) shareSelection;

  const SearchAppBar({
    Key key,
    @required this.model,
    @required this.shareSelection,
  }) : super(key: key);

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

  @override
  void initState() {
    _isInSelectionMode = widget.model.isInSelectionMode;
    super.initState();
  }

  @override
  void didUpdateWidget(SearchAppBar oldWidget) {
    _isInSelectionMode = widget.model.isInSelectionMode;
    super.didUpdateWidget(oldWidget);
  }

  void _showSearch() {
    showSearch<String>(
      query: widget.model.searchQuery, //widget.model.searchQuery
      context: context,
      delegate: BibleSearchDelegate(
          searchHistory: widget.model.searchHistory,
          search: widget.model.updateSearchResults),
    );
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
                SwitchListTile(
                    secondary: Icon(Icons.lightbulb_outline),
                    value: widget.model.state.isDarkTheme,
                    title: const Text('Light/Dark Mode'),
                    onChanged: (b) {
                      DynamicTheme.of(context).setThemeData(ThemeData(
                        primarySwatch: b ? Colors.teal : Colors.orange,
                        primaryColorBrightness: Brightness.dark,
                        brightness: b ? Brightness.dark : Brightness.light,
                      ));
                      widget.model.changeTheme(b);
                    }),
              ],
            ));
  }

  void _changeToSelectionMode() {
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
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: InkWell(
                      onTap: _showSearch,
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
                      icon: Icon(Icons.more_horiz),
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
