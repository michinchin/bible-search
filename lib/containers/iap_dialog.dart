import 'package:flutter/material.dart';

import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_user_account/tec_user_account_ui.dart';
import 'package:tec_widgets/tec_widgets.dart';

Future<void> showSignInForPurchases(BuildContext context, UserAccount ua) {
  return tecShowSimpleAlertDialog(
    context: context,
    title: 'Sign in to save purchases',
    content: 'Sync purchases across devices by signing in or signing up for a TecartaBible account.',
    actions: <Widget>[
      TecDialogButton(
        child: const Text('No thanks'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TecDialogButton(
        child: const Text('Sign in'),
        onPressed: () async {
          await showSignInDlg(context: context, account: ua, appName: 'bible_search');
          Navigator.of(context).pop();
        },
      )
    ],
  );
}
