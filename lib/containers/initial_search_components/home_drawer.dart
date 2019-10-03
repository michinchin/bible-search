import 'package:bible_search/containers/iap_dialog.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/presentation/initial_search_screen.dart';
import 'package:bible_search/version.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;

class HomeDrawer extends StatelessWidget {
  final InitialSearchViewModel vm;

  const HomeDrawer(this.vm);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            child: Text('Settings'),
          ),
          SwitchListTile.adaptive(
              secondary: Icon(Icons.lightbulb_outline),
              value: vm.isDarkTheme,
              title: Text(vm.isDarkTheme ? 'Dark Mode' : 'Light Mode'),
              onChanged: (b) {
                DynamicTheme.of(context).setThemeData(ThemeData(
                  primarySwatch: b ? Colors.teal : Colors.orange,
                  primaryColorBrightness: Brightness.dark,
                  brightness: b ? Brightness.dark : Brightness.light,
                ));
                vm.changeTheme(b);
              }),
          !tec.Prefs.shared.getBool(removedAdsPref, defaultValue: false)
              ? ListTile(
                  leading: Icon(Icons.remove_circle),
                  title: const Text('Remove Ads'),
                  onTap: () => showDialog<void>(
                      context: context, builder: (c) => InAppPurchaseDialog()))
              : Container(),
          ListTile(
            leading: Icon(Icons.clear_all),
            title: const Text('Clear Search History'),
            onTap: () {
              showDialog<void>(
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      title: const Text('Are you sure?'),
                      actions: <Widget>[
                        FlatButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            vm.updateSearchHistory([]);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                  context: context);
            },
          ),
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
        ],
      ),
    );
  }
}
