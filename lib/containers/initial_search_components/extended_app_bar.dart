import 'package:bible_search/presentation/translation_book_filter_screen.dart';
import 'package:flutter/material.dart';

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const ExtendedAppBar({Key key, @required this.height}) : super(key: key);

  @override
  Size get preferredSize {
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      brightness: Brightness.dark,
      centerTitle: false,
      textTheme: const TextTheme(),
      elevation: 0.0,
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
          children: <TextSpan>[
            const TextSpan(text: 'Tecarta'),
            TextSpan(
                text: 'Bible', style: TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: ' Search')
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
            Navigator.of(context)
                .push<MaterialPageRoute<dynamic>>(MaterialPageRoute(
              builder: (context) => TranslationBookFilterScreen(tabValue: 1),
              fullscreenDialog: true,
            ));
          },
        ),
      ],
    );
  }
}
