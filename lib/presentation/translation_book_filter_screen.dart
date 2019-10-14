import 'package:flutter/material.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:bible_search/data/book.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/data/translation.dart';

import 'package:bible_search/containers/f_components.dart';

import 'package:bible_search/redux/actions.dart';

class TranslationBookFilterScreen extends StatelessWidget {
  final int tabValue;

  TranslationBookFilterScreen({Key key, this.tabValue}) : super(key: key);

  final List<Tab> tabs = <Tab>[
    const Tab(text: 'BOOK'),
    const Tab(text: 'TRANSLATION'),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FilterViewModel>(
        converter: (store) => FilterViewModel(store),
        builder: (context, vm) {
          return DefaultTabController(
            initialIndex: tabValue,
            length: tabs.length,
            child: Scaffold(
              appBar: AppBar(
                title: GestureDetector(
                    onVerticalDragDown: Navigator.of(context).pop,
                    child: const Text('Filter')),
                bottom: TabBar(
                  tabs: tabs,
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ),
              body: TabBarView(
                children: tabs.map((tab) {
                  return Container(
                      key: PageStorageKey(tab.text),
                      padding: const EdgeInsets.all(10.0),
                      child: tab.text == 'BOOK'
                          ? BookList(vm, tabValue)
                          : LanguageList(vm));
                }).toList(),
              ),
            ),
          );
        });
  }
}

class FilterViewModel {
  final Store<AppState> store;
  BibleTranslations translations;
  Function(bool, int) selectTranslation;
  List<Language> languages;
  Function(bool, int) selectLanguage;
  List<Book> bookNames;
  Function(bool, int) selectBook;
  bool otSelected;
  bool ntSelected;
  VoidCallback updateSearch;

  FilterViewModel(this.store) {
    translations = store.state.translations;
    selectTranslation = (b, i) =>
        store.dispatch(SelectAction(i, Select.translation, toggle: b));
    languages = store.state.languages;
    selectLanguage =
        (b, i) => store.dispatch(SelectAction(i, Select.language, toggle: b));
    bookNames = store.state.books;
    selectBook =
        (b, i) => store.dispatch(SelectAction(i, Select.book, toggle: b));
    otSelected = store.state.otSelected;
    ntSelected = store.state.ntSelected;
    updateSearch = () => store.dispatch(SearchAction(store.state.searchQuery));
  }

  @override
  bool operator ==(dynamic other) =>
      translations == other.translations &&
      languages == other.languages &&
      bookNames == other.bookNames &&
      otSelected == other.otSelected &&
      ntSelected == other.ntSelected;

  @override
  int get hashCode =>
      translations.hashCode ^
      languages.hashCode ^
      bookNames.hashCode ^
      otSelected.hashCode ^
      ntSelected.hashCode;
}
