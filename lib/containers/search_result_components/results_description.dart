import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/labels.dart';
import 'package:flutter/material.dart';

class ResultsDescription extends StatelessWidget {
  final int resultLength;
  final int filteredLength;
  final bool filterOn;
  final String searchQuery;

  const ResultsDescription(
      {@required this.resultLength,
      @required this.filteredLength,
      @required this.filterOn,
      @required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AutoSizeText.rich(
            TextSpan(
              style: Theme.of(context).textTheme.caption,
              children: [
                TextSpan(
                  text:
                      'Showing $filteredLength verse${filteredLength > 1 ? 's' : ''} containing ',
                ),
                TextSpan(
                    text: '$searchQuery',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (filterOn)
                  TextSpan(
                    text: ' of $resultLength filtered verses',
                  )
              ],
            ),
            minFontSize: defaultMinFontSize,
          ),
        ));
  }
}
