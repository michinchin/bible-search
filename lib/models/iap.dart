import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchases {
  static InAppPurchases _iap;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  Function _purchaseHandler;

  static void init(Function purchaseHandler) {
    _iap ??= InAppPurchases();
    _iap._purchaseHandler = purchaseHandler;
  }

  static void restorePurchases() {
    if (_iap != null) {
      _iap._restorePurchases();
    }
  }

  static void purchase(String productId, {bool consumable = true}) {
    if (_iap != null) {
      _iap._purchase(productId, consumable);
    }
  }

  Future<void> _purchase(String productId, bool consumable) async {
    final available = await InAppPurchaseConnection.instance.isAvailable();

    if (available) {
      //ignore: prefer_collection_literals
      final ids = <String>[productId].toSet();

      final response =
      await InAppPurchaseConnection.instance.queryProductDetails(ids);

      if (response.notFoundIDs.isNotEmpty) {
        print('Could not retrieve products');
        return;
      }

      var sandbox = false;

      assert(() {
        sandbox = true;
        return true;
      }());

      final purchaseParam = PurchaseParam(
          productDetails: response.productDetails.first,
          sandboxTesting: sandbox);

      if (consumable) {
        await InAppPurchaseConnection.instance
            .buyConsumable(purchaseParam: purchaseParam);
      } else {
        await InAppPurchaseConnection.instance
            .buyNonConsumable(purchaseParam: purchaseParam);
      }
    }
  }

  void dispose() {
    _subscription.cancel();
  }

  InAppPurchases() {
    final purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen(_handlePurchaseUpdates);

    InAppPurchaseConnection.instance.isAvailable().then((available) {
      if (!available) {
        print('Unable to initialize inapps...');
        return;
      }
    });
  }

  void _restorePurchases() {
    InAppPurchaseConnection.instance.isAvailable().then((available) {
      if (available) {
        InAppPurchaseConnection.instance.queryPastPurchases().then((response) {
          if (response.error != null) {
            // Handle the error.
            print('Unable to restore purchases...');
          } else {
            _handlePurchaseUpdates(response.pastPurchases);
          }
        });
      }
    });
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetails) {
    if (_purchaseHandler != null) {
      for (final details in purchaseDetails) {
        // status is null when it's a past purchase...
        if (details.status == PurchaseStatus.purchased ||
            details.status == null) {

          if (details.skPaymentTransaction != null) {
            // Mark that you've delivered the purchase. Only the App Store requires
            // this final confirmation.
            InAppPurchaseConnection.instance.completePurchase(details);
          }

          _purchaseHandler(details.productID);
        }
      }
    }
  }
}
