import 'package:bible_search/Model/search_result.dart';
import 'package:bible_search/Screens/translation_book_filter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/translation.dart';
import 'package:flutter/material.dart';
import '../Screens/results_page.dart';
import '../Model/book.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class SearchModel extends Model {
  bool isDarkTheme = false;
  bool isLoading = false;
  bool isInSelectionMode = false;
  List<String> searchQueries;
  String searchQuery;
  BibleTranslations translations;
  bool otSelected = true;
  bool ntSelected = true;
  String translationIds;
  List<SearchResult> searchResults;

  static SearchModel of(BuildContext context) =>
      ScopedModel.of<SearchModel>(context);

  // static ScopedModelDescendant<SearchModel> descendant(Widget child) {
  //   return ScopedModelDescendant<SearchModel>(
  //       builder: (BuildContext context, Widget child, SearchModel model) {
  //     return child;
  //   });
  // }

  /// On app start, load current theme, search history, translations from user prefs
  void initHomePage() {
    loadTheme();
    loadSearchHistory();
  }

  // On opening filter page, load translations from user prefs and update language toggles
  void initFilterPage() {
    loadTranslations();
    loadLanguagePref();
  }

  /// add search query and update user prefs
  void addSearchQuery(String keywords) {
    searchQuery = keywords;
    if (keywords.length > 0) {
      searchQueries.add(keywords);
      updateSearchHistory();
    }
    notifyListeners();
  }

  /// clear search queries and update user prefs
  void clearSearchQueries() {
    searchQueries = [];
    updateSearchHistory();
    notifyListeners();
  }

  /// load dark or light theme from user prefs
  void loadTheme() async {
    await SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool('theme') == null) {
        prefs.setBool('theme', false);
      }
      isDarkTheme = prefs.getBool('theme');
    });
  }

  /// load the search history from user prefs
  void loadSearchHistory() async {
    await SharedPreferences.getInstance().then((prefs) {
      searchQueries = (prefs.getStringList('searchHistory') ?? []);
    });
  }

  /// update the search history with current user prefs
  void updateSearchHistory() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(
          'searchHistory',
          searchQueries =
              searchQueries.reversed.toSet().toList().reversed.toList());
    });
  }

  void changeTheme(bool b, BuildContext context) {
    DynamicTheme.of(context).setThemeData(ThemeData(
      primarySwatch: Colors.orange,
      primaryColorBrightness: Brightness.dark,
      brightness: b ? Brightness.dark : Brightness.light,
    ));
    isDarkTheme = b;
    updateTheme(b);
  }

  void updateTheme(bool b) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('theme', isDarkTheme);
  }

  /// update search queries user prefs and navigate to results page
  void updateSearchAndNavigateToResults(BuildContext context, String keywords) {
    // searchResults = [];
    addSearchQuery(keywords);
    Navigator.of(context).push(MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return ResultsPage();
      },
    ));
  }

  void navigateToFilter(BuildContext context, int filterNum) {
    initFilterPage();
    Navigator.of(context).push(MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return TranslationBookFilterPage(tabValue: filterNum);
      },
      fullscreenDialog: true,
    ));
  }

  /// load translations chosen from user prefs
  void loadTranslations() async {
    // TODO (What happens if can't connect to internet?) need to test
    final temp = await BibleTranslations.fetch();
    temp.data.sort((f, k) => f.lang.id.compareTo(k.lang.id));
    final prefs = await SharedPreferences.getInstance();
    //select only translations that are in the formatted Id
    if (prefs.getString('translations') == null) {
      prefs.setString('translations', temp.formatIds());
    }
    translationIds = prefs.getString('translations');
    translations = temp;
    translations.selectTranslations(translationIds);
  }

  void updateTranslations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('translations', translationIds = translations.formatIds());
    translations.selectTranslations(translationIds);
    notifyListeners();
  }

  void loadLanguagePref() {
    if (translations != null) {
      for (final each in translations.data) {
        if (!each.isSelected) {
          each.lang.isSelected = false;
          languages.firstWhere((l) => l.id == each.lang.id).isSelected = false;
        }
      }
    }
  }

  void chooseTranslation(bool b, int i) {
    translations.data[i].isSelected = b;
    if (!b) {
      translations.data[i].lang.isSelected = b;
      languages.firstWhere((l) => l.id == translations.data[i].lang.id).isSelected = b;
    }
    var currLang = translations.data[i].lang;
    var currLangList = translations.data.where((test) {
      return test.lang == currLang;
    }).toList();
    if (currLangList.any((bt) => !bt.isSelected)) {
      updateTranslations();
    } else {
      selectLang(currLang, true);
    }
  }

  void selectLang(Language lang, bool b) {
    translations.data.forEach((each) {
      if (each.lang.id == lang.id) {
        each.isSelected = b;
      }
    });
    languages.firstWhere((l) => l.id == lang.id).isSelected = b;
    updateTranslations();
  }

  void chooseBook(bool b, int i) {
    bookNames[i].isSelected = b;
    if (!b) {
      bookNames[i].isOT() ? otSelected = b : ntSelected = b;
    }
    var isOT = bookNames[i].isOT();
    var books = bookNames.where((bn) => bn.isOT() == isOT).toList();
    if (books.any((b) => !b.isSelected)) {
      notifyListeners();
    } else {
      isOT ? selectOT(true) : selectNT(true);
    }
    notifyListeners();
  }

  void selectOT(bool b) {
    bookNames.forEach((each) {
      if (each.isOT()) {
        each.isSelected = b;
      }
    });
    otSelected = b;
    notifyListeners();
  }

  void selectNT(bool b) {
    bookNames.forEach((each) {
      if (!each.isOT()) {
        each.isSelected = b;
      }
    });
    ntSelected = b;
    notifyListeners();
  }

  final languages = <Language>[
    Language(a: 'en', name: "English", id: 0, isSelected: true),
    Language(a: 'es', name: "Español", id: 1, isSelected: true),
    Language(a: 'zh', name: "Chinese", id: 2, isSelected: true),
    Language(a: 'ko', name: "Korean", id: 3, isSelected: true),
  ];

  final bookNames = <Book>[
    Book(name: "Genesis", id: 1),
    Book(name: "Exodus", id: 2),
    Book(name: "Leviticus", id: 3),
    Book(name: "Numbers", id: 4),
    Book(name: "Deuteronomy", id: 5),
    Book(name: "Joshua", id: 6),
    Book(name: "Judges", id: 7),
    Book(name: "Ruth", id: 8),
    Book(name: "1 Samuel", id: 9),
    Book(name: "2 Samuel", id: 10),
    Book(name: "1 Kings", id: 11),
    Book(name: "2 Kings", id: 12),
    Book(name: "1 Chronicles", id: 13),
    Book(name: "2 Chronicles", id: 14),
    Book(name: "Ezra", id: 15),
    Book(name: "Nehemiah", id: 16),
    Book(name: "Esther", id: 19),
    Book(name: "Job", id: 22),
    Book(name: "Psalm", id: 23),
    Book(name: "Proverbs", id: 24),
    Book(name: "Ecclesiastes", id: 25),
    Book(name: "Song of Solomon", id: 26),
    Book(name: "Isaiah", id: 29),
    Book(name: "Jeremiah", id: 30),
    Book(name: "Lamentations", id: 31),
    Book(name: "Ezekiel", id: 33),
    Book(name: "Daniel", id: 34),
    Book(name: "Hosea", id: 35),
    Book(name: "Joel", id: 36),
    Book(name: "Amos", id: 37),
    Book(name: "Obadiah", id: 38),
    Book(name: "Jonah", id: 39),
    Book(name: "Micah", id: 40),
    Book(name: "Nahum", id: 41),
    Book(name: "Habakkuk", id: 42),
    Book(name: "Zephaniah", id: 43),
    Book(name: "Haggai", id: 44),
    Book(name: "Zechariah", id: 45),
    Book(name: "Malachi", id: 46),
    Book(name: "Matthew", id: 47),
    Book(name: "Mark", id: 48),
    Book(name: "Luke", id: 49),
    Book(name: "John", id: 50),
    Book(name: "Acts", id: 51),
    Book(name: "Romans", id: 52),
    Book(name: "1 Corinthians", id: 53),
    Book(name: "2 Corinthians", id: 54),
    Book(name: "Galatians", id: 55),
    Book(name: "Ephesians", id: 56),
    Book(name: "Philippians", id: 57),
    Book(name: "Colossians", id: 58),
    Book(name: "1 Thessalonians", id: 59),
    Book(name: "2 Thessalonians", id: 60),
    Book(name: "1 Timothy", id: 61),
    Book(name: "2 Timothy", id: 62),
    Book(name: "Titus", id: 63),
    Book(name: "Philemon", id: 64),
    Book(name: "Hebrews", id: 65),
    Book(name: "James", id: 66),
    Book(name: "1 Peter", id: 67),
    Book(name: "2 Peter", id: 68),
    Book(name: "1 John", id: 69),
    Book(name: "2 John", id: 70),
    Book(name: "3 John", id: 71),
    Book(name: "Jude", id: 72),
    Book(name: "Revelation", id: 73),
  ];

  final extraBookNames = {
    "ge": 1,
    "gen": 1,
    "genesis": 1,
    "exodus": 2,
    "ex": 2,
    "exo": 2,
    "exod": 2,
    "leviticus": 3,
    "lev": 3,
    "numbers": 4,
    "nu": 4,
    "num": 4,
    "deuteronomy": 5,
    "deut": 5,
    "dt": 5,
    "joshua": 6,
    "jos": 6,
    "josh": 6,
    "judges": 7,
    "jdg": 7,
    "judg": 7,
    "ruth": 8,
    "ru": 8,
    "1 samuel": 9,
    "1samuel": 9,
    "1sa": 9,
    "1 sa": 9,
    "1 sam": 9,
    "2 samuel": 10,
    "2samuel": 10,
    "2sa": 10,
    "2 sa": 10,
    "2 sam": 10,
    "1 kings": 11,
    "1kings": 11,
    "1ki": 11,
    "1 kgs": 11,
    "1 ki": 11,
    "1 kin": 11,
    "2 kings": 12,
    "2kings": 12,
    "2 ki": 12,
    "2 kin": 12,
    "2 kgs": 12,
    "2ki": 12,
    "1 chronicles": 13,
    "1chronicles": 13,
    "1ch": 13,
    "1 ch": 13,
    "1 chron": 13,
    "1 chr": 13,
    "2 chronicles": 14,
    "2chronicles": 14,
    "2ch": 14,
    "2 ch": 14,
    "2 chron": 14,
    "2 chr": 14,
    "ezra": 15,
    "ezr": 15,
    "nehemiah": 16,
    "ne": 16,
    "neh": 16,
    "esther": 19,
    "est": 19,
    "esth": 19,
    "job": 22,
    "psalms": 23,
    "psalm": 23,
    "ps": 23,
    "proverbs": 24,
    "pr": 24,
    "prov": 24,
    "ecclesiastes": 25,
    "ecc": 25,
    "eccl": 25,
    "song of solomon": 26,
    "song_of_solomon": 26,
    "song": 26,
    "ss": 26,
    "is": 29,
    "isaiah": 29,
    "isa": 29,
    "jeremiah": 30,
    "jer": 30,
    "lamentations": 31,
    "la": 31,
    "lam": 31,
    "ezekiel": 33,
    "eze": 33,
    "ezek": 33,
    "daniel": 34,
    "da": 34,
    "dan": 34,
    "hosea": 35,
    "hos": 35,
    "joel": 36,
    "amos": 37,
    "am": 37,
    "obadiah": 38,
    "ob": 38,
    "oba": 38,
    "obad": 38,
    "jonah": 39,
    "jon": 39,
    "jnh": 39,
    "micah": 40,
    "mic": 40,
    "nahum": 41,
    "na": 41,
    "nah": 41,
    "habakkuk": 42,
    "hab": 42,
    "zephaniah": 43,
    "zep": 43,
    "zeph": 43,
    "haggai": 44,
    "hag": 44,
    "ha": 44,
    "zechariah": 45,
    "zec": 45,
    "zech": 45,
    "malachi": 46,
    "mal": 46,
    "matthew": 47,
    "matt": 47,
    "mt": 47,
    "mark": 48,
    "mk": 48,
    "luke": 49,
    "lk": 49,
    "john": 50,
    "jn": 50,
    "acts": 51,
    "ac": 51,
    "romans": 52,
    "ro": 52,
    "rom": 52,
    "1 corinthians": 53,
    "1corinthians": 53,
    "1co": 53,
    "1 co": 53,
    "1 cor": 53,
    "2 corinthians": 54,
    "2corinthians": 54,
    "2co": 54,
    "2 co": 54,
    "2 cor": 54,
    "galatians": 55,
    "gal": 55,
    "ephesians": 56,
    "eph": 56,
    "philippians": 57,
    "php": 57,
    "phil": 57,
    "colossians": 58,
    "col": 58,
    "1 thessalonians": 59,
    "1thessalonians": 59,
    "1th": 59,
    "1thes": 59,
    "1 thes": 59,
    "1 thess": 59,
    "1 th": 59,
    "2 thessalonians": 60,
    "2thessalonians": 60,
    "2 th": 60,
    "2 thes": 60,
    "2 thess": 60,
    "2th": 60,
    "2thes": 60,
    "1 timothy": 61,
    "1 ti": 61,
    "1 tim": 61,
    "1timothy": 61,
    "1ti": 61,
    "2 timothy": 62,
    "2 ti": 62,
    "2 tim": 62,
    "2timothy": 62,
    "2ti": 62,
    "titus": 63,
    "tit": 63,
    "philemon": 64,
    "phm": 64,
    "philem": 64,
    "hebrews": 65,
    "heb": 65,
    "james": 66,
    "jas": 66,
    "1 peter": 67,
    "1peter": 67,
    "1pe": 67,
    "1 pe": 67,
    "1 pet": 67,
    "2 peter": 68,
    "2peter": 68,
    "2 pe": 68,
    "2 pet": 68,
    "2pe": 68,
    "1 john": 69,
    "1jhn": 69,
    "1john": 69,
    "1jn": 69,
    "2 john": 70,
    "2john": 70,
    "2jhn": 70,
    "2jn": 70,
    "3 john": 71,
    "3john": 71,
    "3jn": 71,
    "jude": 72,
    "revelation": 73,
    "rev": 73,
  };
}
