import 'dart:io';
import 'package:bible_search/labels.dart';
import 'package:flutter/material.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'iap.dart';

class UserModel {
  static Future<void> buyProduct(BuildContext context) async {
    InAppPurchases.purchase(removeAdsId, consumable: Platform.isAndroid);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  static void purchaseHandler(String inAppId, UserAccount ua) {
    if (inAppId == removeAdsId) {
      addLicense(ua);
    }
  }

  static Future<bool> hasPurchase(UserAccount ua) async {
    final hasLicense =
        await ua.userDb.hasLicenseToFullVolume(removeAdsVolumeId);
    return hasLicense;
  }

  static Future<void> addLicense(UserAccount ua) async {
    await ua.userDb.addLicenseForFullVolume(removeAdsVolumeId,
        expires: DateTime.now().add(const Duration(days: 365)));
    await tec.Prefs.shared.setBool(removedAdsPref, true);
  }
}
