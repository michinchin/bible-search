import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import 'package:tec_ads/tec_ads.dart';
import 'keyword_text.dart';

class BibleSearchDelegate extends SearchDelegate<String> {
  final List<String> searchHistory;
  final Function(String) search;
  final TecInterstitialAd interstitial;

  BibleSearchDelegate(
      {@required this.searchHistory, @required this.search, this.interstitial});

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
  Widget buildSuggestions(BuildContext context) {
    final results = searchHistory
        .where((a) => (a?.toLowerCase() ?? '').contains(query))
        .toList()
        .reversed
        .toList();
    return ListView(
      children: results
          .map((a) => ListTile(
                title: query.isEmpty
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
