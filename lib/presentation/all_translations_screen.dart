import 'package:flutter/material.dart';

import 'package:share/share.dart';

import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/main.dart';
import 'package:bible_search/models/search_model.dart';
import 'package:bible_search/Data/all_result.dart';

class AllTranslationsScreen extends StatelessWidget {
  final SearchResult res;
  final List bcv;
  final SearchModel model;
  final String keywords;

  AllTranslationsScreen({this.bcv, this.res, this.model, this.keywords});

  @override
  Widget build(BuildContext context) {
    var book = bcv[0];
    var chapter = bcv[1];
    var verse = bcv[2];
    var _future = AllResults.fetch(
        book: book,
        chapter: chapter,
        verse: verse,
        translations: store.state.translations);

    Widget _buildAllPageView(List<AllResult> allResults) {
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
            padding: EdgeInsets.all(10.0),
            child: allResults.length == 0
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: allResults.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String text =
                          '${res.ref} ${allResults[index].a}\n${allResults[index].text}';
                      return Card(
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(15.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            '\n'+ store.state.translations
                                                    .getFullName(
                                                        allResults[index].id) +
                                                '\n',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style:
                                              Theme.of(context).textTheme.body1,
                                          children: model.formatWords(
                                              allResults[index].text + '\n',
                                              keywords),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () =>
                                                    model.copyPressed(
                                                        text: text,
                                                        context: context),
                                                icon: Icon(Icons.content_copy),
                                              ),
                                              IconButton(
                                                  onPressed: () =>
                                                      Share.share(text),
                                                  icon: Icon(Icons.share)),
                                              IconButton(
                                                onPressed: () => model.openTB(
                                                      a: allResults[index].a,
                                                      bookId: res.bookId,
                                                      id: allResults[index].id,
                                                      chapterId: res.chapterId,
                                                      verseId: res.verseId,
                                                      context: context,
                                                    ),
                                                icon: Icon(Icons.exit_to_app),
                                              )
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                                // Row(
                                //     mainAxisSize: MainAxisSize.min,
                                //     children: [
                                //       IconButton(
                                //         onPressed: () => model.copyPressed(
                                //             text: text, context: context),
                                //         icon: Icon(Icons.content_copy),
                                //       ),
                                //       IconButton(
                                //           onPressed: () =>
                                //               Share.share(text),
                                //           icon: Icon(Icons.share)),
                                //       IconButton(
                                //         onPressed: () => model.openTB(
                                //               a: allResults[index].a,
                                //               bookId: res.bookId,
                                //               id: allResults[index].id,
                                //               chapterId: res.chapterId,
                                //               verseId: res.verseId,
                                //               context: context,
                                //             ),
                                //         icon: Icon(Icons.exit_to_app),
                                //       )
                                //     ]),
                              ],
                            ),
                          ));
                    })),
      );
    }

    return FutureBuilder<AllResults>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildAllPageView(snapshot.data.data);
          }
          return _buildAllPageView([]);
        });
  }
}
