import 'dart:async';
import 'package:bible_search/data/translation.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:async/async.dart';
import 'package:bible_search/data/autocomplete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'keyword_text.dart';

class BibleSearchDelegate extends SearchDelegate<String> {
  final List<String> searchHistory;
  final Function(String) search;
  final BibleTranslations translations;
  CancelableOperation<AutoComplete> autoCompleteOperation;

  BibleSearchDelegate(
      {@required this.searchHistory,
      @required this.search,
      @required this.translations}) {
    // autoCompleteOperation = CancelableOperation<AutoComplete>.fromFuture(
    //     AutoComplete.fetch(
    //         phrase: query, translationIds: translations.formatIds()),
    //     onCancel: () => {debugPrint('onCancel')});
  }

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
    
    // autoCompleteOperation.cancel();
    // autoCompleteOperation = CancelableOperation<AutoComplete>.fromFuture(
    //     AutoComplete.fetch(
    //         phrase: query, translationIds: translations.formatIds()),
    //     onCancel: () => {debugPrint('onCancel')});

    // return FutureBuilder<AutoComplete>(
    //     future: autoCompleteOperation.value,
    //     builder: (c, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
            return query.isNotEmpty
                ? ListView(
                    children: results
                    // (snapshot.data?.possibles ?? [])
                        .map((a) => ListTile(
                              title: query.isEmpty
                                  ? Text(a)
                                  : KeywordText(
                                      outer: a, inner: query, c: context),
                              onTap: () {
                                query = a;
                                search(query);
                                close(context, null);
                              },
                            ))
                        .toList(),
                  )
                : Container();
        //   } else {
        //     return const Center(
        //       child: CircularProgressIndicator(),
        //     );
        //   }
        // });
  }
}
