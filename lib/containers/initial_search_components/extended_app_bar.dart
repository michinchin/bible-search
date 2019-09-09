
import 'package:bible_search/presentation/translation_book_filter_screen.dart';
import 'package:flutter/material.dart';

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  ExtendedAppBar({Key key, @required this.height})
      : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      brightness: Brightness.dark,
      centerTitle: false,
      textTheme: TextTheme(),
      elevation: 0.0,
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
          children: <TextSpan>[
            TextSpan(text: 'Tecarta'),
            TextSpan(
                text: 'Bible', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' Search')
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.menu),
        color: Colors.white,
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.filter_list),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute<dynamic>(
              builder: (BuildContext context) {
                return TranslationBookFilterScreen(tabValue: 1);
              },
              fullscreenDialog: true,
            ));
          },
        ),
      ],
    );
  }
}