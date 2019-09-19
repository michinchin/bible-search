import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(20.0),
      child: Stack(children: [
        ListView.builder(
          itemCount: 15,
          itemBuilder: ( context,  index) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Placeholder(
                color: Theme.of(context).accentColor.withAlpha(100),
                fallbackWidth: MediaQuery.of(context).size.width - 30,
                fallbackHeight: MediaQuery.of(context).size.height / 5,
              ),
            );
          },
        ),
        const Center(
          child: CircularProgressIndicator(),
        )
      ]));
}