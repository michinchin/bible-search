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
        converter: FilterViewModel.fromStore,
        builder: (context, vm) {
          List<Widget> _getChildren(Language lang) {
            final _translationList = <Widget>[];
            final translations = vm.translations.data
                .where((t) => t.lang.id == lang.id)
                .toList();
            for (var i = 0; i < translations.length; i++) {
              _translationList.add(Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: CheckboxListTile(
                  checkColor: Theme.of(context).brightness == Brightness.dark
                      ? ThemeData.dark().cardColor
                      : null,
                  onChanged: (b) => vm.selectTranslation(
                      b, vm.translations.data.indexOf(translations[i])),
                  value: translations[i].isSelected,
                  title: Text(translations[i].a),
                  subtitle: Text('${translations[i].name}'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ));
            }
            return _translationList;
          }

          List<Widget> _createLanguageList() {
            final _languageList = <Widget>[];
            for (var i = 0; i < vm.languages.length; i++) {
              final lang = vm.languages[i];
              _languageList.add(ExpandableCheckboxListTile(
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeData.dark().cardColor
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (b) {
                  vm.selectLanguage(b, i);
                },
                value: lang.isSelected,
                title: Text(
                  lang.name,
                  style: Theme.of(context).textTheme.title,
                ),
                children: _getChildren(lang),
                initiallyExpanded: lang.a == 'en',
              ));
            }
            return _languageList;
          }

          List<Widget> _getBookChildren(bool isOT) {
            final _bookList = <Widget>[];

            for (var i = isOT ? 0 : 39;
                i < (isOT ? 39 : vm.bookNames.length);
                i++) {
              _bookList.add(ChoiceChip(
                shape: StadiumBorder(
                    side: BorderSide(
                        color: vm.bookNames[i].isSelected
                            ? Theme.of(context).accentColor
                            : Colors.black12)),
                selectedColor: Theme.of(context).cardColor,
                label: Text(
                  vm.bookNames[i].name,
                  style: TextStyle(
                      fontSize: 12.0,
                      color: vm.bookNames[i].isSelected
                          ? Theme.of(context).accentColor
                          : Colors.black45,
                      fontWeight: vm.bookNames[i].isSelected
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
                backgroundColor: vm.bookNames[i].isSelected
                    ? Theme.of(context).cardColor
                    : Theme.of(context).cardColor,
                onSelected: (b) => vm.selectBook(b, i),
                selected: vm.bookNames[i].isSelected,
              ));
            }
            return [
              Wrap(
                  spacing: 5.0,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  verticalDirection: VerticalDirection.down,
                  children: _bookList)
            ];
          }

          List<Widget> _createBookList() {
            final _bookList = <Widget>[
              ExpandableCheckboxListTile(
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeData.dark().cardColor
                    : null,
                initiallyExpanded: true,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (b) {
                  vm.selectBook(b, -2);
                },
                value: vm.otSelected,
                title: Text(
                  'Old Testament',
                  style: Theme.of(context).textTheme.title,
                ),
                children: _getBookChildren(true),
              ),
              ExpandableCheckboxListTile(
                initiallyExpanded: true,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ThemeData.dark().cardColor
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (b) {
                  vm.selectBook(b, -1);
                },
                value: vm.ntSelected,
                title: Text(
                  'New Testament',
                  style: Theme.of(context).textTheme.title,
                ),
                children: _getBookChildren(false),
              )
            ];
            return _bookList;
          }

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
                      child: ListView(
                        children: tab.text == 'BOOK'
                            ? _createBookList()
                            : _createLanguageList(),
                      ));
                }).toList(),
              ),
            ),
          );
        });
  }
}

class FilterViewModel {
  final BibleTranslations translations;
  final Function(bool, int) selectTranslation;
  final List<Language> languages;
  final Function(bool, int) selectLanguage;
  final List<Book> bookNames;
  final Function(bool, int) selectBook;
  final bool otSelected;
  final bool ntSelected;
  final Function() updateSearch;

  const FilterViewModel({
    this.translations,
    this.selectTranslation,
    this.languages,
    this.selectLanguage,
    this.bookNames,
    this.selectBook,
    this.otSelected,
    this.ntSelected,
    this.updateSearch,
  });

  static FilterViewModel fromStore(Store<AppState> store) {
    return FilterViewModel(
      translations: store.state.translations,
      selectTranslation: (b, i) =>
          store.dispatch(SelectAction(i, Select.translation, toggle: b)),
      languages: store.state.languages,
      selectLanguage: (b, i) =>
          store.dispatch(SelectAction(i, Select.language, toggle: b)),
      bookNames: store.state.books,
      selectBook: (b, i) =>
          store.dispatch(SelectAction(i, Select.book, toggle: b)),
      otSelected: store.state.otSelected,
      ntSelected: store.state.ntSelected,
      updateSearch: () => store.dispatch(SearchAction(store.state.searchQuery)),
    );
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
