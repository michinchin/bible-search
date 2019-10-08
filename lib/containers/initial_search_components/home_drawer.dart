import 'package:bible_search/containers/iap_dialog.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/presentation/initial_search_screen.dart';
import 'package:bible_search/version.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tec_util/tec_util.dart' as tec;

class HomeDrawer extends StatelessWidget {
  final bool isResultPage;
  const HomeDrawer({this.isResultPage = false});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, InitialSearchViewModel>(
        distinct: true,
        converter: (store) => InitialSearchViewModel(store),
        builder: (context, vm) {
          return Drawer(
            child: ListView(
              children: <Widget>[
                const DrawerHeader(
                  child: Text('Settings'),
                ),
                isResultPage
                    ? ListTile(
                        leading: Icon(Icons.history),
                        title: const Text('Search History'),
                        onTap: () {
                          while (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                      )
                    : Container(),
                !tec.Prefs.shared.getBool(removedAdsPref, defaultValue: false)
                    ? ListTile(
                        leading: Icon(Icons.money_off),
                        title: const Text('Remove Ads'),
                        onTap: () => showDialog<void>(
                            context: context,
                            builder: (c) => InAppPurchaseDialog()))
                    : Container(),
                ListTile(
                  leading: Icon(Icons.mobile_screen_share),
                  title: const Text('Share App'),
                  onTap: () async {
                    await Navigator.of(context).maybePop();
                    await vm.shareApp(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.help_outline),
                  title: const Text('Help & Feedback'),
                  onTap: () async {
                    await Navigator.of(context).maybePop();
                    await vm.emailFeedback(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version: $appVersion'),
                ),
                SwitchListTile.adaptive(
                    secondary: Icon(Icons.lightbulb_outline),
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
              ],
            ),
          );
        });
  }
}
