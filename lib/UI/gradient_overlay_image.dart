import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class GradientOverlayImage extends StatelessWidget {
  
  final String imageURL;
  final Color topColor;
  final Color bottomColor;
  final double height;
 
  const GradientOverlayImage({
      Key key,
      @required this.imageURL,
      @required this.topColor,
      @required this.bottomColor,
      @required this.height,
    })  :
          assert(topColor != null),
          assert(bottomColor != null),
          assert(height != null),
          super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   height: height,
    //   decoration: BoxDecoration(
    //     image: DecorationImage(
    //       image: imageURL == null ? kTransparentImage : NetworkImage(imageURL),
    //       fit: BoxFit.fill
    //    ),
    //   ),
    //   foregroundDecoration: BoxDecoration(
    //     gradient: new LinearGradient(
    //       colors: [topColor, bottomColor],
    //       begin: Alignment.topCenter,
    //       end: Alignment.bottomCenter,
    //       stops: [0.0, 0.5],
    //       tileMode: TileMode.clamp,
    //     )
    //   ),
    // );
    return Container(
      height: height,
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        fadeInCurve: Curves.easeIn,
        image: imageURL,
        fit: BoxFit.fill,
      ),

      foregroundDecoration: BoxDecoration(
      gradient: new LinearGradient(
        colors: [topColor, bottomColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5],
        tileMode: TileMode.clamp,
      )
    ),
    );
  }
}