import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/containers/search_result_components/result_card.dart';
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

    if (res.length > 2) {
      for (var i = 2; i < res.length && adsAvailable > 0; i += 15) {
        adLocations.add(i);
        adsAvailable--;
      }
    }
    else if (adsAvailable > 0 && res.isNotEmpty) {
      adLocations.add(res.length);
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
                                  'Showing ${res.length} verse${res.length > 1 ? 's' : ''} containing ',
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

              if (adLocations.contains(i)) {
                resOffset++;

                return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .cardColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Theme
                              .of(context)
                              .brightness == Brightness.light
                              ? Colors.black12
                              : Colors.black26,
                          offset: const Offset(0, 10),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],),
                    height: 105,
                    width: 180,
                    child: Stack(
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.hardEdge,
                          borderRadius: BorderRadius.circular(15),
                          child: TecNativeAd(
                            adUnitId: prefAdMobNativeAdId,
                            uniqueId: 'list-$i',
                            adFormat: 'text',
                            darkMode: Theme
                                .of(context)
                                .brightness != Brightness.light,
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: Theme
                                  .of(context)
                                  .brightness == Brightness.light ? Colors
                                  .black45 : Colors.grey,
                              size: 24.0,
                            ),
                            onPressed: () {

                            },
                          ),
                        ),
                      ],
                    )
                );
              }

              return ResultCard(
                index: i - resOffset,
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
