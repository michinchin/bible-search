import 'package:flutter/material.dart';


class SearchAppBar extends StatefulWidget implements PreferredSizeWidget{
  final String title;

  SearchAppBar({Key key, this.title}) : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }

  @override
  _SearchAppBarState createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 1.0,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.title,
        ),
        centerTitle: true,
        actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info_outline),
          color: Colors.white,
          onPressed: () => {},
          //TODO: onPressed action
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          color: Colors.white,
          onPressed: () => {},
          //TODO: onPressed action
        ),
      ],
      );
  }
}