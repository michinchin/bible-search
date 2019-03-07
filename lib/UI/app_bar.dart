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
    // return SafeArea(
    //   child: Container(
    //     height: widget.preferredSize.height,
    //     width: widget.preferredSize.width,
    //     padding: EdgeInsets.only(left: 10.0, right: 10.0),
    //         decoration: BoxDecoration(
    //           shape: BoxShape.rectangle,
    //           color: Colors.white,
    //           borderRadius: BorderRadius.circular(10.0),
    //           boxShadow: [
    //             BoxShadow(
    //               color: Colors.black26,
    //               blurRadius: 5.0, // has the effect of softening the shadow
    //               offset: Offset(
    //                 0.0, // right
    //                 2.0, //left
    //               ),
    //             )
    //           ],
    //         ),
    //         child: Stack(children: [
    //           Center(
    //             child: TextField(
    //               onChanged: (s){
    //                 setState(() {
    //                 });
    //               },
    //               textAlign: TextAlign.left,
    //               style: TextStyle(color: Colors.black),
    //               decoration: InputDecoration(
    //                 contentPadding: EdgeInsets.only(left: 40.0, right: 40.0),
    //                 hintText: 'Enter search terms',
    //                 border: InputBorder.none,
    //                 hintStyle: TextStyle(color: Colors.grey),
    //               ),
    //               onSubmitted: (String s) {
    //               },
    //             ),
    //           ),
    //           Align(
    //             alignment: Alignment.centerRight,
    //             child: widget.title.length > 0
    //             ? IconButton(
    //               splashColor: Colors.transparent,
    //               icon: Icon(
    //                 Icons.cached,
    //                 color: Colors.black,
    //               ),
    //               onPressed: () {
    //                 setState(() {
    //                 });
    //               },
    //             ):null,
    //           ),
    //            Align(
    //             alignment: Alignment.centerLeft,
    //             child: IconButton(
    //               splashColor: Colors.transparent,
    //               icon: Icon(
    //                 Icons.search,
    //                 color: Colors.black,
    //               ),
    //               onPressed: () => {},
    //             ),
    //           )
    //         ]),),
    // );
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
