import 'package:flutter/material.dart';

import 'keyword_text.dart';

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
                    : KeywordText(outer: a, inner: query, c: context),
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
