import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/singleton.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final navigator;
  final update;
  final shareSelection;

  SearchAppBar(
      {Key key,
      this.title,
      this.navigator,
      this.update,
      this.shareSelection})
      : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }
  var sc = TextEditingController();

  void _updateTheme(bool b) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('theme', isDarkTheme);
  }

  void _settingModalBottomSheet(context) {
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

  @override
  Widget build(BuildContext context) {
    
    return AppBar(
      elevation: 1.0,
      title: TextField(
        cursorColor: Colors.white,
        style: TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 10.0),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white),
          labelText: title,
        ),
        onSubmitted: (String s) => update(s),
      ),
      centerTitle: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info_outline),
          color: Colors.white,
          onPressed: () => _settingModalBottomSheet(context),
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          color: Colors.white,
          onPressed: () => navigator(context),
        ),
        IconButton(
          icon: Icon(Icons.share),
          color: Colors.white,
          onPressed: () => shareSelection(context),
        )
      ],
    );
  }
}


  


