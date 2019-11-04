
import 'package:bible_search/models/user_model.dart';
import 'package:flutter/material.dart';


import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_user_account/tec_user_account_ui.dart';

class InAppPurchaseDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
          'This is an ad supported app. Would you like to pay a small fee to remove ads for a year?'),
      actions: <Widget>[
        FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No')),
        FlatButton(
            onPressed: () => UserModel.buyProduct(context),
            child: const Text('Yes')),
      ],
    );
  }
}

class SignInForPurchasesDialog extends StatelessWidget {
  final UserAccount ua;
  const SignInForPurchasesDialog(this.ua);
  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Sign in to save purchases'),
        content: const Text(
            'Sync purchases across devices by signing in or signing up for a TecartaBible account.'),
        actions: <Widget>[
          FlatButton(
            child: const Text('No thanks'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: const Text('Okay'),
            onPressed: () async {
              await showSignInDlg(context: context, account: ua);
              Navigator.of(context).pop();
            },
          )
        ],
      );
}
