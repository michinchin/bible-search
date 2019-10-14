import 'dart:io';

import 'package:bible_search/containers/initial_search_components/home_drawer.dart';
import 'package:bible_search/containers/sr_components.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/models/search_model.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/translation.dart';

import 'package:bible_search/models/app_state.dart';

import 'package:bible_search/redux/actions.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({Key key}) : super(key: key);

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  @override
  void initState() {
    final numSearches =
        tec.Prefs.shared.getInt(numSearchesPref, defaultValue: 0);

    if (tec.Prefs.shared.getBool(firstTimeOpenedPref, defaultValue: true)) {
      WidgetsBinding.instance.addPostFrameCallback(
          (duration) => Future.delayed(const Duration(seconds: 1), () {
                FeatureDiscovery.discoverFeatures(
                  context,
                  <String>{'selection_mode', 'filter', 'context', 'open_in_TB'},
                );
              }));
      tec.Prefs.shared.setBool(firstTimeOpenedPref, false);
    } else if (numSearches == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: const Text(
                  'This is an ad supported app.',
                  textAlign: TextAlign.center,
                ),
                content: const Text(
                    'You will occasionally see an ad. You may remove ads '
                    'from the menu.\n\nThanks for your support!'),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Ok')),
                ],
              );
            });
      });

      tec.Prefs.shared
          .setString(lastTimeAdShownPref, DateTime.now().toIso8601String());
    }

    tec.Prefs.shared.setInt(numSearchesPref, numSearches + 1);

    super.initState();
  }

  void _showSearch(ResultsViewModel vm) {
    showSearch<String>(
      query: vm.searchQuery,
      context: context,
      delegate: BibleSearchDelegate(
        searchHistory: vm.searchHistory,
        search: vm.updateSearchResults,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //on translation change, the view should reload
    print('rebuilt ${DateTime.now().second}');

    return StoreConnector<AppState, ResultsViewModel>(
        distinct: true,
        converter: (store) => ResultsViewModel(store),
        builder: (context, vm) {
          return Scaffold(
              resizeToAvoidBottomInset: false,
              drawer: const HomeDrawer(
                isResultPage: true,
              ),
              appBar: SearchAppBar(
                model: vm,
                showSearch: () => _showSearch(vm),
              ),
              body: WillPopScope(
                  onWillPop: () => Future.value(Platform.isAndroid),
                  child: vm.isFetchingSearch
                      ? LoadingView()
                      : vm.filteredRes.isEmpty
                          ? NoResultsView(
                              hasError: vm.hasError,
                              hasNoTranslations: vm.hasNoTranslationsSelected,
                              books: vm.bookNames,
                              resultLength: vm.searchResults.length,
                              resetFilter: vm.resetFilter,
                            )
                          : CardView(vm)));
        });
  }
}

class ResultsViewModel {
  final Store<AppState> store;
  String searchQuery;
  List<SearchResult> searchResults;
  List<SearchResult> filteredRes;
  List<String> searchHistory;

  BibleTranslations translations;
  List<Book> bookNames;
  bool isInSelectionMode;
  int numSelected;
  bool isFetchingSearch;
  bool isDarkTheme;
  bool hasError;
  bool hasNoTranslationsSelected;

  VoidCallback changeToSelectionMode;
  Function(String) updateSearchResults;
  Function(int, bool) selectCard;
  ShareVerse Function() getShareVerse;
  Function(bool) changeTheme;
  VoidCallback resetFilter;

  ResultsViewModel(this.store) {
    searchQuery = store.state.searchQuery;
    searchResults = store.state.results;
    searchHistory = store.state.searchHistory;
    translations = store.state.translations;
    bookNames = store.state.books;
    numSelected = store.state.numSelected;
    isFetchingSearch = store.state.isFetchingSearch;
    isDarkTheme = store.state.isDarkTheme;
    hasError = store.state.hasError;
    hasNoTranslationsSelected = store.state.hasNoTranslationsSelected;
    isInSelectionMode = store.state.isInSelectionMode;
    changeToSelectionMode = () => store.dispatch(SetSelectionModeAction());
    updateSearchResults = (s) => store.dispatch(SearchAction(s));
    selectCard =
        (idx, b) => store.dispatch(SelectAction(idx, Select.result, toggle: b));
    getShareVerse = () =>
        ShareVerse(books: store.state.books, results: store.state.results);
    changeTheme = (b) => store.dispatch(SetThemeAction(isDarkTheme: b));
    filteredRes = store.state.filteredResults;
    resetFilter = _resetFilter;
  }

  void _resetFilter() {
    final books = List<Book>.from(bookNames)
      ..map((b) {
        b.isSelected = true;
        return b;
      }).toList();
    store
      ..dispatch(SetBookNamesAction(books))
      ..dispatch(SearchAction(searchQuery));
  }

  @override
  bool operator ==(dynamic other) =>
      searchQuery == other.searchQuery &&
      translations == other.translations &&
      bookNames == other.bookNames &&
      isFetchingSearch == isFetchingSearch &&
      numSelected == other.numSelected &&
      isInSelectionMode == other.isInSelectionMode &&
      numSelected == other.numSelected &&
      isDarkTheme == other.isDarkTheme &&
      filteredRes == other.filteredRes &&
      searchHistory == other.searchHistory &&
      hasError == other.hasError &&
      hasNoTranslationsSelected == other.hasNoTranslationsSelected;

  @override
  int get hashCode =>
      searchQuery.hashCode ^
      translations.hashCode ^
      bookNames.hashCode ^
      isFetchingSearch.hashCode ^
      isInSelectionMode.hashCode ^
      numSelected.hashCode ^
      isDarkTheme.hashCode ^
      filteredRes.hashCode ^
      searchHistory.hashCode;
}
