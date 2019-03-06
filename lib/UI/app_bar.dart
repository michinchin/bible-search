import 'package:flutter/material.dart';
import '../Model/info_button_controller.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function(BuildContext) navigator;
  final Function(String) update;
  final Function(BuildContext) shareSelection;

  SearchAppBar(
      {Key key,
      this.title,
      this.navigator,
      this.update,
      this.shareSelection})
      : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    final ib = InfoButtonController();
    return AppBar(
      elevation: 1.0,
      title: TextField(
        cursorColor: Colors.white,
        style: TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 10.0),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white),
          labelText: title,
        ),
        onSubmitted: (String s) => update(s),
      ),
      centerTitle: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info_outline),
          color: Colors.white,
          onPressed: () => ib.infoButtonPressed(context),
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          color: Colors.white,
          onPressed: () => navigator(context),
        ),
        IconButton(
          icon: Icon(Icons.share),
          color: Colors.white,
          onPressed: () => shareSelection(context),
        )
      ],
    );
  }
}


  


