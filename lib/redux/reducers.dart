import 'package:bible_search/labels.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/redux/actions.dart';
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';

final reducers = combineReducers<AppState>([
  /// Load Search Reducers
  TypedReducer<AppState, SearchLoadingAction>(_onLoad),
  TypedReducer<AppState, SearchErrorAction>(_onError),
  TypedReducer<AppState, SearchNoTranslationsAction>(_onNoTranslationsSearch),
  TypedReducer<AppState, SearchResultAction>(_onResult),
  TypedReducer<AppState, SetSelectionModeAction>(_onSetSelectionMode),

  /// Init Home Reducers
  TypedReducer<AppState, ImageLoadingAction>(_onImageLoad),
  TypedReducer<AppState, StateChangeAction>(_onStateChange),
  // TypedReducer<AppState, ImageResultAction>(_onImageLoaded),
  TypedReducer<AppState, SetThemeAction>(_onThemeSet),
  TypedReducer<AppState, SetSearchHistoryAction>(_onSearchHistorySet),
  // TypedReducer<AppState, SetNoAdsPurchasedAction>(_onNoAdsPurchasedSet),

  /// Init Filter Reducers
  TypedReducer<AppState, SetTranslationsAction>(_onTranslationsSet),
  TypedReducer<AppState, SetLanguagesAction>(_onLanguagesSet),
  TypedReducer<AppState, SetBookNamesAction>(_onBookNamesSet),
  TypedReducer<AppState, SetTestamentAction>(_onTestamentSet),
  TypedReducer<AppState, SetResultsAction>(_onResultsChanged),
  TypedReducer<AppState, SetFilteredResultsAction>(_onFiltered),
  TypedReducer<AppState, SetNumSelectedAction>(_onSelected),
]);

AppState _onLoad(AppState state, SearchLoadingAction action) =>
    state.copyWith(isFetchingSearch: true);

AppState _onError(AppState state, SearchErrorAction action) => state.copyWith(
    hasError: true, isFetchingSearch: false, hasNoTranslationsSelected: false);

AppState _onNoTranslationsSearch(
        AppState state, SearchNoTranslationsAction action) =>
    state.copyWith(
        hasError: false,
        isFetchingSearch: false,
        results: [],
        hasNoTranslationsSelected: true);

AppState _onResult(AppState state, SearchResultAction action) {
  if (action.res.isEmpty) {
    return state.copyWith(
        results: [],
        isFetchingSearch: false,
        filteredResults: [],
        hasError: false,
        hasNoTranslationsSelected: false);
  } else {
    return state.copyWith(
        results: action.res,
        isFetchingSearch: false,
        hasError: false,
        hasNoTranslationsSelected: false);
  }
}

AppState _onResultsChanged(AppState state, SetResultsAction action) =>
    state.copyWith(results: action.res);

AppState _onFiltered(AppState state, SetFilteredResultsAction action) =>
    state.copyWith(filteredResults: action.res);

AppState _onSetSelectionMode(AppState state, SetSelectionModeAction action) {
  if (state.isInSelectionMode) {
    final res = state.results;
    res.map((r) => r.isSelected = false).toList();
    return state.copyWith(
        isInSelectionMode: !state.isInSelectionMode,
        results: res,
        numSelected: 0);
  }
  return state.copyWith(isInSelectionMode: !state.isInSelectionMode);
}

AppState _onSelected(AppState state, SetNumSelectedAction action) =>
    state.copyWith(numSelected: action.numSelected);

AppState _onImageLoad(AppState state, ImageLoadingAction action) =>
    state.copyWith(isLoadingImage: true);

AppState _onStateChange(AppState state, StateChangeAction action) =>
    state.copyWith(state: action.state);

// AppState _onImageLoaded(AppState state, ImageResultAction action) =>
//     state.copyWith(votdImage: action.votdImage);

AppState _onThemeSet(AppState state, SetThemeAction action) {
  print('set dark');
  SystemChrome.setSystemUIOverlayStyle(
      action.isDarkTheme ? darkOverlay : lightOverlay);
  return state.copyWith(isDarkTheme: action.isDarkTheme);
}

AppState _onSearchHistorySet(AppState state, SetSearchHistoryAction action) =>
    state.copyWith(
        searchHistory: action.searchQueries, searchQuery: action.searchQuery);

// AppState _onNoAdsPurchasedSet(AppState state, SetNoAdsPurchasedAction action) =>
//     state.copyWith(noAdsPurchased: action.noAdsPurchased);

AppState _onLanguagesSet(AppState state, SetLanguagesAction action) =>
    state.copyWith(languages: action.languages);

AppState _onBookNamesSet(AppState state, SetBookNamesAction action) =>
    state.copyWith(books: action.bookNames);

AppState _onTranslationsSet(AppState state, SetTranslationsAction action) =>
    state.copyWith(translations: action.translations);

AppState _onTestamentSet(AppState state, SetTestamentAction action) {
  if (action.test == Test.oT) {
    return state.copyWith(otSelected: action.toggle);
  }
  return state.copyWith(ntSelected: action.toggle);
}
