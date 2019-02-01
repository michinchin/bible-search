import 'package:flutter/material.dart';

import 'Screens/initial_search.dart';
import './Model/votd_image.dart';

void main() => runApp(BibleSearch());

class BibleSearch extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible Search',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
      ),
      home: InitialSearchPage(votd: VOTDImage.fetch()),
    );
  }
}