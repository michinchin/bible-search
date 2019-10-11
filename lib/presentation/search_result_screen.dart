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
    var num_searches = tec.Prefs.shared.getInt(
        numSearchesPref, defaultValue: 0);

    if (tec.Prefs.shared.getBool(firstTimeOpenedPref, defaultValue: true)) {
      WidgetsBinding.instance.addPostFrameCallback(
          (duration) => Future.delayed(const Duration(seconds: 1), () {
                FeatureDiscovery.discoverFeatures(
                  context,
                  <String>{'selection_mode', 'filter', 'context', 'open_in_TB'},
                );
              }));
      tec.Prefs.shared.setBool(firstTimeOpenedPref, false);
    }
    else if (num_searches == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: const Text(
                    'This is an ad supported app.\n\nYou will occasionally see an ad. You may remove ads from the menu.\n\nThanks for your support!',
                  textAlign: TextAlign.center,
                ),
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

    tec.Prefs.shared.setInt(numSearchesPref, num_searches + 1);

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
        converter: ResultsViewModel.fromStore,
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
                  onWillPop: () => Future.value(false),
                  child: vm.state.isFetchingSearch
                      ? LoadingView()
                      : vm.filteredRes.isEmpty
                          ? NoResultsView(
                              hasError: vm.state.hasError,
                              hasNoTranslations:
                                  vm.state.hasNoTranslationsSelected,
                            )
                          : CardView(vm)));
        });
  }
}

class ResultsViewModel {
  final AppState state;
  final String searchQuery;
  final List<SearchResult> searchResults;
  final List<SearchResult> filteredRes;
  final List<String> searchHistory;

  final BibleTranslations translations;
  final List<Book> bookNames;
  final bool isInSelectionMode;

  final VoidCallback changeToSelectionMode;
  final Function(String) updateSearchResults;
  final Function(int, bool) selectCard;
  final ShareVerse Function() getShareVerse;
  final Function(bool) changeTheme;

  const ResultsViewModel({
    this.state,
    this.searchQuery,
    this.searchResults,
    this.searchHistory,
    this.translations,
    this.bookNames,
    this.isInSelectionMode,
    this.changeToSelectionMode,
    this.updateSearchResults,
    this.filteredRes,
    this.selectCard,
    this.getShareVerse,
    this.changeTheme,
  });

  static ResultsViewModel fromStore(Store<AppState> store) {
    return ResultsViewModel(
      state: store.state,
      searchQuery: store.state.searchQuery,
      searchResults: store.state.results,
      searchHistory: store.state.searchHistory,
      translations: store.state.translations,
      bookNames: store.state.books,
      isInSelectionMode: store.state.isInSelectionMode,
      changeToSelectionMode: () => store.dispatch(SetSelectionModeAction()),
      updateSearchResults: (s) => store.dispatch(SearchAction(s)),
      selectCard: (idx, b) =>
          store.dispatch(SelectAction(idx, Select.result, toggle: b)),
      getShareVerse: () =>
          ShareVerse(books: store.state.books, results: store.state.results),
      changeTheme: (b) => store.dispatch(SetThemeAction(isDarkTheme: b)),
      filteredRes: store.state.filteredResults,
    );
  }

  @override
  bool operator ==(dynamic other) =>
      searchQuery == other.searchQuery &&
      translations == other.translations &&
      bookNames == other.bookNames &&
      state.isFetchingSearch == other.state.isFetchingSearch &&
      isInSelectionMode == other.isInSelectionMode &&
      state.numSelected == other.state.numSelected &&
      state.isDarkTheme == other.state.isDarkTheme &&
      filteredRes == other.filteredRes &&
      searchHistory == other.searchHistory;

  @override
  int get hashCode =>
      searchQuery.hashCode ^
      translations.hashCode ^
      bookNames.hashCode ^
      state.isFetchingSearch.hashCode ^
      isInSelectionMode.hashCode ^
      state.numSelected.hashCode ^
      state.isDarkTheme.hashCode ^
      filteredRes.hashCode ^
      searchHistory.hashCode;
}
