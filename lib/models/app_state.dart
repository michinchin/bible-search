import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/translation.dart';
import 'package:bible_search/data/votd_image.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final BibleTranslations translations;
  final List<SearchResult> results;
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

  const AppState({
    this.translations,
    this.results,
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
    this.ntSelected
  });

  factory AppState.initial() => AppState(
      translations: BibleTranslations(data: []),
      results: [],
      votdImage: null,
      searchQuery: '',
      searchHistory: [],
      languages: [],
      books: [],
      isFetchingSearch: false,
      isLoadingImage: false,
      isInSelectionMode: false,
      hasError: false,
      isDarkTheme: false,
      otSelected: true,
      ntSelected: true);
  
  AppState copyWith({
    BibleTranslations translations,
     List<SearchResult> results,
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
     bool ntSelected
  }){
    return new AppState(
      translations: translations ?? this.translations,
      results: results ?? this.results,
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
    );
  }
}
