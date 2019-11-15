import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/presentation/search_result_screen.dart';
import 'package:flutter/material.dart';

class ResultsDescription extends StatelessWidget {
  final ResultsViewModel vm;

  const ResultsDescription(this.vm);

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
                      'Showing ${vm.filteredLength} verse${vm.filteredLength > 1 ? 's' : ''} containing ',
                ),
                TextSpan(
                    text: '${vm.searchQuery}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (vm.filterOn)
                  if (vm.showOTLabel)
                    const TextSpan(text: ' in the Old Testament')
                  else if (vm.showNTLabel)
                    const TextSpan(text: ' in the New Testament')
                  else if (vm.booksSelected.length <= 5)
                    TextSpan(
                      text: ' in ${vm.booksSelected.map((b) {
                        return b.name;
                      }).join(', ')}',
                    )
                  else
                    const TextSpan(text: ' in current filter')
              ],
            ),
            minFontSize: defaultMinFontSize,
          ),
        ));
  }
}
