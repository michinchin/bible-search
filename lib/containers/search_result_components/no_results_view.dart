import 'package:flutter/material.dart';

class NoResultsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: const Text(
            'No Results',
          ),
        ),
      );
}
