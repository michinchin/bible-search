import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/translation.dart';
import 'package:flutter/material.dart';

/// Search Actions
class SearchAction {
  final String searchQuery;
  SearchAction(this.searchQuery);
}

class SearchLoadingAction {}

class SearchErrorAction {}

class SearchNoTranslationsAction {}

class SearchResultAction {
  final List<SearchResult> res;
  final int numAdsAvailable;
  SearchResultAction(this.res, {this.numAdsAvailable = 0});
}

class SetResultsAction {
  final List<SearchResult> res;
  SetResultsAction(this.res);
}

class SetFilteredResultsAction {
  final List<SearchResult> res;
  SetFilteredResultsAction(this.res);
}

class SetNumSelectedAction {
  final int numSelected;
  SetNumSelectedAction(this.numSelected);
}

class GetContextAction {
  final int idx;
  GetContextAction(this.idx);
}

class SetSelectionModeAction {}

/// Init Home Actions
class InitHomeAction {}

class ImageLoadingAction {}

class StateChangeAction {
  AppLifecycleState state;
  StateChangeAction({this.state});
}

// class ImageResultAction {
//   final VOTDImage votdImage;
//   ImageResultAction(this.votdImage);
// }

class SetThemeAction {
  bool isDarkTheme;
  SetThemeAction({this.isDarkTheme});
}

class SetSearchHistoryAction {
  final String searchQuery;
  final List<String> searchQueries;
  SetSearchHistoryAction({this.searchQuery = '', this.searchQueries});
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
  SetTestamentAction(this.test, {this.toggle});
}

enum Test { oT, nT }

class UpdateTranslationsAction {}

/// Init Filter Actions
class InitFilterAction {}

class SelectionAction {
  final Select select;
  final bool toggle;
  final int index;
  // final dynamic item;
  SelectionAction(this.index, this.select, {this.toggle});
}

enum Select {
  translation,
  defaultTranslation,
  book, //index indicates ot or nt (-2 or -1) or book index
  language,
  result
}
