import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/containers/search_result_components/no_results_view.dart';
import 'package:bible_search/labels.dart';
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
  final String keywords;
  final bool isVerseRefSearch;

  AllTranslationsScreen(
      {this.res, this.keywords, this.isVerseRefSearch = false});

  final model = SearchModel();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AllTranslationsScreenViewModel>(
        distinct: true,
        converter: (s) => AllTranslationsScreenViewModel(s),
        builder: (context, vm) {
          final book = res.bookId;
          final chapter = res.chapterId;
          final verse = res.verseId;
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
                  appBar: isVerseRefSearch
                      ? PreferredSize(
                          preferredSize: AppBar().preferredSize,
                          child: Container(
                              padding: const EdgeInsets.only(top: 20, left: 15),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AutoSizeText.rich(
                                  TextSpan(
                                    style: Theme.of(context).textTheme.display1,
                                    children: [
                                      TextSpan(
                                          text: '${res.ref} ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  ),
                                ),
                              )))
                      : AppBar(
                          title: Text(res.ref),
                        ),
                  body: Container(
                      padding: const EdgeInsets.only(top: 8),
                      child: allResults.isEmpty
                          ? snapshot.connectionState == ConnectionState.done
                              ? NoResultsView(hasError: snapshot.hasError)
                              : const Center(
                                  child: CircularProgressIndicator(),
                                )
                          : ListView.builder(
                              itemCount: allResults.length,
                              // separatorBuilder: (c, i) => const Divider(),
                              itemBuilder: (context, index) {
                                final text =
                                    '${res.ref} ${allResults[index].a}\n${allResults[index].text}';
                                return _AllResultCard(
                                  title:
                                      '${vm.store.state.translations.getFullName(allResults[index].id)}\n',
                                  subtitle: isVerseRefSearch
                                      ? [TextSpan(text: allResults[index].text)]
                                      : model.formatWords(
                                          '${allResults[index].text}',
                                          keywords),
                                  copy: () => model.copyPressed(
                                      text: text, context: context),
                                  share: () => Share.share(text),
                                  openInTB: () => model.openTB(
                                    a: allResults[index].a,
                                    bookId: res.bookId,
                                    id: allResults[index].id,
                                    chapterId: res.chapterId,
                                    verseId: res.verseId,
                                    context: context,
                                  ),
                                );
                              })),
                );
              });
        });
  }
}

class _AllResultCard extends StatelessWidget {
  final String title;
  final List<InlineSpan> subtitle;
  final VoidCallback copy;
  final VoidCallback share;
  final VoidCallback openInTB;
  const _AllResultCard(
      {this.title, this.subtitle, this.copy, this.share, this.openInTB});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).brightness == Brightness.light
          ? ThemeData(
              accentColor: Colors.orange,
              iconTheme: IconThemeData(color: Colors.black54))
          : Theme.of(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          title: AutoSizeText.rich(
            TextSpan(children: [
              TextSpan(
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor),
                  text: title),
              TextSpan(
                  style: Theme.of(context).textTheme.body1, children: subtitle),
            ]),
            minFontSize: minFontSizeDescription,
          ),
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: ButtonBar(
                  alignment: MainAxisAlignment.end,
                  layoutBehavior: ButtonBarLayoutBehavior.constrained,
                  children: [
                    IconButton(
                      tooltip: 'Copy',
                      onPressed: copy,
                      icon: Icon(Icons.content_copy),
                    ),
                    IconButton(
                        tooltip: 'Share',
                        onPressed: share,
                        icon: Icon(Icons.share)),
                    IconButton(
                      tooltip: 'Open in TecartaBible',
                      onPressed: openInTB,
                      icon: Icon(Icons.exit_to_app),
                    )
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class AllTranslationsScreenViewModel {
  final Store<AppState> store;
  const AllTranslationsScreenViewModel(this.store);
}
