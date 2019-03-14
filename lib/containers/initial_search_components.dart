import 'package:bible_search/presentation/translation_book_filter.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
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
                onChanged: (s) {
                  setState(() {});
                },
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 40.0, right: 40.0),
                  hintText: 'Enter search terms',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                controller: controller,
                onSubmitted: (String s) {
                  widget.updateSearch(s);
                  // Navigator.of(context).push(MaterialPageRoute<dynamic>(
                  //   builder: (BuildContext context) {
                  //     return ResultsPage();
                  //   },
                  // ));
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: controller.text.length > 0
                  ? IconButton(
                      splashColor: Colors.transparent,
                      icon: Icon(
                        CupertinoIcons.clear_circled,
                        color: Colors.black,
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
                  color: Colors.black,
                ),
                onPressed: () => {},
              ),
            )
          ]),
        ));
  }
}

class GradientOverlayImage extends StatelessWidget {
  final bool fromOnline;
  final String path;
  final Color topColor;
  final Color bottomColor;
  final double height;
  final double width;

  const GradientOverlayImage({
    Key key,
    @required this.fromOnline,
    @required this.path,
    @required this.topColor,
    @required this.bottomColor,
    @required this.height,
    @required this.width,
  })  : assert(fromOnline != null),
        assert(path != null),
        assert(topColor != null),
        assert(bottomColor != null),
        assert(height != null),
        assert(width != null),
        super(key: key);

  Widget _getImageOnline() {
    return Container(
      height: height,
      width: width,
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        fadeInCurve: Curves.easeIn,
        image: path,
        fit: BoxFit.fill,
      ),
      foregroundDecoration: BoxDecoration(
          gradient: new LinearGradient(
        colors: [topColor, bottomColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5],
        tileMode: TileMode.clamp,
      )),
    );
  }

  Widget _getImageOffline() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(path),
        fit: BoxFit.fill,
      )),
      foregroundDecoration: BoxDecoration(
          gradient: new LinearGradient(
        colors: [topColor, bottomColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5],
        tileMode: TileMode.clamp,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return fromOnline ? _getImageOnline() : _getImageOffline();
  }
}

class ExtendedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  ExtendedAppBar({Key key, @required this.height})
      : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      textTheme: TextTheme(),
      elevation: 0.0,
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
          children: <TextSpan>[
            TextSpan(text: 'Tecarta'),
            TextSpan(
                text: 'Bible', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' Search')
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.filter_list),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute<dynamic>(
              builder: (BuildContext context) {
                return TranslationBookFilterPage(tabValue: 1);
              },
              fullscreenDialog: true,
            ));
          },
        ),
      ],
    );
  }
}
