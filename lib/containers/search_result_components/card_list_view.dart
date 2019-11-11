import 'package:bible_search/containers/search_result_components/ad_card.dart';
import 'package:bible_search/containers/search_result_components/results_description.dart';
import 'package:bible_search/containers/search_result_components/result_card.dart';
import 'package:bible_search/presentation/search_result_screen.dart';
import 'package:flutter/material.dart';

class CardView extends StatefulWidget {
  final ResultsViewModel vm;
  const CardView(this.vm);

  @override
  State<StatefulWidget> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  List<int> _adLocations;
  // the first item is a showing ... from ...
  int resOffset;

  @override
  void initState() {
    super.initState();
    final res = widget.vm.filteredRes;
    var adsAvailable = widget.vm.store.state.numAdsAvailable;
    _adLocations = [];
    resOffset = 1;

    if (adsAvailable > 0) {
      if (res.length > 3) {
        for (var i = 3; i < res.length && adsAvailable > 0; i += 15) {
          _adLocations.add(i);
          adsAvailable--;
        }
      } else if (res.isNotEmpty) {
        _adLocations.add(res.length);
      }
    }
  }

  void _hideAd(int idx) {
    setState(() {
      _adLocations.remove(idx);
      resOffset--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.vm.filteredRes;

    final filterOn =
        widget.vm.filteredRes.length != widget.vm.searchResults.length;

    // every build - we need to reset resOffset
    // first index is always "showing..." so start at 1
    resOffset = 1;

    return SafeArea(
      bottom: false,
      child: Container(
          key: PageStorageKey(
              '${widget.vm.searchQuery}${res[0].ref}${res.length}'),
          padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
          child: ListView.builder(
            itemCount: res.length + 1 + _adLocations.length,
            itemBuilder: (context, i) {
              if (i == 0) {
                return ResultsDescription(
                  filteredLength: res.length,
                  resultLength: widget.vm.searchResults.length,
                  filterOn: filterOn,
                  searchQuery: widget.vm.searchQuery,
                );
              }

              if (_adLocations.contains(i)) {
                resOffset++;
                return AdCard(i, _hideAd);
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
