import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import '../Model/votd_image.dart';

class GradientOverlayImage extends StatelessWidget {
  
  final Future<VOTDImage> votd;
  final Color topColor;
  final Color bottomColor;
  final double height;
 
  const GradientOverlayImage({
      Key key,
      @required this.votd,
      @required this.topColor,
      @required this.bottomColor,
      @required this.height,
    })  :
          assert(topColor != null),
          assert(bottomColor != null),
          assert(height != null),
          super(key: key);

  Widget _getImageOnline(String url) {
    return Container(
      height: height,
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        fadeInCurve: Curves.easeIn,
        image: url,
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

  Widget _getImageOffline(String path) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.fill,
        )  
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VOTDImage>(
      future: votd,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return _getImageOnline(snapshot.data.url);
        } else if (snapshot.hasError) {
          return _getImageOffline('assets/appimage.jpg');
        }
        return Container(
          color: Colors.transparent,
          height: height,
          child: Center(
            child: SizedBox(
              child: CircularProgressIndicator(),
              height: 25.0,
              width: 25.0,
            ),
          ),
        );
      });
  }
}
