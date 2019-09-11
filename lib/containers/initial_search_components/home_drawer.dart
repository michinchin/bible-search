import 'package:bible_search/containers/iap.dart';
import 'package:bible_search/presentation/initial_search_screen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

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
          SwitchListTile(
              secondary: Icon(Icons.lightbulb_outline),
              value: vm.isDarkTheme,
              title: const Text('Light/Dark Mode'),
              onChanged: (b) {
                DynamicTheme.of(context).setThemeData(ThemeData(
                  primarySwatch: b ? Colors.teal : Colors.orange,
                  primaryColorBrightness: Brightness.dark,
                  brightness: b ? Brightness.dark : Brightness.light,
                ));
                vm.changeTheme(b);
              }),
          ListTile(
            leading: Icon(Icons.more),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(context: context);
            },
          ),
          ListTile(
              leading: Icon(Icons.remove_circle),
              title: const Text('Remove Ads'),
              onTap: () => showDialog<void>(
                  context: context, builder: (c) => InAppPurchaseDialog())),
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
        ],
      ),
    );
  }
}
