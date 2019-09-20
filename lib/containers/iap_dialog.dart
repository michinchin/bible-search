import 'package:bible_search/models/iap.dart';
import 'package:bible_search/presentation/initial_search_screen.dart';
import 'package:flutter/material.dart';

class InAppPurchaseDialog extends StatefulWidget {
  @override
  _InAppPurchaseDialogState createState() => _InAppPurchaseDialogState();
}

class _InAppPurchaseDialogState extends State<InAppPurchaseDialog> {
  void _buyProduct() {
    InAppPurchases.purchase(removeAdsId);
    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
      title: const Text(
          'This is an ad supported app. Would you like to pay a small fee to remove ads for a year?'),
      actions: <Widget>[
        FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No')),
        FlatButton(onPressed: _buyProduct, child: const Text('Yes')),
      ],
    );
  }
}
