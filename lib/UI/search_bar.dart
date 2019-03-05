import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SearchBar extends StatelessWidget {

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
  Widget build(BuildContext context) {
    return Padding(
      padding: orientation == Orientation.portrait ?
        EdgeInsets.only(left: 20.0,right: 20.0, top: imageHeight-(height/2)):
        EdgeInsets.only(left: 40.0,right: 40.0, top: imageHeight-(height/2)),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(height),
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
          height: height,
          child: Center(
            child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(color:Colors.black),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20.0, right: 20.0),
                  hintText: 'Search term here',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                  suffix: Padding(
                    padding:EdgeInsets.only(left: 5.0),
                    child: IconButton(
                      icon: Icon(CupertinoIcons.clear_circled, color: Colors.orange,),
                      onPressed: ()=>controller.clear(),
                    )
                    )
                ),
                controller: controller,
                onSubmitted: (String s){navigation(context,s);},
              ),
          ),
      ),
    );
  }
}


