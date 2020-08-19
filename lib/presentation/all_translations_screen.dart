import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/containers/search_result_components/no_results_view.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:redux/redux.dart';

import 'package:share/share.dart';

import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/models/search_model.dart';
import 'package:bible_search/Data/all_result.dart';
import 'package:tec_widgets/tec_widgets.dart';

class AllTranslationsScreen extends StatelessWidget {
  final SearchResult res;
  final String keywords;

  const AllTranslationsScreen({this.res, this.keywords});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AllTranslationsScreenViewModel>(
        distinct: true,
        converter: (s) => AllTranslationsScreenViewModel(s),
        builder: (context, vm) {
          if (keywords.contains(':') && res.verses.isNotEmpty) {
            return _VerseAllResultsPage(res: res, vm: vm);
          } else {
            return _FutureAllResultsPage(res: res, vm: vm, keywords: keywords);
          }
        });
  }
}

class _VerseAllResultsPage extends StatelessWidget {
  final SearchResult res;
  final AllTranslationsScreenViewModel vm;
  final String keywords;
  const _VerseAllResultsPage({this.res, this.vm, this.keywords});
  @override
  Widget build(BuildContext context) {
    final model = SearchModel();
    return Scaffold(
        appBar: AppBar(
          title: Text(res.ref),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
              itemCount: res.verses.length,
              itemBuilder: (context, index) {
                final allResults = res.verses;
                final text = '${res.ref} ${allResults[index].a}\n${allResults[index].verseContent}';
                return _AllResultCard(
                  title: '${vm.store.state.translations.getFullName(allResults[index].id)}\n',
                  subtitle: [TextSpan(text: allResults[index].verseContent)],
                  copy: () => model.copyPressed(text: text, context: context),
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
              }),
        ));
  }
}

class _FutureAllResultsPage extends StatelessWidget {
  final SearchResult res;
  final AllTranslationsScreenViewModel vm;
  final String keywords;
  const _FutureAllResultsPage({this.res, this.vm, this.keywords});

  @override
  Widget build(BuildContext context) {
    final model = SearchModel();
    final book = res.bookId;
    final chapter = res.chapterId;
    final verse = res.verseId;
    final _future = AllResults.fetch(
        book: book, chapter: chapter, verse: verse, translations: vm.store.state.translations);

    return FutureBuilder<AllResults>(
        future: _future,
        builder: (context, snapshot) {
          final allResults = snapshot.data == null ? <AllResult>[] : snapshot.data.data;

          return Scaffold(
            appBar: AppBar(
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
                        itemBuilder: (context, index) {
                          final text =
                              '${res.ref} ${allResults[index].a}\n${allResults[index].text}';
                          return _AllResultCard(
                            title:
                                '${vm.store.state.translations.getFullName(allResults[index].id)}\n',
                            subtitle: model.formatWords(
                              '${allResults[index].text}',
                              keywords,
                            ),
                            copy: () => model.copyPressed(text: text, context: context),
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
  }
}

class _AllResultCard extends StatelessWidget {
  final String title;
  final List<InlineSpan> subtitle;
  final VoidCallback copy;
  final VoidCallback share;
  final VoidCallback openInTB;
  const _AllResultCard({this.title, this.subtitle, this.copy, this.share, this.openInTB});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).brightness == Brightness.light
          ? ThemeData(
              accentColor: Colors.orange, iconTheme: const IconThemeData(color: Colors.black54))
          : Theme.of(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          title: AutoSizeText.rich(
            TextSpan(children: [
              TextSpan(
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                  text: title),
              TextSpan(style: Theme.of(context).textTheme.bodyText2, children: subtitle),
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
                      icon: Icon(Platform.isIOS ? SFSymbols.doc_on_doc : Icons.content_copy),
                    ),
                    IconButton(
                        tooltip: 'Share',
                        onPressed: share,
                        icon: Icon(Platform.isIOS ? SFSymbols.square_arrow_up : OMIcons.share)),
                    IconButton(
                      tooltip: 'Open in TecartaBible',
                      onPressed: openInTB,
                      icon: const Icon(TecIcons.tbOutlineLogo),
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
