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
  final List<SearchResult> res;
  SearchResultAction(this.res);
}

class SetResultsAction{
  final List<SearchResult> res;
  SetResultsAction(this.res);
}

class SetFilteredResultsAction{
  final List<SearchResult> res;
  SetFilteredResultsAction(this.res);
}

class SetNumSelectedAction{
  final int numSelected;
  SetNumSelectedAction(this.numSelected);
}
class ContextAction{
  final int idx;
  ContextAction(this.idx);
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
  SetThemeAction({this.isDarkTheme});
}

class SetSearchHistoryAction {
  final String searchQuery;
  final List<String> searchQueries;
  SetSearchHistoryAction({this.searchQuery = '',this.searchQueries});
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
  SetTestamentAction(this.test,{this.toggle});
}

enum Test{oT, nT}

class UpdateTranslationsAction{}

/// Init Filter Actions
class InitFilterAction {}

class SelectAction {
  final Select select;
  final bool toggle;
  final int index;
  // final dynamic item;
  SelectAction( this.index, this.select,{this.toggle});
}

enum Select {
  translation,
  book, //index indicates ot or nt (-2 or -1) or book index
  language,
  result
}
