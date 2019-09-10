import 'dart:io';

import 'package:bible_search/data/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchModel {
  Future<void> openTB(
      {@required String a,
      @required int id,
      @required int bookId,
      @required int chapterId,
      @required int verseId,
      @required BuildContext context}) async {
    var url = Platform.isIOS ? 'bible://$a' : 'bible://$id';
    url += '/$bookId/$chapterId/$verseId';

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
      title: const Text('Download TecartaBible'),
      content: const Text(
          'Easily navigate to scriptures in the Bible by downloading our Bible app.'),
      actions: [
        FlatButton(
          child: const Text('No Thanks'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: const Text('Okay'),
          onPressed: () async {
            final url = Platform.isIOS
                ? 'itms-apps://itunes.apple.com/app/id325955298'
                : 'https://play.google.com/store/apps/details?id=com.tecarta.TecartaBible';
            if (await canLaunch(url)) {
              try {
                await launch(url);
              } catch (e) {
                Navigator.of(context).pop();
                print(e);
              }
            }
            Navigator.of(context).pop();
          },
        )
      ],
    );
    showDialog<void>(context: context, builder: (x) => dialog);
  }

  void copyPressed({@required String text, @required BuildContext context}) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: const Text('Successfully Copied!')));
    });
  }

  List<TextSpan> formatWords(String paragraph, String keywords) {
    final contentText = paragraph.split(' ');
    final content = contentText.map((s) => TextSpan(text: s)).toList();
    final contentCopy = <TextSpan>[];
    String modKeywords;
    urlEncodingExceptions
        .forEach((k, v) => modKeywords = keywords.replaceAll(RegExp(k), v));
    final formattedKeywords = modKeywords.toLowerCase().split(' ');

    for (var i = 0; i < content.length; i++) {
      final text = <TextSpan>[];
      final w = content[i].text;
      for (final search in formattedKeywords) {
        if (w.toLowerCase().contains(search)) {
          final start = w.toLowerCase().indexOf(search);
          final end = start + search.length;
          final prefix = w.substring(0, start);
          final suffix = w.substring(end, w.length);
          if (prefix.isNotEmpty) {
            text.add(TextSpan(text: prefix));
          }
          if (prefix.isEmpty && suffix.isEmpty) {
            text.add(TextSpan(
                text: '$w ', style: TextStyle(fontWeight: FontWeight.bold)));
          } else {
            suffix.isNotEmpty
                ? text.add(TextSpan(
                    text: search,
                    style: TextStyle(fontWeight: FontWeight.bold)))
                : text.add(TextSpan(
                    text: '$search ',
                    style: TextStyle(fontWeight: FontWeight.bold)));
          }
          if (suffix.isNotEmpty) {
            text.add(TextSpan(text: '$suffix '));
          }
        }
      }
      (text.isNotEmpty)
          ? text.forEach(contentCopy.add)
          : contentCopy.add(TextSpan(text: '$w '));
    }
    return contentCopy;
  }
}
