import 'package:flutter/material.dart';

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Function(BuildContext) navigate;
  ExtendedAppBar({Key key, this.height, this.navigate}) : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      textTheme: TextTheme(),
      elevation: 0.0,
      title: 
        RichText(
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
      actions: <Widget>[
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
