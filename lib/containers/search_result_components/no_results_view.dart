import 'package:bible_search/data/book.dart';
import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;

class NoResultsView extends StatelessWidget {
  final bool hasError;
  final bool hasNoTranslations;
  final int resultLength;
  final List<Book> books;
  final VoidCallback resetFilter;

  const NoResultsView(
      {this.hasError = false,
      this.hasNoTranslations = false,
      this.books,
      this.resultLength,
      this.resetFilter});

  @override
  Widget build(BuildContext context) {
    var text = '';
    var reset = false;

    if (hasError) {
      text = 'No active internet connection.\n' ' Please connect to WiFi :)';
    } else if (hasNoTranslations) {
      text = 'No translations selected. \n'
          'Please select translations to view results';
    } else if (books != null && tec.isNotNullOrZero(resultLength)) {
      final bookString =
          books.where((b) => b.isSelected).map((b) => b.name).join(',');
      text =
          'Found $resultLength results, \nbut none in the book(s): $bookString';
      reset = true;
    } else {
      text = 'No Results';
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(text),
          Divider(
            color: Colors.transparent,
          ),
          if (reset)
            RaisedButton(
              child: const Text('Reset filter?'),
              onPressed: resetFilter,
            )
        ]),
      ),
    );
  }
}
