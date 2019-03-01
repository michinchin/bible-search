import 'package:flutter/material.dart';
import 'Screens/initial_search.dart';
import './Model/votd_image.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import './Model/singleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() { 
  _loadTheme();
  return runApp(BibleSearch());
}
void _loadTheme() async {
  var prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('theme') == null) {
    prefs.setBool('theme', false);
  } 
  isDarkTheme = prefs.getBool('theme');
} 
class BibleSearch extends StatelessWidget {
   
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
        primarySwatch: Colors.orange,
        primaryColorBrightness: Brightness.dark,
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      ),
      themedWidgetBuilder:(context,theme) {
        return MaterialApp(
          title: 'Bible Search',
          theme: theme,
          home: InitialSearchPage(votd: VOTDImage.fetch()),
        );
      });
  }
}