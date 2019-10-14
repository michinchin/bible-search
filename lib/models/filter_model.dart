import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/translation.dart';
import 'package:bible_search/labels.dart';
import 'package:tec_util/tec_util.dart' as tec;

class FilterModel {
  /// load translations chosen from user prefs
  Future<BibleTranslations> loadTranslations() async {
    final temp = await BibleTranslations.fetch();
    temp.data.sort((f, k) => f.lang.id.compareTo(k.lang.id));
    final translations = temp;
    //select only translations that are in the formatted Id
    final translationIds = tec.Prefs.shared.getString(translationsPref);
    if (translationIds == null || translationIds.trim().isEmpty) {
      await tec.Prefs.shared.setString(translationsPref, temp.formatIds());
    } else {
      translations.selectTranslations(translationIds);
    }

    return translations;
  }

  /// update translations chosen each time one is chosen
  Future<BibleTranslations> updateTranslations(
      BibleTranslations translations) async {
    var translationIds = '';
    await tec.Prefs.shared
        .setString(translationsPref, translationIds = translations.formatIds());

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
    return <dynamic>[translations, languages];
  }

  /// choose the translation in list and update translations in user prefs
  List chooseTranslation(
      int i, BibleTranslations translations, List<Language> languages,
      {bool b}) {
    BibleTranslations t;
    List<Language> l;
    translations.data[i].isSelected = b;
    if (!b) {
      translations.data[i].lang.isSelected = b;
      languages
          .firstWhere((l) => l.id == translations.data[i].lang.id)
          .isSelected = b;
    }
    final currLang = translations.data[i].lang;
    final currLangList = translations.data.where((test) {
      return test.lang.id == currLang.id;
    }).toList();
    if (!currLangList.any((bt) => !bt.isSelected)) {
      final tl = selectLang(
        currLang,
        translations,
        languages,
        b: true,
      );
      t = tec.as<BibleTranslations>(tl[0]);
      l = tec.as<List<Language>>(tl[1]);
    }
    return <dynamic>[t, l];
  }

  /// select the language and update translations in user prefs to represent which are chosen
  List selectLang(
      Language lang, BibleTranslations translations, List<Language> languages,
      {bool b}) {
    for (final each in translations.data) {
      if (each.lang.id == lang.id) {
        each.isSelected = b;
      }
    }
    languages.firstWhere((l) => l.id == lang.id).isSelected = b;
    updateTranslations(translations);
    return <dynamic>[translations, languages];
  }

  /// select a book of the bible and check for OT or NT selection
  List chooseBook(
      {bool b, int i, List<Book> bookNames, bool otSelected, bool ntSelected}) {
    var modBookNames = List<Book>.from(bookNames);
      // ..map(((b) {
      //   if (b.numResults > 0) {
      //     return b;
      //   }
      // }));
    var oT = otSelected;
    var nT = ntSelected;
    if (i == -2) {
      chooseTestament(
        bookNames,
        b: b,
        isOT: true,
      );
      oT = b;
    } else if (i == -1) {
      chooseTestament(
        bookNames,
        b: b,
        isOT: false,
      );
      nT = b;
    } else {
      //deselect all if one selected
      if (!b) {
        bookNames[i].isOT() ? oT = b : nT = b;
      }
      //is OT
      final isOT = bookNames[i].isOT();
      final books = bookNames.where((bn) => bn.isOT() == isOT).toList();

      if (!books.any((b) => !b.isSelected) && !b) {
        modBookNames = chooseTestament(bookNames, b: b, isOT: isOT);
        if (isOT) {
          oT = b;
        } else {
          nT = b;
        }
        modBookNames[i].isSelected = !b;
        return <dynamic>[modBookNames, oT, nT];
      }

      modBookNames[i].isSelected = b;
      if (!(books.any((bk) => !bk.isSelected))) {
        // final books = bookNames.where((bn) => bn.isOT() == isOT).toList();
        modBookNames = chooseTestament(bookNames, b: b, isOT: isOT);
        if (isOT) {
          oT = b;
        } else {
          nT = b;
        }
        modBookNames[i].isSelected = b;
      }
    }
    return <dynamic>[modBookNames, oT, nT];
  }

  List<Book> chooseTestament(List<Book> bookNames, {bool b, bool isOT}) {
    for (final each in bookNames) {
      if (isOT ? each.isOT() : !each.isOT()) {
        each.isSelected = b;
      }
    }
    return bookNames;
  }

  List<SearchResult> updateBooks(
      List<SearchResult> searchRes, List<Book> bookNames) {
    final books = List<Book>.from(bookNames);
    final results = List<SearchResult>.from(searchRes);
    for (final b in books) {
      b.numResults = results.where((r) => r.bookId == b.id).toList().length;
    }
    return filterByBook(searchRes, books);
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
