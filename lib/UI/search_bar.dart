import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {

  final Orientation orientation;
  final double height;
  final TextEditingController controller;
  final double imageHeight;
 

  const SearchBar({
      Key key,
      @required this.orientation,
      @required this.height,
      @required this.controller,
      @required this.imageHeight,
    })  : assert(orientation != null),
          assert(height != null),
          assert(controller != null),
          assert(imageHeight != null),
          super(key: key);

    void _navigateToResults(BuildContext context, String keywords) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            elevation: 1.0,
            title: Text(
              keywords,
              style: Theme.of(context).textTheme.display1,
            ),
            centerTitle: true,
          ),
        );
      },
    ));
  }

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
            decoration: InputDecoration(
                hintText: 'Search term here',
                border: InputBorder.none,
            ),
            controller: controller,
            onSubmitted: (String s){_navigateToResults(context,s);},
            ),
          ),
      ),
    );
  }
}


