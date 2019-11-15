import 'dart:io';

import 'package:bible_search/containers/iap_dialog.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/version.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tec_native_ad/tec_native_ad.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:url_launcher/url_launcher.dart' as launcher;

class AdCard extends StatefulWidget {
  final int index;
  final void Function(int) hideAd;
  final bool hideNow;

  const AdCard(this.index, this.hideAd, {this.hideNow});

  @override
  _AdCardState createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AdCardViewModel>(
        distinct: true,
        converter: (store) => AdCardViewModel(store),
        builder: (context, vm) {
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
                    child: widget.hideNow
                        ? Container()
                        : TecNativeAd(
                            adUnitId: prefAdMobNativeAdId,
                            uniqueId: 'list-${widget.index}',
                            adFormat: 'text',
                            darkMode: Theme.of(context).brightness !=
                                Brightness.light,
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
                      onPressed: () {
                        showModalBottomSheet<void>(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15))),
                            context: context,
                            builder: (context) => Container(
                                  child: Wrap(
                                    children: <Widget>[
                                      ListTile(
                                        title: const Text('Hide this ad'),
                                        leading:
                                            Icon(Icons.remove_circle_outline),
                                        onTap: () {
                                          Navigator.of(context).maybePop();
                                          widget.hideAd(widget.index);
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Remove ads'),
                                        leading: Icon(Icons.money_off),
                                        onTap: () => vm.removeAds(context),
                                      ),
                                      ListTile(
                                          title: const Text(
                                              'Why am I seeing this ad?'),
                                          leading: Icon(Icons.info),
                                          onTap: () => vm.whyAdDialog(context)),
                                      ListTile(
                                        title: const Text('Send feedback'),
                                        leading: Icon(Icons.feedback),
                                        onTap: () {
                                          Navigator.of(context).maybePop();
                                          vm.emailFeedback(
                                              context, 'list-${widget.index}');
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Close'),
                                        leading: Icon(Icons.close),
                                        onTap: () =>
                                            Navigator.of(context).pop(),
                                      )
                                    ],
                                  ),
                                ));
                      },
                    ),
                  ),
                ],
              ));
        });
  }
}

class AdCardViewModel {
  final Store<AppState> store;
  Future<void> Function(BuildContext, String) emailFeedback;
  void Function(BuildContext) whyAdDialog;
  void Function(BuildContext) removeAds;

  AdCardViewModel(this.store) {
    emailFeedback = _emailFeedback;
    whyAdDialog = _showWhyAd;
    removeAds = _removeAds;
  }

  void _removeAds(BuildContext context) {
    final ua = store.state.userAccount;
    if (ua.user.userId == 0) {
      showDialog<bool>(
          context: context,
          builder: (c) => SignInForPurchasesDialog(ua)).then((_) {
        showDialog<bool>(
            context: context, builder: (c) => InAppPurchaseDialog());
      });
    } else {
      showDialog<bool>(context: context, builder: (c) => InAppPurchaseDialog());
    }
  }

  void _showWhyAd(BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Text('Why am I seeing ads?'),
              content: const Text(
                  'Bible Search! is an ad supported app. To support the app\'s continued development, text only ads will occasionally appear in the search results.'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: const Text('Remove Ads'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _removeAds(context);
                  },
                )
              ],
            ));
  }

  /// Opens the native email UI with an email for questions or comments.
  Future<void> _emailFeedback(BuildContext context, String uniqueId) async {
    var email = 'biblesupport@tecarta.com';
    if (!Platform.isIOS) {
      email = 'androidsupport@tecarta.com';
    }
    final di = await tec.DeviceInfo.fetch();
    print(
        'Running on ${di.productName} with ${tec.DeviceInfo.os} ${di.version}');
    final version =
        (appVersion == 'DEBUG-VERSION' ? '(debug version)' : 'v$appVersion');
    final subject = 'Feedback regarding Bible Search! $version '
        'with ${di.productName} ${tec.DeviceInfo.os} ${di.version}';
    final adHeadline = await NativeAdController.instance
        .getHeadline(prefAdMobNativeAdId, uniqueId);
    final body =
        'I have the following question or comment about an ad with headline ($adHeadline):\n\n\n';
    final url = Uri.encodeFull('mailto:$email?subject=$subject&body=$body');

    try {
      if (await launcher.canLaunch(url)) {
        await launcher.launch(url, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      final msg = 'Error emailing: ${e.toString()}';
      showToastAndPop(context, msg);
      print(msg);
    }
  }
}
