import 'package:bible_search/data/context.dart';
import 'package:bible_search/models/filter_model.dart';
import 'package:bible_search/redux/actions.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:redux/redux.dart';
import 'package:bible_search/data/votd_image.dart';
import 'package:bible_search/models/home_model.dart';

final filterModel = FilterModel();
final homeModel = HomeModel();

final searchMiddleware = (
  Store<AppState> store,
  SearchAction action,
  NextDispatcher next,
) {
  store.dispatch(SearchLoadingAction());
  List<String> newSearchList = store.state.searchHistory;
  newSearchList.add(action.searchQuery);
  store.dispatch(SetSearchHistoryAction(
      searchQuery: action.searchQuery,
      searchQueries:
          newSearchList.reversed.toSet().toList().reversed.toList()));
  SearchResults.fetch(
    words: action.searchQuery,
    translationIds: store.state.translations.formatIds(),
  ).then((res) {
    store.dispatch(SearchResultAction(res));
    store.dispatch(SetFilteredResultsAction(filterModel.filterByBook(res, store.state.books)));
  }).catchError((e) {
    store.dispatch(SearchErrorAction());
  });
  next(action);
};

final contextMiddleware = (
  Store<AppState> store,
  ContextAction action,
  NextDispatcher next,
) {
  final res = store.state.results[action.idx];
  if (res.verses[res.currentVerseIndex].contextText.length == 0) {
    Context.fetch(
            translation: res.verses[res.currentVerseIndex].id,
            book: res.bookId,
            chapter: res.chapterId,
            verse: res.verseId)
        .then((context) {
      var results = store.state.results;
      results[action.idx].verses[res.currentVerseIndex].contextText =
          context.text;
      results[action.idx].verses[res.currentVerseIndex].verseIdx = [
        context.initialVerse,
        context.finalVerse
      ];
      store.dispatch(SetResultsAction(results));
    });
  }
};

/// Fetch verse of the day, init home page by loading theme and search history from user preferences, and load languages and bookNames
final initHomeMiddleware = (
  Store<AppState> store,
  InitHomeAction action,
  NextDispatcher next,
) {
  store.dispatch(ImageLoadingAction());
  VOTDImage.fetch().then((votd) {
    store.dispatch(ImageResultAction(votd));
  }).catchError((e) {
    store.dispatch(ImageResultAction(VOTDImage(url: 'assets/appimage.jpg')));
  });
  homeModel.loadTheme().then((theme) {
    store.dispatch(SetThemeAction(theme));
  });
  homeModel.loadSearchHistory().then((searchHistory) {
    store.dispatch(SetSearchHistoryAction(searchQueries: searchHistory));
  });
  store.dispatch(SetLanguagesAction(homeModel.languages));
  store.dispatch(SetBookNamesAction(homeModel.bookNames));
  next(action);
};

final updateThemeMiddleware = (
  Store<AppState> store,
  SetThemeAction action,
  NextDispatcher next,
) {
  homeModel.updateTheme(action.isDarkTheme);
  next(action);
};

final updateSearchesMiddleware = (
  Store<AppState> store,
  SetSearchHistoryAction action,
  NextDispatcher next,
) {
  homeModel.updateSearchHistory(action.searchQueries);
  next(action);
};

final initFilterMiddleware = (
  Store<AppState> store,
  InitFilterAction action,
  NextDispatcher next,
) {
  filterModel.loadTranslations().then((translations) {
    var tl = filterModel.loadLanguagePref(translations, store.state.languages);
    store.dispatch(SetTranslationsAction(tl[0]));
    store.dispatch(SetLanguagesAction(tl[1]));
  });
  next(action);
};

final updateTranslationsMiddleware = (
  Store<AppState> store,
  UpdateTranslationsAction action,
  NextDispatcher next,
) {
  filterModel.updateTranslations(store.state.translations).then((translations) {
    store.dispatch(SetTranslationsAction(translations));
    store.dispatch(SearchAction(store.state.searchQuery));
  });
  next(action);
};

final selectionMiddleware = (
  Store<AppState> store,
  SelectAction action,
  NextDispatcher next,
) {
  switch (action.select) {
    case Select.TRANSLATION:
      final tl = filterModel.chooseTranslation(action.toggle, action.index,
          store.state.translations, store.state.languages);
      store.dispatch(SetTranslationsAction(tl[0]));
      store.dispatch(SetLanguagesAction(tl[1]));
      store.dispatch(UpdateTranslationsAction());
      break;
    case Select.BOOK:
      var bon = filterModel.chooseBook(
          b: action.toggle,
          i: action.index,
          bookNames: store.state.books,
          otSelected: store.state.otSelected,
          ntSelected: store.state.ntSelected);
      final books = bon[0];
      store.dispatch(SetTestamentAction(bon[1], Test.OT));
      store.dispatch(SetTestamentAction(bon[2], Test.NT));
      store.dispatch(SetBookNamesAction(books));
      store.dispatch(SetFilteredResultsAction(filterModel.filterByBook(store.state.results, books)));
      break;
    case Select.LANGUAGE:
      final tl = filterModel.selectLang(store.state.languages[action.index],
          action.toggle, store.state.translations, store.state.languages);
      store.dispatch(SetTranslationsAction(tl[0]));
      store.dispatch(SetLanguagesAction(tl[1]));
      store.dispatch(UpdateTranslationsAction());
      break;
    case Select.RESULT:
      var results = store.state.results;
      results[action.index].isSelected = action.toggle;
      store.dispatch(SetResultsAction(results));
      var numSelected = store.state.numSelected;
      action.toggle ? ++numSelected : --numSelected;
      numSelected == 0
          ? store.dispatch(SetSelectionModeAction())
          : store.dispatch(SetNumSelectedAction(numSelected));
      break;
  }
  next(action);
};

final List<Middleware<AppState>> middleware = [
  TypedMiddleware<AppState, SearchAction>(searchMiddleware),
  TypedMiddleware<AppState, InitHomeAction>(initHomeMiddleware),
  TypedMiddleware<AppState, SetThemeAction>(updateThemeMiddleware),
  TypedMiddleware<AppState, SetSearchHistoryAction>(updateSearchesMiddleware),
  TypedMiddleware<AppState, InitFilterAction>(initFilterMiddleware),
  TypedMiddleware<AppState, UpdateTranslationsAction>(
      updateTranslationsMiddleware),
  TypedMiddleware<AppState, SelectAction>(selectionMiddleware),
  TypedMiddleware<AppState, ContextAction>(contextMiddleware),
];
