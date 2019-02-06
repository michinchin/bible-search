import 'package:flutter/material.dart';
import '../Model/singleton.dart';
import '../Model/search_result.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget{
  final String title;
  final navigator;
  final TextEditingController searchController;
  final update;

  SearchAppBar({Key key, this.title,this.navigator,this.searchController, this.update}) : super(key: key);

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
        title: TextField(
          style: new TextStyle(
            color: Colors.white,
          ),
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search, color: Colors.white),
              hintText: "Search...",
              hintStyle: new TextStyle(color: Colors.white),
              labelText: widget.searchController.text,
          ),
          controller: widget.searchController,
          onSubmitted: (String s) => widget.update(s),
          
        ),
        centerTitle: false,
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
          onPressed: () => widget.navigator(context),
          //TODO: onPressed action
        ),
      ],
      );
  }
}