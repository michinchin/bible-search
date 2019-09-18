import 'dart:async';
import 'dart:io';

import 'package:bible_search/labels.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:tec_util/tec_util.dart' as tec;

class InAppPurchaseDialog extends StatefulWidget {
  @override
  _InAppPurchaseDialogState createState() => _InAppPurchaseDialogState();
}

const id = 'upgrade';

class _InAppPurchaseDialogState extends State<InAppPurchaseDialog> {
  InAppPurchaseConnection iap;
  bool _available;
  List<ProductDetails> _products;
  List<PurchaseDetails> _purchases;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  Future<void> _initPurchase;

  @override
  void initState() {
    iap = InAppPurchaseConnection.instance;
    _available = true;
    _products = [];
    _purchases = [];
    _initPurchase = _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    _available = await iap.isAvailable();
    if (_available) {
      final futures = <Future>[
        _getProducts(),
        _getPastPurchases(),
        _verifyPurchases()
      ];
      await Future.wait<void>(futures);

      final purchaseUpdates = iap.purchaseUpdatedStream;
      _subscription = purchaseUpdates.listen(_handlePurchaseUpdates);
    } else {}
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetails) {
    debugPrint('New Purchases!');
    setState(() {
      _purchases = purchaseDetails;
    });
    _verifyPurchases();
  }

  Future<void> _verifyPurchases() async {
    final purchase = _hasPurchased(id);
    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      await tec.Prefs.shared.setBool(removedAdsPref, true);
    }
  }

  Future<void> _getProducts() async {
    final ids = <String>[id] //ignore: prefer_collection_literals
        .toSet();
    final response = await iap.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Could not retrieve products');
      return;
    }
    setState(() {
      _products = response.productDetails;
    });
  }

  Future<void> _getPastPurchases() async {
    final response = await iap.queryPastPurchases();
    for (final purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        await iap.completePurchase(purchase);
      }
    }
    setState(() {
      _purchases = response.pastPurchases;
    });
  }

  void _buyProduct() {
    Navigator.of(context).maybePop();
    if (tec.isNotNullOrEmpty(_products)) {
      final purchaseParam = PurchaseParam(productDetails: _products.first);
      iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  PurchaseDetails _hasPurchased(String productId) {
    if (_purchases.isNotEmpty) {
      return _purchases.firstWhere((p) => p.productID == productId);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initPurchase,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Text(
                  'Would you like to pay a small fee to not see ads?'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('No')),
                FlatButton(onPressed: _buyProduct, child: const Text('Yes')),
              ],
            );
          }
          return Center(
            child: const CircularProgressIndicator(),
          );
        });
  }
}
