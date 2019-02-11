import 'package:flutter/material.dart';
import '../Model/singleton.dart';
import '../Model/search_result.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget{
  final String title;
  final navigator;
  final TextEditingController searchController;
  final update;
  final changeSelectionMode;


  SearchAppBar({Key key, this.title,this.navigator,this.searchController, this.update, this.changeSelectionMode}) : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }

  @override
  _SearchAppBarState createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {

  
void _settingModalBottomSheet(context){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            child: Wrap(
            children: <Widget>[
            ListTile(
              leading: Icon(Icons.lightbulb_outline),
              title:  Text('Light Mode'),
              onTap: () {theme = Brightness.light;}          
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Dark Mode'),
              onTap: () {theme = Brightness.dark;},          
            ),
            ],
          ),
          );
      }
    );
}

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 1.0,
        title: TextField(
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom:10.0),
              prefixIcon: Icon(Icons.search, color: Colors.white),
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.white),
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
            onPressed: ()=>_settingModalBottomSheet(context),
            //TODO: onPressed action
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            color: Colors.white,
            onPressed: () => widget.navigator(context),
            //TODO: onPressed action
          ),
          IconButton(
            icon: Icon(Icons.check_circle_outline),
            color: Colors.white,
            onPressed: widget.changeSelectionMode,
          )

      ],
      );
  }
}