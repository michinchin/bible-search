import 'dart:io';

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
  bool _scrolling = false;

  @override
  void initState() {
    super.initState();
    final res = widget.vm.filteredRes;
    var adsAvailable = widget.vm.store.state.numAdsAvailable;
    _adLocations = [];

    if (adsAvailable > 0) {
      if (res.length > 3) {
        for (var i = 3; i < res.length && adsAvailable > 0; i += 25) {
          _adLocations.add(i);
          adsAvailable--;
        }
      } else if (res.isNotEmpty) {
        // +1 to include showing...
        _adLocations.add(res.length + 1);
      }
    }
  }

  void _hideAd(int idx) {
    setState(() {
      _adLocations.remove(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.vm.filteredRes;

    return SafeArea(
      bottom: false,
      child: Container(
          key: PageStorageKey(
              '${widget.vm.searchQuery}${res[0].ref}${res.length}'),
          padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
          child: NotificationListener<ScrollNotification>(
            child: ListView.builder(
              itemCount: res.length + 1 + _adLocations.length,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return ResultsDescription(widget.vm);
                }

                if (_adLocations.contains(i)) {
                  return AdCard(
                    i,
                    _hideAd,
                    hideNow: _scrolling,
                  );
                }

                // we start with 1 since the first card is a showing...
                var resultOffset = 1;

                for (final location in _adLocations) {
                  if (location < i) {
                    resultOffset++;
                  }
                }

                if (i - resultOffset < res.length) {
                  return ResultCard(
                    index: i - resultOffset,
                    res: res[i - resultOffset],
                    keywords: widget.vm.searchQuery,
                    isInSelectionMode: widget.vm.isInSelectionMode,
                    selectCard: widget.vm.selectCard,
                    bookNames: widget.vm.bookNames,
                    toggleSelectionMode: widget.vm.changeToSelectionMode,
                  );
                } else {
                  return Container();
                }
              },
            ),
            onNotification: (n) {
              if (Platform.isIOS) {
                // only setState for these 2 notification types
                if (n is ScrollStartNotification) {
                  setState(() {
                    _scrolling = true;
                  });
                } else if (n is ScrollEndNotification) {
                  setState(() {
                    _scrolling = false;
                  });
                }
              }

              return false;
            },
          )),
    );
  }
}
