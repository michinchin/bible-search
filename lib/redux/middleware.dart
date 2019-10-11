import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/context.dart';
import 'package:bible_search/data/translation.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/models/filter_model.dart';
import 'package:bible_search/redux/actions.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:bible_search/models/home_model.dart';
import 'package:tec_ads/tec_ads.dart';

import 'package:tec_util/tec_util.dart' as tec;

final filterModel = FilterModel();
final homeModel = HomeModel();

Future<void> searchMiddleware(
  Store<AppState> store,
  SearchAction action,
  NextDispatcher next,
) async {
  TecInterstitialAd ad;

  if (homeModel.shouldShowAd) {
    ad = TecInterstitialAd(adUnitId: prefInterstitialAdId);
  }

  store.dispatch(SearchLoadingAction());
  final translationIds = store.state.translations.formatIds();
  if (translationIds.isNotEmpty) {
    final newSearchList = List<String>.from(store.state.searchHistory)
      ..add(action.searchQuery);
    store.dispatch(SetSearchHistoryAction(
        searchQuery: action.searchQuery,
        searchQueries:
            newSearchList.reversed.toSet().toList().reversed.toList()));
    final res = await SearchResults.fetch(
      words: action.searchQuery,
      translationIds: translationIds,
    ).catchError((dynamic e) {
      store..dispatch(SearchResultAction([]))..dispatch(SearchErrorAction());
      // store.dispatch(SearchErrorAction());
    });
    store
      ..dispatch(SearchResultAction(res))
      ..dispatch(SetFilteredResultsAction(
          filterModel.filterByBook(res, store.state.books)));
  } else {
    store
      ..dispatch(SearchResultAction([]))
      ..dispatch(SearchNoTranslationsAction());
  }

  showAd(ad, maxTries: 10);

  next(action);
}

void showAd(TecInterstitialAd ad, { int maxTries = 1 }) {
  if (ad != null) {
    Future.delayed(const Duration(seconds: 1), () async {
      if (await ad.isLoaded()) {
        await ad.show();
      }
      else if (maxTries > 1) {
        showAd(ad, maxTries: maxTries - 1);
      }
    });
  }
}

void contextMiddleware(
  Store<AppState> store,
  ContextAction action,
  NextDispatcher next,
) {
  final res = store.state.results[action.idx];
  if (res.verses[res.currentVerseIndex].contextText.isEmpty) {
    Context.fetch(
            translation: res.verses[res.currentVerseIndex].id,
            book: res.bookId,
            chapter: res.chapterId,
            verse: res.verseId)
        .then((context) {
      final results = store.state.results;
      results[action.idx].verses[res.currentVerseIndex].contextText =
          context.text;
      results[action.idx].verses[res.currentVerseIndex].verseIdx = [
        context.initialVerse,
        context.finalVerse
      ];
      store.dispatch(SetResultsAction(results));
    });
  }
}

/// Fetch verse of the day, init home page by loading theme and search history from user preferences, and load languages and bookNames
void initHomeMiddleware(
  Store<AppState> store,
  InitHomeAction action,
  NextDispatcher next,
) {
  // store.dispatch(ImageLoadingAction());
  // VOTDImage.fetch().then((votd) {
  //   store.dispatch(ImageResultAction(votd));
  // }).catchError((dynamic e) {
  //   store.dispatch(ImageResultAction(VOTDImage(url: 'assets/appimage.jpg')));
  // });

  homeModel.loadTheme().then((theme) {
    store.dispatch(SetThemeAction(isDarkTheme: theme));
  });
  homeModel.loadSearchHistory().then((searchHistory) {
    store.dispatch(SetSearchHistoryAction(searchQueries: searchHistory));
  });
  store
    ..dispatch(SetLanguagesAction(homeModel.languages))
    ..dispatch(SetBookNamesAction(homeModel.bookNames));
  next(action);
}

void updateStateMiddleware(
  Store<AppState> store,
  StateChangeAction action,
  NextDispatcher next,
) {
  SystemChrome.setSystemUIOverlayStyle(
      store.state.isDarkTheme ? darkOverlay : lightOverlay);
  next(action);
}

void updateThemeMiddleware(
  Store<AppState> store,
  SetThemeAction action,
  NextDispatcher next,
) {
  homeModel.updateTheme(b: action.isDarkTheme);
  next(action);
}

void updateSearchesMiddleware(
  Store<AppState> store,
  SetSearchHistoryAction action,
  NextDispatcher next,
) {
  homeModel.updateSearchHistory(action.searchQueries);
  next(action);
}

Future<void> initFilterMiddleware(
  Store<AppState> store,
  InitFilterAction action,
  NextDispatcher next,
) async {
  final translations = await filterModel.loadTranslations();
  final tl = filterModel.loadLanguagePref(translations, store.state.languages);
  final t = tec.as<BibleTranslations>(tl[0]);
  final l = tec.as<List<Language>>(tl[1]);
  store..dispatch(SetTranslationsAction(t))..dispatch(SetLanguagesAction(l));
  next(action);
}

void updateTranslationsMiddleware(
  Store<AppState> store,
  UpdateTranslationsAction action,
  NextDispatcher next,
) {
  filterModel.updateTranslations(store.state.translations).then((translations) {
    store
      ..dispatch(SetTranslationsAction(translations))
      ..dispatch(SearchAction(store.state.searchQuery));
  });
  next(action);
}

void selectionMiddleware(
  Store<AppState> store,
  SelectAction action,
  NextDispatcher next,
) {
  switch (action.select) {
    case Select.translation:
      final tl = filterModel.chooseTranslation(
        action.index,
        store.state.translations,
        store.state.languages,
        b: action.toggle,
      );
      final t = tec.as<BibleTranslations>(tl[0]);
      final l = tec.as<List<Language>>(tl[1]);
      store
        ..dispatch(SetTranslationsAction(t))
        ..dispatch(SetLanguagesAction(l))
        ..dispatch(UpdateTranslationsAction());
      break;
    case Select.book:
      final bon = filterModel.chooseBook(
          b: action.toggle,
          i: action.index,
          bookNames: store.state.books,
          otSelected: store.state.otSelected,
          ntSelected: store.state.ntSelected);
      final books = tec.as<List<Book>>(bon[0]);
      final otOn = tec.as<bool>(bon[1]);
      final ntOn = tec.as<bool>(bon[2]);
      store
        ..dispatch(SetTestamentAction(Test.oT, toggle: otOn))
        ..dispatch(SetTestamentAction(Test.nT, toggle: ntOn))
        ..dispatch(SetBookNamesAction(books))
        ..dispatch(SetFilteredResultsAction(
            filterModel.filterByBook(store.state.results, books)));
      break;
    case Select.language:
      final tl = filterModel.selectLang(store.state.languages[action.index],
          store.state.translations, store.state.languages,
          b: action.toggle);
      final t = tec.as<BibleTranslations>(tl[0]);
      final l = tec.as<List<Language>>(tl[1]);
      store
        ..dispatch(SetTranslationsAction(t))
        ..dispatch(SetLanguagesAction(l))
        ..dispatch(UpdateTranslationsAction());
      break;
    case Select.result:
      final results = store.state.results;
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
}

final List<Middleware<AppState>> middleware = [
  TypedMiddleware<AppState, SearchAction>(searchMiddleware),
  TypedMiddleware<AppState, InitHomeAction>(initHomeMiddleware),
  TypedMiddleware<AppState, SetThemeAction>(updateThemeMiddleware),
  TypedMiddleware<AppState, StateChangeAction>(updateStateMiddleware),
  TypedMiddleware<AppState, SetSearchHistoryAction>(updateSearchesMiddleware),
  TypedMiddleware<AppState, InitFilterAction>(initFilterMiddleware),
  TypedMiddleware<AppState, UpdateTranslationsAction>(
      updateTranslationsMiddleware),
  TypedMiddleware<AppState, SelectAction>(selectionMiddleware),
  TypedMiddleware<AppState, ContextAction>(contextMiddleware),
];
