import 'dart:io';

import 'package:bible_search/data/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchModel {
  
  void openTB({@required String a, @required int id,@required int bookId,@required int chapterId,@required int verseId,@required BuildContext context}) async {
    var url = Platform.isIOS
        ? 'bible://$a' +
            '/$bookId/$chapterId/$verseId'
        //need a check to see if has bible app on android
        : 'bible/$id' +
            '/$bookId/$chapterId/$verseId';

    if (await canLaunch(url)) {
      await launch(url, universalLinksOnly: false);
    } else {
      //couldn't launch, open app store
      print('Could not launch $url');
      showAppStoreDialog(context);
    }
  }

  void showAppStoreDialog(BuildContext context) {

    final dialog = AlertDialog(
      title: Text('Download TecartaBible'),
      content: Text(
          'Easily navigate to scriptures in the Bible by downloading our Bible app.'),
      actions: [
        FlatButton(
          child: Text('No Thanks'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Okay'),
          onPressed: () async {
            var url = Platform.isIOS
                ? 'itms-apps://itunes.apple.com/app/id325955298'
                : 'https://play.google.com/store/apps/details?id=com.tecarta.TecartaBible';
            if (await canLaunch(url)) {
              try {
                await launch(url);
              } catch (e) {
                Navigator.of(context).pop();
                print(e);
              }
            } else {
              Navigator.of(context).pop();
            }
          },
        )
      ],
    );
    showDialog(context: context, builder: (x) => dialog);
  }

  void copyPressed({@required String text,@required BuildContext context}) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Successfully Copied!')));
    });
  }

  List<TextSpan> formatWords(String paragraph, String keywords) {
    final List<String> contentText = paragraph.split(' ');
    List<TextSpan> content = contentText.map((s) => TextSpan(text: s)).toList();
    var contentCopy = <TextSpan>[];
    urlEncodingExceptions
        .forEach((k, v) => keywords = keywords.replaceAll(RegExp(k), v));
    final formattedKeywords = keywords.toLowerCase().split(' ');

    for (var i = 0; i < content.length; i++) {
      var text = <TextSpan>[];
      final w = content[i].text;
      for (final search in formattedKeywords) {
        if (w.toLowerCase().contains(search)) {
          final start = w.toLowerCase().indexOf(search);
          final end = start + search.length;
          final prefix = w.substring(0, start);
          final suffix = w.substring(end, w.length);
          if (prefix.length > 0) {
            text.add(TextSpan(text: prefix));
          }
          if (prefix.length == 0 && suffix.length == 0) {
            text.add(TextSpan(
                text: w + ' ', style: TextStyle(fontWeight: FontWeight.bold)));
          } else {
            suffix.length > 0
                ? text.add(TextSpan(
                    text: search,
                    style: TextStyle(fontWeight: FontWeight.bold)))
                : text.add(TextSpan(
                    text: search + ' ',
                    style: TextStyle(fontWeight: FontWeight.bold)));
          }
          if (suffix.length > 0) {
            text.add(TextSpan(text: suffix + ' '));
          }
        }
      }
      (text.length > 0)
          ? text.forEach((ts) {
              contentCopy.add(ts);
            })
          : contentCopy.add(TextSpan(text: w + ' '));
    }
    return contentCopy;
  }

}
