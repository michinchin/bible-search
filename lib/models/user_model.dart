import 'dart:io';
import 'package:bible_search/labels.dart';
import 'package:bible_search/main.dart';
import 'package:flutter/material.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'iap.dart';

class UserModel {
  Future<void> buyProduct(BuildContext context, UserAccount ua) async {
    InAppPurchases.purchase(removeAdsId, consumable: Platform.isAndroid);
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
  }

  void purchaseHandler(String inAppId) {
    if (inAppId == removeAdsId) {
      addLicense(UserAccount(kvStore: KVStore()));
      // tec.Prefs.shared.setBool(removedAdsPref, true);
      // tec.Prefs.shared.setString(removedAdsExpirePref,
      //     DateTime.now().add(const Duration(days: 365)).toString());
    }
  }

  Future<bool> checkPurchaseAndSync(UserAccount ua) async {
    await ua.userDb.openForUser(ua.user.userId);
    await ua.syncUserDb<void>(
        itemTypes: [UserItemType.license],
        completion: (ua, i) {
          print('Completed sync from db: $i');
          return;
        });
    final hasLicense =
        await ua.userDb.hasLicenseToFullVolume(removeAdsVolumeId);
    ua.userDb.close();
    return hasLicense;
  }

  Future<void> addLicense(UserAccount ua) async {
    await ua.userDb.openForUser(ua.user.userId);
    await ua.userDb.addLicenseForFullVolume(removeAdsVolumeId,
        expires: DateTime.now().add(const Duration(days: 365)));
    await ua.syncUserDb<void>(
        itemTypes: [UserItemType.license],
        completion: (ua, i) {
          print('Completed sync to db: $i');
          return;
        });
    ua.userDb.close();
  }
}
