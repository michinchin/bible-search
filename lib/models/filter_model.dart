import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterModel {
  /// load translations chosen from user prefs
  Future<BibleTranslations> loadTranslations() async {
    // TODO (What happens if can't connect to internet?) need to test
    final temp = await BibleTranslations.fetch();
    temp.data.sort((f, k) => f.lang.id.compareTo(k.lang.id));
    final prefs = await SharedPreferences.getInstance();
    //select only translations that are in the formatted Id
    var translationIds = prefs.getString('translations');
    if (translationIds == null || translationIds.trim().length == 0) {
      prefs.setString('translations', temp.formatIds());
    }
    var translations = temp;
    translations.selectTranslations(translationIds);
    return translations;
  }

  /// update translations chosen each time one is chosen
  Future<BibleTranslations> updateTranslations(
      BibleTranslations translations) async {
    var translationIds = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('translations', translationIds = translations.formatIds());
    translations.selectTranslations(translationIds);
    return translations;
  }

  /// select language pref based on translations
  List loadLanguagePref(
      BibleTranslations translations, List<Language> languages) {
    if (translations != null) {
      for (final each in translations.data) {
        if (!each.isSelected) {
          each.lang.isSelected = false;
          languages.firstWhere((l) => l.id == each.lang.id).isSelected = false;
        }
      }
    }
    return [translations, languages];
  }

  /// choose the translation in list and update translations in user prefs
  List chooseTranslation(
      bool b, int i, BibleTranslations translations, List<Language> languages) {
    translations.data[i].isSelected = b;
    if (!b) {
      translations.data[i].lang.isSelected = b;
      languages
          .firstWhere((l) => l.id == translations.data[i].lang.id)
          .isSelected = b;
    }
    var currLang = translations.data[i].lang;
    var currLangList = translations.data.where((test) {
      return test.lang.id == currLang.id;
    }).toList();
    if (currLangList.any((bt) => !bt.isSelected)) {
      updateTranslations(translations);
      // notifyListeners();
    } else {
      final tl = selectLang(currLang, true, translations, languages);
      translations = tl[0];
      languages = tl[1];
    }
    return [translations, languages];
  }

  /// select the language and update translations in user prefs to represent which are chosen
  List selectLang(Language lang, bool b, BibleTranslations translations,
      List<Language> languages) {
    translations.data.forEach((each) {
      if (each.lang.id == lang.id) {
        each.isSelected = b;
      }
    });
    languages.firstWhere((l) => l.id == lang.id).isSelected = b;
    updateTranslations(translations);
    return [translations, languages];
  }

  /// select a book of the bible and check for OT or NT selection
  List chooseBook(
      {bool b, int i, List<Book> bookNames, bool otSelected, bool ntSelected}) {
    if (i == -2) {
      chooseTestament(true, bookNames, b);
      otSelected = b;
    } else if (i == -1) {
      chooseTestament(false, bookNames, b);
      ntSelected = b;
    } else {
      bookNames[i].isSelected = b;
      if (!b) {
        bookNames[i].isOT() ? otSelected = b : ntSelected = b;
      }
      var isOT = bookNames[i].isOT();
      var books = bookNames.where((bn) => bn.isOT() == isOT).toList();
      if (!(books.any((b) => !b.isSelected))) {
        bookNames = chooseTestament(isOT, bookNames, b);
        if (isOT) {
          otSelected = b;
        } else {
          ntSelected = b;
        }
      }
    }
    return [bookNames, otSelected, ntSelected];
  }

  List<Book> chooseTestament(bool isOT, List<Book> bookNames, bool b) {
    bookNames.forEach((each) {
      if (isOT ? each.isOT() : !each.isOT()) {
        each.isSelected = b;
      }
    });
    return bookNames;
  }

  List<SearchResult> filterByBook(
      List<SearchResult> searchRes, List<Book> bookNames) {
    final sr = searchRes.where((res) {
      for (final each in bookNames) {
        if (each.id == res.bookId && each.isSelected) {
          return true;
        }
      }
      return false;
    }).toList();
    return sr;
  }
}
