import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class KeywordText extends StatelessWidget {
  final String outer;
  final String inner;
  final BuildContext c;
  const KeywordText({this.outer, this.inner, this.c});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(c).brightness == Brightness.dark;
    final arr = outer.split(inner);
    final spans = <TextSpan>[];
    for (final each in arr) {
      spans
        ..add(TextSpan(
            text: each,
            style: TextStyle(
                color: isDarkTheme ? Colors.grey[200] : Colors.black)))
        ..add(TextSpan(
          text: inner,
          style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ));
    }
    spans.removeLast();
    return AutoSizeText.rich(
      TextSpan(
        children: spans,
      ),
    );
  }
}
