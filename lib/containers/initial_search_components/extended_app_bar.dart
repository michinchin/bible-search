import 'package:bible_search/presentation/translation_book_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

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
        text: const TextSpan(
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
        tooltip: 'Menu',
        icon: const Icon(Icons.menu),
        color: Colors.white,
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      actions: <Widget>[
        IconButton(
          tooltip: 'Filter',
          icon: const Icon(SFSymbols.line_horizontal_3_decrease_circle),
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
