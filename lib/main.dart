import 'package:flutter/material.dart';

import 'Screens/initial_search.dart';
import './Model/votd_image.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

void main() { 
  return runApp(BibleSearch());
}

class BibleSearch extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch: Colors.orange,
        brightness: brightness,
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