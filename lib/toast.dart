import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class TecToast {
  static void show(String message) {
    final widget = Container(
      margin: const EdgeInsets.only(
          left: 50.0, right: 50.0, top: 50.0, bottom: 0.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(235, 244, 144, 30),
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: ClipRect(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );

    showToastWidget(widget, position: ToastPosition.bottom);
  }
}