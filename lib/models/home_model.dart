import 'package:bible_search/data/translation.dart';
import 'package:bible_search/data/book.dart';
import 'package:bible_search/labels.dart';

import 'package:tec_util/tec_util.dart' as tec;

class HomeModel {
  /// load dark or light theme from user prefs
  Future<bool> loadTheme() async {
    if (tec.Prefs.shared.getBool(themePref) == null) {
      await tec.Prefs.shared.setBool(themePref, false);
    }
    return tec.Prefs.shared.getBool(themePref);
  }

  /// load the search history from user prefs
  Future<List<String>> loadSearchHistory() async {
    var sh = tec.Prefs.shared
        .getStringList(searchHistoryPref, defaultValue: defaultSearchHistory);
    if (sh.length > searchHistoryMaxNum) {
      sh = sh.take(searchHistoryMaxNum).toList();
      await tec.Prefs.shared.setStringList(searchHistoryPref, sh);
    }
    return sh.isEmpty ? defaultSearchHistory : sh;
  }

  /// update the search history with current user prefs
  Future<void> updateSearchHistory(List<String> searchQueries) async {
    final sq = <String>[];

    for (var s in searchQueries.reversed) {
      s = s.trim();
      if (s.isNotEmpty && !sq.contains(s)) {
        sq.add(s);
      }
    }

    await tec.Prefs.shared.setStringList(
        searchHistoryPref, sq.reversed.toList());
  }

  /// update the current theme in user prefs
  Future<void> updateTheme({bool b}) async {
    await tec.Prefs.shared.setBool(themePref, b);
  }

  final languages = <Language>[
    Language(a: 'en', name: 'English', id: 0, isSelected: true),
    Language(a: 'es', name: 'Español', id: 1, isSelected: true),
    Language(a: 'zh', name: 'Chinese', id: 2, isSelected: true),
    Language(a: 'ko', name: 'Korean', id: 3, isSelected: true),
  ];

  final bookNames = <Book>[
    Book(name: 'Genesis', id: 1),
    Book(name: 'Exodus', id: 2),
    Book(name: 'Leviticus', id: 3),
    Book(name: 'Numbers', id: 4),
    Book(name: 'Deuteronomy', id: 5),
    Book(name: 'Joshua', id: 6),
    Book(name: 'Judges', id: 7),
    Book(name: 'Ruth', id: 8),
    Book(name: '1 Samuel', id: 9),
    Book(name: '2 Samuel', id: 10),
    Book(name: '1 Kings', id: 11),
    Book(name: '2 Kings', id: 12),
    Book(name: '1 Chronicles', id: 13),
    Book(name: '2 Chronicles', id: 14),
    Book(name: 'Ezra', id: 15),
    Book(name: 'Nehemiah', id: 16),
    Book(name: 'Esther', id: 19),
    Book(name: 'Job', id: 22),
    Book(name: 'Psalm', id: 23),
    Book(name: 'Proverbs', id: 24),
    Book(name: 'Ecclesiastes', id: 25),
    Book(name: 'Song of Solomon', id: 26),
    Book(name: 'Isaiah', id: 29),
    Book(name: 'Jeremiah', id: 30),
    Book(name: 'Lamentations', id: 31),
    Book(name: 'Ezekiel', id: 33),
    Book(name: 'Daniel', id: 34),
    Book(name: 'Hosea', id: 35),
    Book(name: 'Joel', id: 36),
    Book(name: 'Amos', id: 37),
    Book(name: 'Obadiah', id: 38),
    Book(name: 'Jonah', id: 39),
    Book(name: 'Micah', id: 40),
    Book(name: 'Nahum', id: 41),
    Book(name: 'Habakkuk', id: 42),
    Book(name: 'Zephaniah', id: 43),
    Book(name: 'Haggai', id: 44),
    Book(name: 'Zechariah', id: 45),
    Book(name: 'Malachi', id: 46),
    Book(name: 'Matthew', id: 47),
    Book(name: 'Mark', id: 48),
    Book(name: 'Luke', id: 49),
    Book(name: 'John', id: 50),
    Book(name: 'Acts', id: 51),
    Book(name: 'Romans', id: 52),
    Book(name: '1 Corinthians', id: 53),
    Book(name: '2 Corinthians', id: 54),
    Book(name: 'Galatians', id: 55),
    Book(name: 'Ephesians', id: 56),
    Book(name: 'Philippians', id: 57),
    Book(name: 'Colossians', id: 58),
    Book(name: '1 Thessalonians', id: 59),
    Book(name: '2 Thessalonians', id: 60),
    Book(name: '1 Timothy', id: 61),
    Book(name: '2 Timothy', id: 62),
    Book(name: 'Titus', id: 63),
    Book(name: 'Philemon', id: 64),
    Book(name: 'Hebrews', id: 65),
    Book(name: 'James', id: 66),
    Book(name: '1 Peter', id: 67),
    Book(name: '2 Peter', id: 68),
    Book(name: '1 John', id: 69),
    Book(name: '2 John', id: 70),
    Book(name: '3 John', id: 71),
    Book(name: 'Jude', id: 72),
    Book(name: 'Revelation', id: 73),
  ];
}
