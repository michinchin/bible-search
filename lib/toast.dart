import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class TecToast {
  static void show(BuildContext context, String message) {
    final widget = Container(
      margin: const EdgeInsets.only(
          left: 50.0, right: 50.0, top: 50.0, bottom: 0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: ClipRect(
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).cardColor),
          textAlign: TextAlign.center,
        ),
      ),
    );

    showToastWidget(widget, position: ToastPosition.bottom);
  }
}
