import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';

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