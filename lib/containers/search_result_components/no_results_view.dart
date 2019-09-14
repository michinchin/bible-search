import 'package:flutter/material.dart';

class NoResultsView extends StatelessWidget {
  final String text;
  const NoResultsView([this.text = 'No Results']);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(text),
        ),
      );
}
