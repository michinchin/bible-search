import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/containers/search_result_components/result_card.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/presentation/search_result_screen.dart';
import 'package:flutter/material.dart';

class CardView extends StatefulWidget {
  final ResultsViewModel vm;
  const CardView(this.vm);

  @override
  State<StatefulWidget> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.vm.filteredRes;
    final filterOn =
        widget.vm.filteredRes.length != widget.vm.searchResults.length;
    return SafeArea(
      bottom: false,
      child: Container(
          key: PageStorageKey(
              '${widget.vm.searchQuery}${res[0].ref}${res.length}'),
          padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
          child: ListView.builder(
            itemCount: res.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText.rich(
                        TextSpan(
                          style: Theme.of(context).textTheme.caption,
                          children: [
                            TextSpan(
                              text: 'Showing ${res.length} verses containing ',
                            ),
                            TextSpan(
                                text: '${widget.vm.searchQuery}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            if (filterOn)
                              TextSpan(
                                text:
                                    ' of ${widget.vm.searchResults.length} filtered verses',
                              )
                          ],
                        ),
                        minFontSize: defaultMinFontSize,
                      ),
                    ));
              }

              i -= 1;

              return ResultCard(
                index: i,
                res: res[i],
                keywords: widget.vm.searchQuery,
                isInSelectionMode: widget.vm.isInSelectionMode,
                selectCard: widget.vm.selectCard,
                bookNames: widget.vm.bookNames,
                toggleSelectionMode: widget.vm.changeToSelectionMode,
              );
            },
          )),
    );
  }
}
