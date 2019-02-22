import 'package:flutter/material.dart';

import 'Screens/initial_search.dart';
import './Model/votd_image.dart';
import './Model/singleton.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async{ 
  final prefs = await SharedPreferences.getInstance();
  darkTheme = prefs.getBool('darkTheme') ?? await prefs.setBool('darkTheme', true);
  return runApp(BibleSearch());
}

class BibleSearch extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bible Search',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: darkTheme ? Brightness.dark : Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: InitialSearchPage(votd: VOTDImage.fetch()),
    );
  }
}