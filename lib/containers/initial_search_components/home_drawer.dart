import 'dart:io';

import 'package:bible_search/containers/iap_dialog.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/models/search_model.dart';
import 'package:bible_search/models/user_model.dart';
import 'package:bible_search/redux/actions.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:feature_discovery/feature_discovery.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:redux/redux.dart';
import 'package:bible_search/version.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_user_account/tec_user_account_ui.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart' as tw;
import 'package:url_launcher/url_launcher.dart' as launcher;

class HomeDrawer extends StatelessWidget {
  final bool isResultPage;
  const HomeDrawer({this.isResultPage = false});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DrawerViewModel>(
        distinct: true,
        converter: (store) => DrawerViewModel(store),
        builder: (context, vm) {
          return Drawer(
            child: IconTheme(
              data: Theme.of(context).iconTheme.copyWith(size: 20),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, top: 16),
                    title: RichText(
                      text: TextSpan(
                          children: const [
                            TextSpan(text: 'Tecarta'),
                            TextSpan(text: 'Bible', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' Search')
                          ],
                          style: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).textTheme.headline5
                              : Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(color: Colors.black54)),
                    ),
                  ),
                  const Divider(),
                  if (isResultPage) ...[
                    ListTile(
                      leading: const Icon(FeatherIcons.clock),
                      title: const Text('History'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Future.delayed(
                            const Duration(milliseconds: 250), () => Navigator.of(context).pop());
                      },
                    ),
                    // IconData(0xe0c6, fontFamily: 'MaterialIcons')
                  ],
                  // if (!tec.Prefs.shared
                  //     .getBool(removedAdsPref, defaultValue: false))
                  FutureBuilder<bool>(
                      future: vm.hasPurchased,
                      builder: (c, snapshot) {
                        if (snapshot.hasData) {
                          if (!snapshot.data) {
                            return ListTile(
                                leading: const Icon(FeatherIcons.xCircle),
                                title: const Text('Remove Ads'),
                                onTap: () => vm.removeAds(context));
                          }
                          return Container();
                        }
                        return Container();
                      }),

                  ListTile(
                    leading: Icon(Platform.isIOS ? SFSymbols.square_arrow_up : OMIcons.share),
                    title: const Text('Share App'),
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await vm.shareApp(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(FeatherIcons.heart),
                    title: const Text('Translations'),
                    onTap: () => Navigator.of(context).pushNamed('/default_translation'),
                  ),
                  SwitchListTile.adaptive(
                      secondary: const Icon(FeatherIcons.moon),
                      activeColor: Theme.of(context).accentColor,
                      value: vm.isDarkTheme,
                      title: const Text('Dark Mode'),
                      onChanged: (b) {
                        DynamicTheme.of(context).setThemeData(ThemeData(
                          primarySwatch: b ? Colors.teal : Colors.orange,
                          primaryColorBrightness: Brightness.dark,
                          brightness: b ? Brightness.dark : Brightness.light,
                        ));
                        vm.changeTheme(b);
                      }),
                  const Divider(),
                  ListTile(
                      leading: const Icon(FeatherIcons.user),
                      title: Text(
                          vm.userAccount.isSignedIn ? '${vm.userAccount.user.email}' : 'Account'),
                      onTap: () {
                        Navigator.of(context).pop();
                        showSignInDlg(
                            context: context, account: vm.userAccount, appName: 'bible_search');
                      }),
                  ListTile(
                    leading: const Icon(FeatherIcons.helpCircle),
                    title: const Text('Help & Feedback'),
                    onTap: () {
                      vm.helpAndFeedback(context);
                    },
                  ),
                  ListTile(
                      leading: const Icon(FeatherIcons.info),
                      title: const Text('About'),
                      onTap: () {
                        tw.tecShowSimpleAlertDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          useRootNavigator: false,
                          title: 'About',
                          content:
                              'Bible Search! is a product developed by Tecarta.\n\nLooking for a full featured Bible app? Download Tecarta Bible to access thousands of study notes, maps, charts, book introductions and more!\n\nVersion: $appVersion',
                          actions: <Widget>[
                            tw.TecDialogButton(
                              child: const tw.TecText('Not Now'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            tw.TecDialogButton(
                              child: const tw.TecText('Tecarta Bible'),
                              onPressed: () {
                                Navigator.pop(context);
                                launcher.launch(tecartaBibleLink);
                              },
                            ),
                          ],
                        );
                      }),
                ],
              ),
            ),
          );
        });
  }
}

class DrawerViewModel {
  final Store<AppState> store;
  // VOTDImage votdImage;
  UserAccount userAccount;
  bool isDarkTheme;
  Future<bool> hasPurchased;
  Future<void> Function(BuildContext) shareApp;
  void Function(BuildContext) removeAds;
  void Function(bool isDarkTheme) changeTheme;
  void Function(BuildContext) helpAndFeedback;

  DrawerViewModel(this.store) {
    userAccount = store.state.userAccount;
    isDarkTheme = store.state.isDarkTheme;
    changeTheme = _changeTheme;
    helpAndFeedback = _helpAndFeedback;
    shareApp = _shareApp;
    removeAds = _removeAds;
    hasPurchased = _hasPurchased();
  }

  void _helpAndFeedback(BuildContext context) {
    var _close = false;
    final accessibilityOff = !MediaQuery.of(context).accessibleNavigation;
    tw.tecShowSimpleAlertDialog<void>(
      context: context,
      title: 'Help & Feedback',
      content:
          'Would you like to ${accessibilityOff ? 're-enable Feature Discovery hints or ' : ''}'
          'send an email to our support team?',
      actions: <Widget>[
        if (accessibilityOff)
          tw.TecDialogButton(
            child: const Text('Feature Discovery'),
            onPressed: () {
              _featureDiscovery(context);
              _close = true;
            },
          ),
        tw.TecDialogButton(
          child: const Text('Email'),
          onPressed: () {
            _emailFeedback(context);
            _close = true;
          },
        ),
      ],
    ).then((_) {
      if (_close) {
        Navigator.of(context).pop();
      }
    });
  }

  void _removeAds(BuildContext context) {
    final ua = store.state.userAccount;
    if (ua.user.userId == 0) {
      showSignInForPurchases(context, ua).then((_) {
        Navigator.of(context).pop();
        UserModel.buyProduct();
      });
    } else {
      Navigator.of(context).pop();
      UserModel.buyProduct();
    }
  }

  Future<bool> _hasPurchased() {
    return userAccount.userDb.hasLicenseToFullVolume(removeAdsVolumeId);
  }

  Future<void> _featureDiscovery(BuildContext c) async {
    await tec.Prefs.shared.setBool(firstTimeOpenedPref, true);
    if (tec.Prefs.shared.getBool(firstTimeOpenedPref, defaultValue: true) &&
        !MediaQuery.of(c).accessibleNavigation) {
      WidgetsBinding.instance.addPostFrameCallback((duration) => FeatureDiscovery.discoverFeatures(
            c,
            featureIds.toSet(),
          ));
      await tec.Prefs.shared.setBool(firstTimeOpenedPref, false);
      showToastAndPop(c, 'Success! Reset Feature Discovery');
    }
  }

  void _changeTheme(bool isDarkTheme) => store.dispatch(SetThemeAction(isDarkTheme: isDarkTheme));

  /// Opens the native email UI with an email for questions or comments.
  Future<void> _emailFeedback(BuildContext context) async {
    var email = 'biblesupport@tecarta.com';
    if (!Platform.isIOS) {
      email = 'androidsupport@tecarta.com';
    }
    final di = await tec.DeviceInfo.fetch();
    print('Running on ${di.productName} with ${di.model} ${di.version}');
    const version = (appVersion == 'DEBUG-VERSION' ? '(debug version)' : 'v$appVersion');
    final subject = 'Feedback regarding Bible Search! $version '
        'with ${di.productName} ${di.model} ${di.version}';
    const body = 'I have the following question or comment:\n\n\n';

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
    await Navigator.of(context).maybePop();
  }

  Future<void> _shareApp(BuildContext context) async {
    await Share.share('https://biblesearch.tecartabible.com/link/app');
  }
}
