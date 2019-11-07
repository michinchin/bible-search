import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/containers/search_result_components/ad_card.dart';
import 'package:bible_search/containers/search_result_components/result_card.dart';
import 'package:bible_search/containers/search_result_components/results_description.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/presentation/search_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:tec_native_ad/tec_native_ad.dart';

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

    final adLocations = <int>[];

    var adsAvailable = widget.vm.store.state.numAdsAvailable;

    if (adsAvailable > 0) {
      if (res.length > 2) {
        for (var i = 2; i < res.length; i += 15) {
          adLocations.add(i);
          adsAvailable--;
        }
      } else if (res.isNotEmpty) {
        adLocations.add(res.length);
      }
    }

    // the first item is a showing ... from ...
    var resOffset = 1;

    return SafeArea(
      bottom: false,
      child: Container(
          key: PageStorageKey(
              '${widget.vm.searchQuery}${res[0].ref}${res.length}'),
          padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
          child: ListView.builder(
            itemCount: res.length + 1 + adLocations.length,
            itemBuilder: (context, i) {
              if (i == 0) {
                return ResultsDescription(
                  filteredLength: res.length,
                  resultLength: widget.vm.searchResults.length,
                  filterOn: filterOn,
                  searchQuery: widget.vm.searchQuery,
                );
              }

              if (adLocations.contains(i)) {
                resOffset++;
                return AdCard(i);
              }

              return ResultCard(
                index: i - resOffset,
                res: res[i - resOffset],
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
