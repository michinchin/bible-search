import 'package:flutter/material.dart';

class NoResultsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'No Results',
          ),
        ),
      );
}
