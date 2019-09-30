import 'package:flutter/material.dart';

class NoResultsView extends StatelessWidget {
  final bool hasError;
  final bool hasNoTranslations;

  const NoResultsView({this.hasError = false, this.hasNoTranslations = false});

  @override
  Widget build(BuildContext context) {
    var text = '';
    if (hasError) {
      text = 'No active internet connection.\n' ' Please connect to WiFi :)';
    } else if (hasNoTranslations) {
      text = 'No translations selected. \n'
          'Please select translations to view results';
    } else {
      text = 'No Results';
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Text(text),
      ),
    );
  }
}
