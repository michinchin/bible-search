import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchase {
  static InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  Function _purchaseHandler;

  static void init(Function purchaseHandler) {
    _iap ??= InAppPurchase();
    _iap._purchaseHandler = purchaseHandler;
  }

  static Future<void> purchase(String productId, { bool consumable : true }) async {
    //ignore: prefer_collection_literals
    final ids = <String>[productId].toSet();

    final response =
        await InAppPurchaseConnection.instance.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Could not retrieve products');
      return;
    }

    final purchaseParam =
        PurchaseParam(productDetails: response.productDetails.first);

    if (consumable) {
      await InAppPurchaseConnection.instance
          .buyConsumable(purchaseParam: purchaseParam);
    }
    else {
      await InAppPurchaseConnection.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  void dispose() {
    _subscription.cancel();
  }

  InAppPurchase() {
    final purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen(_handlePurchaseUpdates);

    InAppPurchaseConnection.instance.isAvailable().then((available) {
      if (!available) {
        debugPrint('Unable to initialize inapps...');
        return;
      }

      InAppPurchaseConnection.instance.queryPastPurchases().then((response) {
        if (response.error != null) {
          // Handle the error.
          debugPrint('Unable to retrieve past purchases...');
        }
        else {
          _handlePurchaseUpdates(response.pastPurchases);
        }
      });
    });
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetails) {
    if (_purchaseHandler != null) {
      for (final details in purchaseDetails) {
        // status is null when it's a past purchase...
        if (details.status == PurchaseStatus.purchased || details.status == null) {
          _purchaseHandler(details.productID);

//          if (Platform.isIOS) {
//            // Mark that you've delivered the purchase. Only the App Store requires
//            // this final confirmation.
//            InAppPurchaseConnection.instance.completePurchase(purchase);
//          }
        }
      }
    }
  }
}
