import 'dart:io';

import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tec_util/tec_util.dart' as tec;

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
      _showToast(context, 'Successfully Copied!');
    });
  }

  Future<void> shareSelection(
      {@required BuildContext context,
      @required ShareVerse verse,
      bool isCopy = false}) async {
    final res = verse.shareVerse;
    final currVerseIdx = res.currentVerseIndex;
    final v = res.verses[currVerseIdx];

    final params = <String, dynamic>{
      'volume': '${v.id}',
      'resid':
          '${verse.books.firstWhere((b) => b.id == res.bookId).name}+${res.chapterId}:${res.verseId}',
    };

    final url = Uri(
            scheme: 'https',
            host: 'tecartabible.com',
            path: '/share',
            queryParameters: params)
        .toString();

    final shortUrl = await tec.shortenUrl(url);

    debugPrint('Share URL: $url\nShort: $shortUrl');

    if (verse.selectedText.isNotEmpty) {
      if (!isCopy) {
        try {
          await Share.share('${verse.selectedText}$shortUrl');
        } catch (e) {
          print('ERROR sharing verse: $e');
        }
      } else {
        await Clipboard.setData(
                ClipboardData(text: '${verse.selectedText}$shortUrl'))
            .then((x) {
          _showToast(context, 'Successfully Copied!');
        });
      }
    } else {
      _showToast(context, 'Please make a selection');
    }
  }

  void _showToast(BuildContext context, String label) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).cardColor,
        content: Text(label, style: Theme.of(context).textTheme.body1),
        action: SnackBarAction(
            label: 'CLOSE',
            textColor: Theme.of(context).accentColor,
            onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  List<TextSpan> formatWords(String paragraph, String keywords) {
    final content = <TextSpan>[];
    var modPar = paragraph;
    String modKeywords;

    urlEncodingExceptions
        .forEach((k, v) => modKeywords = keywords.replaceAll(RegExp(k), v));
    final formattedKeywords = modKeywords.split(' ');
    final lFormattedKeywords = modKeywords.toLowerCase().split(' ');
    for (final keyword in formattedKeywords) {
      final regex = RegExp(keyword, caseSensitive: false);
      modPar = modPar.replaceAll(regex, '\*$keyword\*');
    }

    final arr = modPar.split('\*');
    for (var i = 0; i < arr.length; i++) {
      if (lFormattedKeywords.contains(arr[i].toLowerCase())) {
        content.add(TextSpan(
            text: arr[i], style: TextStyle(fontWeight: FontWeight.bold)));
      } else {
        content.add(TextSpan(text: arr[i]));
      }
    }
    return content;
  }
}

class ShareVerse {
  final List<SearchResult> results;
  final List<Book> books;

  const ShareVerse({this.results, this.books});

  String get selectedText {
    var text = '';
    for (final each in results) {
      final currVerse = each.verses[each.currentVerseIndex];
      if (each.isSelected && each.contextExpanded) {
        text += '${books.firstWhere((book) => book.id == each.bookId).name} '
            '${each.chapterId}:'
            '${each.verses[each.currentVerseIndex].verseIdx[0]}'
            '-${each.verses[each.currentVerseIndex].verseIdx[1]} '
            '(${each.verses[each.currentVerseIndex].a})'
            '\n${currVerse.contextText}\n\n';
      } else if (each.isSelected) {
        text += '${each.ref} (${currVerse.a})\n${currVerse.verseContent}\n\n';
      } else {
        text += '';
      }
    }
    return text;
  }

  int get volumeId => books.firstWhere((b) => b.id == shareVerse.bookId).id;

  SearchResult get shareVerse =>
      results?.firstWhere((r) => r.isSelected) ??
      results[results.first.currentVerseIndex];
}
