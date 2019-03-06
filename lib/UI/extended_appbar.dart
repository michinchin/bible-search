import 'package:flutter/material.dart';
import '../Model/info_button_controller.dart';

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Function(BuildContext) navigate;
  ExtendedAppBar({Key key, this.height, this.navigate}) : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final ib = InfoButtonController();
    return AppBar(
      textTheme: TextTheme(),
      elevation: 0.0,
      title: Row(children: [
        Image.asset(
          'assets/logo.png',
          scale: 2.0,
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
            children: <TextSpan>[
              TextSpan(text: ' Tecarta'),
              TextSpan(
                  text: 'Bible', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' Search')
            ],
          ),
        ),
      ]),
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info_outline),
          color: Colors.white,
          onPressed: () => ib.infoButtonPressed(context),
        ),
        IconButton(
            icon: Icon(Icons.filter_list),
            color: Colors.white,
            onPressed: () {
              navigate(context);
            }),
      ],
    );
  }
}
