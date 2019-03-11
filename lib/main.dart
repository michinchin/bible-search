import 'package:flutter/material.dart';
import 'Screens/initial_search.dart';
import 'Model/votd_image.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:scoped_model/scoped_model.dart';
import 'Model/search_model.dart';

void main() { 
  var model = SearchModel();
  model.initHomePage();
  model.loadTranslations();
  return runApp(ScopedModel<SearchModel>(
    model: model,
    child: BibleSearch()));
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
        brightness: SearchModel.of(context).isDarkTheme ? Brightness.dark : Brightness.light,
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