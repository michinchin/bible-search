import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'singleton.dart';

class InfoButtonController {

  void infoButtonPressed(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                SwitchListTile(
                    secondary: Icon(Icons.lightbulb_outline),
                    value: isDarkTheme,
                    title: Text('Light/Dark Mode'),
                    onChanged: (b) {
                      _changeTheme(b, context);
                    }),
              ],
            ),
          );
        });
  }
  
  void _changeTheme(bool b, BuildContext context) {
      DynamicTheme.of(context).setThemeData(
        ThemeData(
          primarySwatch: Colors.orange,
          primaryColorBrightness: Brightness.dark,
          brightness: b ? Brightness.dark : Brightness.light,
        )
      );
      isDarkTheme = b;
      _updateTheme(b);
    }


  void _updateTheme(bool b) async {
      var prefs = await SharedPreferences.getInstance();
      prefs.setBool('theme', isDarkTheme);
    }
}