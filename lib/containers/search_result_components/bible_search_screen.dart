import 'dart:async';
import 'package:bible_search/containers/sr_components.dart';
import 'package:bible_search/data/autocomplete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'keyword_text.dart';

class BibleSearchScreen extends BibleSearchDelegate<String> {
  final List<String> searchHistory;
  final Function(String) search;

  BibleSearchScreen({
    @required this.searchHistory,
    @required this.search,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context)
        : super.appBarTheme(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return query.isNotEmpty
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
    return BackButton(
      onPressed: () => close(context, searchHistory.last),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future.delayed(const Duration(microseconds: 10), () {
      search(query);
      close(context, null);
    });
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context, AutoComplete data) {
    // final results = searchHistory
    //     .where((a) => (a?.toLowerCase() ?? '').contains(query))
    //     .toList()
    //     .reversed
    //     .toList();

    return query.isNotEmpty
        ? ListView(
            children: data.possibles
                .map((a) => ListTile(
                      title: query.isEmpty
                          ? Text(a)
                          : KeywordText(outer: a, inner: query, c: context),
                      onTap: () {
                        if (query.substring(query.length - 1, query.length) ==
                            ' ') {
                          query += '$a ';
                        } else {
                          final words = query.split(' ')..last = a;
                          query = words.join(' ');
                          search(query);
                          close(context, null);
                        }
                      },
                    ))
                .toList(),
          )
        : Container();
  }
}
