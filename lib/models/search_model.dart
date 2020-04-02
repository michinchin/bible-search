import 'dart:io';
import 'package:bible_search/data/verse.dart';
import 'package:bible_search/labels.dart';
import 'package:diacritic/diacritic.dart';

import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:tec_widgets/tec_widgets.dart' as tw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tec_util/tec_util.dart' as tec;

final tecartaBibleLink = Platform.isAndroid
    ? 'https://play.google.com/store/apps/details?id=com.tecarta.TecartaBible'
    : 'itms-apps://itunes.apple.com/app/id325955298';

class SearchModel {
  Future<void> openTB(
      {@required String a,
      @required int id,
      @required int bookId,
      @required int chapterId,
      @required int verseId,
      @required BuildContext context}) async {
    final url = 'tecartabible://$id/$bookId/$chapterId/$verseId';
    final launched = await launchUrl(url);
    if (!launched) {
      //couldn't launch, open app store
      print('Could not launch $url');
      showAppStoreDialog(context);
    }
  }

  Future<bool> launchUrl(String url) async {
    var launched = false;
    try {
      launched = await launch(url, forceSafariVC: false, forceWebView: false);
    } catch (e) {
      print('ERROR with launch(\'$url\'): $e');
    }
    return launched;
  }

  void showAppStoreDialog(BuildContext context) {
    final dialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('Download TecartaBible'),
      content: const Text(
          'Easily navigate to scriptures in the Bible by downloading our Bible app.'),
      actions: [
        FlatButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: const Text('Download'),
          onPressed: () async {
            if (await canLaunch(tecartaBibleLink)) {
              try {
                await launch(tecartaBibleLink);
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
      tw.TecToast.show(context, 'Successfully Copied!');
    });
  }

  Future<bool> shareSelection(
      {@required BuildContext context,
      @required ShareVerse verse,
      bool isCopy = false}) async {
    var shortUrl = '';
    if (!verse.multipleSelected) {
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

      shortUrl = await tec.shortenUrl(url);

      debugPrint('Share URL: $url\nShort: $shortUrl');
    }

    if (verse.selectedText.isNotEmpty) {
      if (!isCopy) {
        try {
          await Share.share(
              '${verse.selectedText}${shortUrl.isNotEmpty ? '\n$shortUrl' : ''}');
          return true;
        } catch (e) {
          print('ERROR sharing verse: $e');
        }
      } else {
        await Clipboard.setData(ClipboardData(text: '${verse.selectedText}'))
            .then((x) {
          tw.TecToast.show(context, 'Successfully Copied!');
        });
        return true;
      }
    } else {
      tw.TecToast.show(context, 'Please make a selection');
    }
    return false;
  }

  List<TextSpan> formatWords(
    String verseText,
    String words,
  ) {
    final verse = removeDiacritics(verseText);

    final content = <TextSpan>[];
    // var modPar = verse;
    var modKeywords = words.trim();
    var phrase = false, exact = false;

    urlEncodingExceptions
        .forEach((k, v) => modKeywords = modKeywords.replaceAll(RegExp(k), v));

    // phrase or exact search ?
    if (modKeywords[0] == '"' || modKeywords[0] == '\'') {
      if (modKeywords.contains(' ')) {
        phrase = true;
      } else {
        exact = true;
      }

      // remove trailing quote
      if (modKeywords.endsWith(modKeywords[0])) {
        modKeywords = modKeywords.substring(1, modKeywords.length - 1);
      } else {
        modKeywords = modKeywords.substring(1);
      }
    } else {
      modKeywords = modKeywords;
    }

    // l = lowercase
    // List<String> formattedKeywords, lFormattedKeywords;
    List<String> lFormattedKeywords;

    if (exact || phrase) {
      // formattedKeywords = [modKeywords.trim()];
      lFormattedKeywords = [modKeywords.trim().toLowerCase()];
    } else {
//      formattedKeywords = modKeywords.split(' ')
//        ..sort((s, t) => s.length.compareTo(t.length));
      lFormattedKeywords = modKeywords.toLowerCase().split(' ');
    }

    final bold = <int, int>{};
    final lverse = verse.toLowerCase();
    final a = 'a'.codeUnitAt(0);
    final z = 'z'.codeUnitAt(0);
    lFormattedKeywords.removeWhere((s) => s.isEmpty);

    // find matching words (case insensitive search)
    for (final keyword in lFormattedKeywords) {
      var where = -1;

      while ((where = lverse.indexOf(keyword, where + 1)) >= 0) {
        if (where == 0 ||
            (lverse.codeUnitAt(where - 1) < a) ||
            lverse.codeUnitAt(where - 1) > z) {
          final length = keyword.length;

          if (length <= 2 && lverse.length > (where + length)) {
            // match only whole words
            if (lverse.codeUnitAt(where + length) >= a &&
                lverse.codeUnitAt(where + length) <= z) {
              continue;
            }
          }

          bold[where] = length;
        }
      }
    }

    if (bold.isEmpty) {
      // no bold - should never happen
      content.add(TextSpan(text: verse));
    } else {
      final boldKeys = bold.keys.toList()..sort((a, b) => a.compareTo(b));

      var lastEnd = 0;

      for (final where in boldKeys) {
        if (where >= lastEnd) {
          if (where > 0) {
            // add any preceding text not bolded...
            content.add(TextSpan(text: verse.substring(lastEnd, where)));
          }

          // add the bold text...
          content.add(TextSpan(
              text: verse.substring(where, where + bold[where]),
              style: const TextStyle(fontWeight: FontWeight.bold)));

          lastEnd = where + bold[where];
        }
      }

      if (lastEnd < verse.length) {
        content.add(TextSpan(text: verse.substring(lastEnd)));
      }
    }

//    for (final keyword in formattedKeywords) {
//      if (keyword.length > 3) {
//        final regex = RegExp(keyword, caseSensitive: false, unicode: true);
//        modPar = modPar.replaceAllMapped(regex, (s) => '\*${s.group(0)}\*');
//      } else {
//        // shorter words (length <= 3 i.e. and, the, I) will be bolded only if
//        // stand alone words (i.e. not bolding l[and] or [the]n)
//        final regex =
//            RegExp('[^a-zA-Z]$keyword[^a-zA-Z]', caseSensitive: false);
//        modPar = modPar.replaceAllMapped(regex, (s) => '\*${s.group(0)}\*');
//        // i.e. if first word in paragraph is One (and this is a keyword) => bold word
//        // this avoids the issue of nested words (not stand alone) for shorter words
//        final keywordAsFirst =
//            RegExp('$keyword[^a-zA-Z]', caseSensitive: false);
//        if (modPar.startsWith(keywordAsFirst)) {
//          final firstWord = modPar.split(' ').first;
//          modPar = modPar.replaceFirst(keywordAsFirst, '\*$firstWord \*');
//        }
//      }
//    }

//    final arr = modPar.split('\*');
//    for (var i = 0; i < arr.length; i++) {
//      var bold = false;
//      final keyword =
//          arr[i].trim().toLowerCase().replaceAll(RegExp('[^a-zA-Z\s]*'), '');
//      if (lFormattedKeywords.contains(keyword)) {
//        bold = true;
//
//        // we may skip this one... if not a whole word match
//        if (exact) {
//          // check last character of previous word...
//          if (i > 0 && isAlpha(arr[i - 1][arr[i - 1].length - 1])) {
//            bold = false;
//          }
//          // check first character of next word...
//          else if (i < arr.length - 1 && isAlpha(arr[i + 1][0])) {
//            bold = false;
//          }
//        }
//      }
//
//      if (bold) {
//        content.add(TextSpan(
//            text: arr[i], style: const TextStyle(fontWeight: FontWeight.bold)));
//      } else {
//        content.add(TextSpan(text: arr[i]));
//      }
//    }

    return content;
  }

  SearchResult orderByDefaultTranslation(SearchResult res) {
    final defaultTranslations = tec.Prefs.shared
        .getString(defaultTranslationsPref, defaultValue: '')
        .split('|')
        .map(int.tryParse)
        .toList();
    final verses = res.verses;
    final ids = verses.map((v) => v.id).toList();
    final orderedVerses = List<Verse>.from(verses);
    for (final dt in defaultTranslations.reversed) {
      if (ids.contains(dt)) {
        final idx = orderedVerses.indexWhere((v) => v.id == dt);
        final verse = orderedVerses.removeAt(idx);
        orderedVerses.insert(0, verse);
      }
    }
    return res.copyWith(verses: orderedVerses);
  }
}

class ShareVerse {
  final List<SearchResult> results;
  final List<Book> books;
  const ShareVerse({this.results, this.books});

  String get selectedText {
    final buffer = StringBuffer();
    for (final each in results) {
      final currVerse = each.verses[each.currentVerseIndex];
      if (each.isSelected && each.contextExpanded) {
        buffer
            .write('${books.firstWhere((book) => book.id == each.bookId).name} '
                '${each.chapterId}:'
                '${each.verses[each.currentVerseIndex].verseIdx[0]}'
                '-${each.verses[each.currentVerseIndex].verseIdx[1]} '
                '${each.verses[each.currentVerseIndex].a}'
                '\n${currVerse.contextText}\n\n');
      } else if (each.isSelected) {
        buffer
            .write('${each.ref} ${currVerse.a}\n${currVerse.verseContent}\n\n');
      }
    }
    return buffer
        .toString()
        .substring(0, buffer.toString().lastIndexOf('\n\n'));
  }

  bool get multipleSelected =>
      results.where((r) => r.isSelected).toList().length > 1;

  int get volumeId {
    return books.firstWhere((b) => b.id == shareVerse.bookId).id;
  }

  SearchResult get shareVerse {
    return results?.firstWhere((r) => r.isSelected,
        orElse: () => results[results.first.currentVerseIndex]);
  }
}
