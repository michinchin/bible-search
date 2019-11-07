import 'package:bible_search/labels.dart';
import 'package:flutter/material.dart';
import 'package:tec_native_ad/tec_native_ad.dart';

class AdCard extends StatelessWidget {
  final int index;
  const AdCard(this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black12
                  : Colors.black26,
              offset: const Offset(0, 10),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        height: 105,
        width: 180,
        child: Stack(
          children: [
            ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(15),
              child: TecNativeAd(
                adUnitId: prefAdMobNativeAdId,
                uniqueId: 'list-$index',
                adFormat: 'text',
                darkMode: Theme.of(context).brightness != Brightness.light,
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black45
                      : Colors.grey,
                  size: 24.0,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ));
  }
}
