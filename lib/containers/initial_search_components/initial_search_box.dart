import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class InitialSearchBox extends StatefulWidget {
  final Orientation orientation;
  final double height;
  final double imageHeight;
  final Function(String) updateSearch;

  const InitialSearchBox({
    Key key,
    @required this.orientation,
    @required this.height,
    @required this.imageHeight,
    @required this.updateSearch,
  })  : assert(orientation != null),
        assert(height != null),
        assert(imageHeight != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _InitialSearchBoxState();
}

class _InitialSearchBoxState extends State<InitialSearchBox> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: widget.orientation == Orientation.portrait
            ? EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: widget.imageHeight - (widget.height / 2))
            : EdgeInsets.only(
                left: 40.0,
                right: 40.0,
                top: widget.imageHeight - (widget.height / 2)),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(widget.height),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0, // has the effect of softening the shadow
                offset: const Offset(
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
                onChanged: (s) {
                  setState(() {}); //for clear button to show
                },
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.only(left: 40.0, right: 40.0),
                  hintText: 'Enter search terms',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                controller: controller,
                onSubmitted: (s) {
                  widget.updateSearch(s);
                  Navigator.of(context).pushNamed('/results');
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: controller.text.isNotEmpty
                  ? IconButton(
                      splashColor: Colors.transparent,
                      icon: const Icon(
                        CupertinoIcons.clear_circled,
                      ),
                      onPressed: () {
                        setState(() {
                          controller.clear();
                        });
                      },
                    )
                  : null,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                splashColor: Colors.transparent,
                icon: Icon(
                  CupertinoIcons.search,
                ),
                onPressed: () {},
              ),
            )
          ]),
        ));
  }
}
