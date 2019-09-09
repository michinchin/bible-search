import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(children: [
        ListView.builder(
          itemCount: 15,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.all(10.0),
              child: Placeholder(
                color: Theme.of(context).accentColor.withAlpha(100),
                fallbackWidth: MediaQuery.of(context).size.width - 30,
                fallbackHeight: MediaQuery.of(context).size.height / 5,
              ),
            );
          },
        ),
        Center(
          child: CircularProgressIndicator(),
        )
      ]));
}
