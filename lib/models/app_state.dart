import 'dart:ui';

import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/translation.dart';
import 'package:bible_search/data/votd_image.dart';
import 'package:meta/meta.dart';
import 'package:tec_user_account/tec_user_account.dart';
import 'package:tec_util/tec_util.dart' as tec;

@immutable
class AppState {
  final tec.DeviceInfo deviceInfo;
  final AppLifecycleState state;
  final UserAccount userAccount;

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
  final bool hasNoTranslationsSelected;

  final int numSelected;

  const AppState({
    this.deviceInfo,
    this.state,
    this.userAccount,
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
    this.hasNoTranslationsSelected,
    this.hasError,
    this.isDarkTheme,
    this.otSelected,
    this.ntSelected,
    this.numSelected,
  });

  factory AppState.initial(
          {tec.DeviceInfo deviceInfo,
          AppLifecycleState state,
          UserAccount userAccount}) =>
      AppState(
        deviceInfo: deviceInfo,
        state: state,
        userAccount: userAccount,
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
        hasNoTranslationsSelected: false,
        hasError: false,
        isDarkTheme: false,
        otSelected: true,
        ntSelected: true,
        numSelected: 0,
      );

  AppState copyWith(
      {tec.DeviceInfo deviceInfo,
      AppLifecycleState state,
      UserAccount userAccount,
      BibleTranslations translations,
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
      bool hasNoTranslationsSelected,
      bool hasError,
      bool isDarkTheme,
      bool otSelected,
      bool ntSelected,
      int numSelected}) {
    return AppState(
        deviceInfo: deviceInfo ?? this.deviceInfo,
        state: state ?? this.state,
        userAccount: userAccount ?? this.userAccount,
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
        hasNoTranslationsSelected:
            hasNoTranslationsSelected ?? this.hasNoTranslationsSelected,
        hasError: hasError ?? this.hasError,
        isDarkTheme: isDarkTheme ?? this.isDarkTheme,
        otSelected: otSelected ?? this.otSelected,
        ntSelected: ntSelected ?? this.ntSelected,
        numSelected: numSelected ?? this.numSelected);
  }
}
