import 'package:flutter/material.dart';
import '../Model/info_button_controller.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function(BuildContext) navigator;
  final Function(String) update;
  final Function(BuildContext) shareSelection;

  SearchAppBar(
      {Key key, this.title, this.navigator, this.update, this.shareSelection})
      : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  String _title;

  @override
  initState(){
    super.initState();
    _title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(left:20.0,right:20.0),
      child: Container(
        height: widget.preferredSize.height,
        width: widget.preferredSize.width,
       
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  offset: Offset(0, 5.0),
                  blurRadius: 5.0,
                ),
              ]),
          child: Center(
            child: TextField(
              onChanged: (s){
                setState(() {
                  _title = s;
                });
              },
              onSubmitted: (s) {
                widget.update(s);
              },
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                border: InputBorder.none,
                hintText: _title,
                suffixIcon: Stack(alignment: Alignment.centerRight, children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 40.0),
                    child: IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () {
                        widget.navigator(context);
                      },
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsetsDirectional.only(end: 0.0),
                      child: IconButton(
                        icon: Icon(Icons.more_horiz),
                        onPressed: () {},
                      )),
                ]),
              ),
            ),
      ))
    );
  }
}
