import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/translation.dart';
import 'package:bible_search/data/votd_image.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final BibleTranslations translations;
  final List<SearchResult> results;
  final List<SearchResult> filteredResults;
  final VOTDImage votdImage;
  final String searchQuery;
  final List<String> searchHistory;
  final List<Language> languages;
  final List<Book> books;

  final bool isFetchingSearch;
  final bool isLoadingImage;
  final bool isInSelectionMode;
  final bool hasError;
  final bool isDarkTheme;
  final bool otSelected;
  final bool ntSelected;

  final int numSelected;

  const AppState({
    this.translations,
    this.results,
    this.filteredResults,
    this.votdImage,
    this.searchQuery,
    this.searchHistory,
    this.languages,
    this.books,
    this.isFetchingSearch,
    this.isLoadingImage,
    this.isInSelectionMode,
    this.hasError,
    this.isDarkTheme,
    this.otSelected,
    this.ntSelected,
    this.numSelected,
  });

  factory AppState.initial() => AppState(
        translations: BibleTranslations(data: []),
        results: const [],
        filteredResults: const [],
        votdImage: null,
        searchQuery: '',
        searchHistory: const [],
        languages: const [],
        books: const [],
        isFetchingSearch: false,
        isLoadingImage: false,
        isInSelectionMode: false,
        hasError: false,
        isDarkTheme: false,
        otSelected: true,
        ntSelected: true,
        numSelected: 0,
      );

  AppState copyWith(
      {BibleTranslations translations,
      List<SearchResult> results,
      List<SearchResult> filteredResults,
      VOTDImage votdImage,
      String searchQuery,
      List<String> searchHistory,
      List<Language> languages,
      List<Book> books,
      bool isFetchingSearch,
      bool isLoadingImage,
      bool isInSelectionMode,
      bool hasError,
      bool isDarkTheme,
      bool otSelected,
      bool ntSelected,
      int numSelected}) {
    return AppState(
        translations: translations ?? this.translations,
        results: results ?? this.results,
        filteredResults: filteredResults ?? this.filteredResults,
        votdImage: votdImage ?? this.votdImage,
        searchQuery: searchQuery ?? this.searchQuery,
        searchHistory: searchHistory ?? this.searchHistory,
        languages: languages ?? this.languages,
        books: books ?? this.books,
        isFetchingSearch: isFetchingSearch ?? this.isFetchingSearch,
        isLoadingImage: isLoadingImage ?? this.isLoadingImage,
        isInSelectionMode: isInSelectionMode ?? this.isInSelectionMode,
        hasError: hasError ?? this.hasError,
        isDarkTheme: isDarkTheme ?? this.isDarkTheme,
        otSelected: otSelected ?? this.otSelected,
        ntSelected: ntSelected ?? this.ntSelected,
        numSelected: numSelected ?? this.numSelected);
  }

  String get selectedText {
    var text = '';
    for (final each in filteredResults) {
      final currVerse = each.verses[each.currentVerseIndex];
      if (each.isSelected && each.contextExpanded) {
        text += '${books.where((book) => book.id == each.bookId).first.name} '
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
}
