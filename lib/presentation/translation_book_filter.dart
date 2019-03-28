import 'package:bible_search/data/book.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/redux/actions.dart';
import 'package:flutter/material.dart';
import 'package:bible_search/data/translation.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

class TranslationBookFilterPage extends StatelessWidget {
  final int tabValue;

  TranslationBookFilterPage({Key key, this.tabValue}) : super(key: key);

  final List<Tab> tabs = <Tab>[
    Tab(text: 'BOOK'),
    Tab(text: 'TRANSLATION'),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FilterViewModel>(converter: (store) {
      return FilterViewModel.fromStore(store);
    }, builder: (BuildContext context, FilterViewModel vm) {
      List<Widget> _createTranslationList() {
        var _translationList = <Widget>[];

        for (var i = 0; i < vm.translations.data.length; i++) {
          _translationList.add(CheckboxListTile(
            onChanged: (bool b) => vm.selectTranslation(b, i),
            value: vm.translations.data[i].isSelected,
            title: Text(vm.translations.data[i].a),
            subtitle: Text('${vm.translations.data[i].name}'),
            controlAffinity: ListTileControlAffinity.leading,
          ));
        }

        for (var i = vm.languages.length - 1; i >= 0; i--) {
          final lang = vm.languages[i];
          _translationList.insert(
              vm.translations.data.indexOf(vm.translations.data
                  .firstWhere((test) => test.lang.a == lang.a)),
              SwitchListTile(
                onChanged: (bool b) {
                  vm.selectLanguage(b, i);
                },
                value: lang.isSelected,
                title: Text(lang.name),
                secondary: Icon(Icons.library_books),
              ));
        }
        return _translationList;
      }

      Widget _buildTranslationWidgets() {
        return Container(
            padding: EdgeInsets.all(10.0),
            child: ListView(
              children: _createTranslationList(),
            ));
      }

      List<Widget> _createBookList({bool isOT}) {
        var _bookList = <Widget>[];
        var isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;
        _bookList.add(isOT
            ? SwitchListTile(
                onChanged: (bool b) {
                  vm.selectBook(b, -2);
                },
                value: vm.otSelected,
                title: Text(isPortrait ? 'OT' : 'Old Testament'),
                secondary: Icon(Icons.library_books),
              )
            : SwitchListTile(
                onChanged: (bool b) {
                  vm.selectBook(b, -1);
                },
                value: vm.ntSelected,
                title: Text(isPortrait ? 'NT' : 'New Testament'),
                secondary: Icon(Icons.library_books),
              ));

        for (var i = isOT ? 0 : 39;
            i < (isOT ? 39 : vm.bookNames.length);
            i++) {
          _bookList.add(CheckboxListTile(
            onChanged: (bool b) => vm.selectBook(b, i),
            value: vm.bookNames[i].isSelected,
            title: Text(vm.bookNames[i].name),
            controlAffinity: ListTileControlAffinity.leading,
          ));
        }
        return _bookList;
      }

      return DefaultTabController(
        initialIndex: tabValue,
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: GestureDetector(
                onVerticalDragDown: Navigator.of(context).pop,
                child: Text("Filter")),
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
            children: tabs.map((Tab tab) {
              if (tab.text == "BOOK") {
                return Container(
                  child: Row(children: [
                    Container(
                      key: PageStorageKey(tab.text + 'OT'),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width / 2,
                      child: ListView(
                        children: _createBookList(isOT: true),
                      ),
                    ),
                    Container(
                      key: PageStorageKey(tab.text + 'NT'),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width / 2,
                      child: ListView(
                        children: _createBookList(isOT: false),
                      ),
                    ),
                  ]),
                );
              } else {
                return Container(
                  key: PageStorageKey(tab.text),
                  child: _buildTranslationWidgets(),
                );
              }
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
          store.dispatch(SelectAction(b, i, Select.TRANSLATION)),
      languages: store.state.languages,
      selectLanguage: (b, i) =>
          store.dispatch(SelectAction(b, i, Select.LANGUAGE)),
      bookNames: store.state.books,
      selectBook: (b, i) => store.dispatch(SelectAction(b, i, Select.BOOK)),
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
