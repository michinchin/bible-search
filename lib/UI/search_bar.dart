import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SearchBar extends StatefulWidget {
  final Orientation orientation;
  final double height;
  final TextEditingController controller;
  final double imageHeight;
  final navigation;

  const SearchBar({
    Key key,
    @required this.orientation,
    @required this.height,
    @required this.controller,
    @required this.imageHeight,
    @required this.navigation,
  })  : assert(orientation != null),
        assert(height != null),
        assert(controller != null),
        assert(imageHeight != null),
        assert(navigation != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: widget.orientation == Orientation.portrait
            ? EdgeInsets.only(
                left: 20.0, right: 20.0, top: widget.imageHeight - (widget.height / 2))
            : EdgeInsets.only(
                left: 40.0, right: 40.0, top: widget.imageHeight - (widget.height / 2)),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.height),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0, // has the effect of softening the shadow
                offset: Offset(
                  0.0, // right
                  2.0, //left
                ),
              )
            ],
          ),
          height: widget.height,
          child: Stack(children: [
            Center(
              child: TextField(
                onChanged: (s){
                  setState(() {
                  });
                },
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 40.0, right: 40.0),
                  hintText: 'Enter search terms',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                controller: widget.controller,
                onSubmitted: (String s) {
                  widget.navigation(context, s);
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: widget.controller.text.length > 0
              ? IconButton(
                splashColor: Colors.transparent,
                icon: Icon(
                  CupertinoIcons.clear_circled,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    widget.controller.clear();
                  });
                },
              ):null,
            ),
             Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                splashColor: Colors.transparent,
                icon: Icon(
                  CupertinoIcons.search,
                  color: Colors.black,
                ),
                onPressed: () => {},
              ),
            )
          ]),
        ));
  }

}