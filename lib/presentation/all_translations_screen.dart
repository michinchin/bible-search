import 'package:bible_search/containers/search_result_components/no_results_view.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:share/share.dart';

import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/models/search_model.dart';
import 'package:bible_search/Data/all_result.dart';

class AllTranslationsScreen extends StatelessWidget {
  final SearchResult res;
  final List<int> bcv;
  final SearchModel model;
  final String keywords;

  const AllTranslationsScreen({this.bcv, this.res, this.model, this.keywords});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AllTranslationsScreenViewModel>(
        distinct: true,
        converter: (s) => AllTranslationsScreenViewModel(s),
        builder: (context, vm) {
          final book = bcv[0];
          final chapter = bcv[1];
          final verse = bcv[2];
          final _future = AllResults.fetch(
              book: book,
              chapter: chapter,
              verse: verse,
              translations: vm.store.state.translations);

          return FutureBuilder<AllResults>(
              future: _future,
              builder: (context, snapshot) {
                final allResults =
                    snapshot.data == null ? <AllResult>[] : snapshot.data.data;

                return Scaffold(
                  appBar: AppBar(
                    title: GestureDetector(
                        onVerticalDragDown: Navigator.of(context).pop,
                        child: Text(res.ref)),
                    leading: IconButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: Icon(Icons.close)),
                  ),
                  body: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: allResults.isEmpty
                          ? snapshot.connectionState == ConnectionState.done
                              ? NoResultsView()
                              : Center(
                                  child: const CircularProgressIndicator(),
                                )
                          : ListView.builder(
                              itemCount: allResults.length,
                              itemBuilder: (context, index) {
                                final text =
                                    '${res.ref} ${allResults[index].a}\n${allResults[index].text}';
                                return Card(
                                    elevation: 2.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      '\n ${vm.store.state.translations.getFullName(allResults[index].id)}\n',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .body1,
                                                    children: model.formatWords(
                                                        '${allResults[index].text}\n',
                                                        keywords),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          onPressed: () =>
                                                              model.copyPressed(
                                                                  text: text,
                                                                  context:
                                                                      context),
                                                          icon: Icon(Icons
                                                              .content_copy),
                                                        ),
                                                        IconButton(
                                                            onPressed: () =>
                                                                Share.share(
                                                                    text),
                                                            icon: Icon(
                                                                Icons.share)),
                                                        IconButton(
                                                          onPressed: () =>
                                                              model.openTB(
                                                            a: allResults[index]
                                                                .a,
                                                            bookId: res.bookId,
                                                            id: allResults[
                                                                    index]
                                                                .id,
                                                            chapterId:
                                                                res.chapterId,
                                                            verseId:
                                                                res.verseId,
                                                            context: context,
                                                          ),
                                                          icon: Icon(Icons
                                                              .exit_to_app),
                                                        )
                                                      ]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ));
                              })),
                );
              });
        });
  }
}

class AllTranslationsScreenViewModel {
  final Store<AppState> store;
  const AllTranslationsScreenViewModel(this.store);
}
