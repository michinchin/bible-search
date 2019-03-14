import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/translation.dart';
import 'package:bible_search/data/votd_image.dart';

/// Search Actions
class SearchAction {
  final String searchQuery;
  SearchAction(this.searchQuery);
}

class SearchLoadingAction {}

class SearchErrorAction {}

class SearchResultAction {
  final List<SearchResult> result;

  SearchResultAction(this.result);
}

class SetSelectionModeAction{}

/// Init Home Actions
class InitHomeAction {}

class ImageLoadingAction {}

class ImageResultAction {
  final VOTDImage votdImage;
  ImageResultAction(this.votdImage);
}

class SetThemeAction {
  bool isDarkTheme;
  SetThemeAction(this.isDarkTheme);
}

class SetSearchHistoryAction {
  final List<String> searchQueries;
  SetSearchHistoryAction(this.searchQueries);
}

class SetLanguagesAction {
  final List<Language> languages;
  SetLanguagesAction(this.languages);
}

class SetBookNamesAction {
  final List<Book> bookNames;
  SetBookNamesAction(this.bookNames);
}

class SetTranslationsAction {
  final BibleTranslations translations;
  SetTranslationsAction(this.translations);
}

class SetTestamentAction {
  final bool toggle;
  final Test test;
  SetTestamentAction(this.toggle,this.test);
}

enum Test{OT, NT}

class UpdateTranslationsAction{}

/// Init Filter Actions
class InitFilterAction {}

class SelectAction {
  final Filter select;
  final bool toggle;
  final int index;
  // final dynamic item;
  SelectAction(this.toggle, this.index, this.select);
}

enum Filter {
  TRANSLATION,
  BOOK, //index indicates ot or nt (-2 or -1) or book index
  LANGUAGE
}
