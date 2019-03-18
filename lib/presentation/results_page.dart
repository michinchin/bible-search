import 'package:bible_search/data/book.dart';
import 'package:bible_search/data/search_result.dart';
import 'package:bible_search/data/translation.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/containers/result_page_components.dart';
import 'package:bible_search/redux/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:share/share.dart';

class ResultsPage extends StatefulWidget {
  ResultsPage({Key key}) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  void _shareSelection(BuildContext context, bool isCopy, String text) async {
    if (text.length > 0) {
      !isCopy
          ? Share.share(text)
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

  final _loadingView = Container(
      padding: EdgeInsets.all(20.0),
      child: Stack(children: [
        ListView.builder(
          itemCount: 15,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.all(10.0),
              child: Placeholder(
                color: Theme.of(context).accentColor.withAlpha(100),
                fallbackWidth: MediaQuery.of(context).size.width - 30,
                fallbackHeight: MediaQuery.of(context).size.height / 5,
              ),
            );
          },
        ),
        Center(
          child: CircularProgressIndicator(),
        )
      ]));

  Widget _noResultsView = Container(
    padding: EdgeInsets.all(20.0),
    child: Center(
      child: Text(
        'No Results',
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    //on translation change, the view should reload
    print('rebuilt ${DateTime.now().second}');

    Widget getResultsView(ResultsViewModel vm) {
      if (vm.state.isFetchingSearch) {
        return _loadingView;
      } else if (vm.searchResults.length == 0) {
        return _noResultsView;
      } else if (!vm.state.isFetchingSearch && vm.searchResults.length > 0) {
        return CardView(vm);
      }
    }

    return StoreConnector<AppState, ResultsViewModel>(
        distinct: true,
        converter: (store) {
          return ResultsViewModel.fromStore(store);
        },
        builder: (BuildContext context, ResultsViewModel vm) {
          return Scaffold(
              appBar: SearchAppBar(
                title: vm.searchQuery,
                update: vm.updateSearchResults,
                getText: vm.getSelectedText,
                shareSelection: _shareSelection,
                numSelected: vm.state.numSelected,
                isInSelectionMode: vm.isInSelectionMode,
                changeToSelectionMode: vm.changeToSelectionMode,
              ),
              body: SafeArea(
                  child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: getResultsView(vm))));
        });
  }
}

class ResultsViewModel {
  final AppState state;
  final String searchQuery;
  final List<SearchResult> searchResults;
  final BibleTranslations translations;
  final List<Book> bookNames;
  final bool isInSelectionMode;

  final VoidCallback changeToSelectionMode;
  final Function(String) updateSearchResults;
  final VoidCallback updateTranslations;
  final Function() filterByBook;
  final Function(int, bool) selectCard;
  final String Function() getSelectedText;

  const ResultsViewModel({
    this.state,
    this.searchQuery,
    this.searchResults,
    this.translations,
    this.bookNames,
    this.isInSelectionMode,
    this.changeToSelectionMode,
    this.updateSearchResults,
    this.updateTranslations,
    this.filterByBook,
    this.selectCard,
    this.getSelectedText,
  });

  static ResultsViewModel fromStore(Store<AppState> store) {
    return ResultsViewModel(
      state: store.state,
      searchQuery: store.state.searchQuery,
      searchResults: store.state.results,
      translations: store.state.translations,
      bookNames: store.state.books,
      isInSelectionMode: store.state.isInSelectionMode,
      changeToSelectionMode: () => store.dispatch(SetSelectionModeAction()),
      updateSearchResults: (s) => store.dispatch(SearchAction(s)),
      updateTranslations: () =>
          store.dispatch(SetTranslationsAction(store.state.translations)),
      filterByBook: () => {},
      selectCard: (idx, b) =>
          store.dispatch(SelectAction(b, idx, Select.RESULT)),
      getSelectedText: () => store.state.selectedText,
    );
  }

  @override
  bool operator ==(dynamic other) =>
      searchQuery == other.searchQuery &&
      translations == other.translations &&
      bookNames == other.bookNames &&
      state.isFetchingSearch == other.state.isFetchingSearch &&
      isInSelectionMode == other.isInSelectionMode &&
      state.numSelected == other.state.numSelected;

  @override
  int get hashCode =>
      searchQuery.hashCode ^
      translations.hashCode ^
      bookNames.hashCode ^
      state.isFetchingSearch.hashCode ^
      isInSelectionMode.hashCode ^
      state.numSelected.hashCode;
}
