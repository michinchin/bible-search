import 'package:bible_search/containers/sr_components.dart';
import 'package:bible_search/tec_settings.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:share/share.dart';

import 'package:tec_util/tec_util.dart' as tec;

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
  tec.TecInterstitialAd _interstitialAd;

  @override
  void initState() {
    _interstitialAd = tec.TecInterstitialAd(adUnitId: prefInterstitialAdId);
    super.initState();
  }

  @override
  void dispose() {
    _interstitialAd.show(minViewTime: Duration(seconds: 30));
    super.dispose();
  }

  Future<void> _shareSelection(
      BuildContext context, bool isCopy, String text) async {
    if (text.isNotEmpty) {
      !isCopy
          ? await Share.share(text)
          : await Clipboard.setData(ClipboardData(text: text)).then((x) {
              _showToast(context, 'Copied!');
            });
    } else {
      _showToast(context, 'Please make a selection');
    }
  }

  void _showToast(BuildContext context, String label) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).cardColor,
        content: Text(label, style: Theme.of(context).textTheme.body1),
        action: SnackBarAction(
            label: 'CLOSE', onPressed: scaffold.hideCurrentSnackBar),
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
              appBar: SearchAppBar(
                model: vm,
                shareSelection: _shareSelection,
              ),
              body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: vm.state.isFetchingSearch
                      ? LoadingView()
                      : vm.filteredRes.isEmpty
                          ? NoResultsView()
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
  final String Function() getSelectedText;
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
    this.getSelectedText,
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
      getSelectedText: () => store.state.selectedText,
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
