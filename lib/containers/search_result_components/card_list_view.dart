import 'dart:io';

import 'package:bible_search/containers/search_result_components/ad_card.dart';
import 'package:bible_search/containers/search_result_components/results_description.dart';
import 'package:bible_search/containers/search_result_components/result_card.dart';
import 'package:bible_search/presentation/search_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CardView extends StatefulWidget {
  final ResultsViewModel vm;
  const CardView(this.vm);

  @override
  State<StatefulWidget> createState() => _CardViewState();
}

///
/// Helper class that makes the relationship between
/// an item index and its BuildContext
///
class ItemContext {
  final BuildContext context;

  ItemContext({this.context});
}

class _CardViewState extends State<CardView> {
  List<int> _adLocations;
  Map<int, ItemContext> _adContexts;
  bool _hideAds = false;

  @override
  void initState() {
    super.initState();
    final res = widget.vm.filteredRes;
    var adsAvailable = widget.vm.store.state.numAdsAvailable;
    _adLocations = [];
    _adContexts = <int, ItemContext>{};

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
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      _adContexts[i] = ItemContext(context: context);

                      return AdCard(
                        i,
                        _hideAd,
                        hideNow: _hideAds,
                      );
                    }
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
                var newHideAds = false;

                for (final location in _adLocations) {
                  final ic = _adContexts[location];

                  if (ic != null) {
                    // Retrieve the RenderObject, linked to a specific item
                    final object = ic.context.findRenderObject();

                    // If none was to be found, or if not attached, ignore
                    // As we are dealing with Slivers, items no longer part of the
                    // viewport will be detached
                    if (object != null && object.attached) {
                      // Retrieve the viewport related to the scroll area
                      final viewport = RenderAbstractViewport.of(object);
                      final vpHeight = viewport.paintBounds.height;
                      final scrollableState = Scrollable.of(ic.context);
                      final scrollPosition = scrollableState.position;
                      final vpOffset = viewport.getOffsetToReveal(
                          object, 0.0);

                      // Retrieve the dimensions of the item
                      final size = object?.semanticBounds?.size;

                      // Check if the item is in the viewport
                      final deltaTop = vpOffset.offset -
                          scrollPosition.pixels;
                      final deltaBottom = deltaTop + size.height;

                      var isInViewport = false;

                      // this is the check if 80% is off screen
                      final offset = size.height * 0.80;
                      isInViewport = (deltaTop + offset) >= 0.0;
                      if (isInViewport) {
                        isInViewport = deltaBottom - offset < vpHeight;
                      }

                      if (!isInViewport) {
                        newHideAds = true;
                      }
                    }
                  }
                }

                if (newHideAds != _hideAds) {
                  setState(() {
                    _hideAds = newHideAds;
                  });
                }
              }

              return false;
            },
          )),
    );
  }
}
