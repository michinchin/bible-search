import 'package:bible_search/Model/search_model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class TranslationBookFilterPage extends StatelessWidget {
  final int tabValue;
  final VoidCallback updateTranslations;

  TranslationBookFilterPage({Key key, this.tabValue, this.updateTranslations})
      : super(key: key);

  final List<Tab> tabs = <Tab>[
    Tab(text: 'BOOK'),
    Tab(text: 'TRANSLATION'),
  ];

  bool checked = false;
  SearchModel model;
  List translations;
  List languages;

  @override
  Widget build(BuildContext context) {
    model = SearchModel.of(context);
    translations = model.translations.data;
    languages = model.languages;

    List<Widget> _createTranslationList() {
      var _translationList = <Widget>[];
      for (var i = 0; i < translations.length; i++) {
        _translationList.add(ScopedModelDescendant<SearchModel>(
            builder: (BuildContext context, Widget child, SearchModel model) {
          return CheckboxListTile(
            onChanged: (bool b) => model.chooseTranslation(b,i),
            value: translations[i].isSelected,
            title: Text(translations[i].a),
            subtitle: Text('${translations[i].name}'),
            controlAffinity: ListTileControlAffinity.leading,
          );
        }));
      }

      for (var i = languages.length - 1; i >= 0; i--) {
        final lang = languages[i];
        _translationList.insert(
            translations.indexOf(
                translations.firstWhere((test) => test.lang.a == lang.a)),
            ScopedModelDescendant<SearchModel>(builder:
                (BuildContext context, Widget child, SearchModel model) {
          return SwitchListTile(
            onChanged: (bool b) {
              model.selectLang(lang, b);
            },
            value: lang.isSelected,
            title: Text(lang.name),
            secondary: Icon(Icons.library_books),
          );
        }));
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
          ? ScopedModelDescendant<SearchModel>(
              builder: (BuildContext context, Widget child, SearchModel model) {
              return SwitchListTile(
                onChanged: (bool b) {
                  model.selectOT(b);
                },
                value: model.otSelected,
                title: Text(isPortrait ? 'OT' : 'Old Testament'),
                secondary: Icon(Icons.library_books),
              );
            })
          : ScopedModelDescendant<SearchModel>(
              builder: (BuildContext context, Widget child, SearchModel model) {
              return SwitchListTile(
                onChanged: (bool b) {
                  model.selectNT(b);
                },
                value: model.ntSelected,
                title: Text(isPortrait ? 'NT' : 'New Testament'),
                secondary: Icon(Icons.library_books),
              );
            }));

      for (var i = isOT ? 0 : 39;
          i < (isOT ? 39 : model.bookNames.length);
          i++) {
        _bookList.add(ScopedModelDescendant<SearchModel>(
            builder: (BuildContext context, Widget child, SearchModel model) {
          return CheckboxListTile(
            onChanged: (bool b) => model.chooseBook(b, i),
            value: model.bookNames[i].isSelected,
            title: Text(model.bookNames[i].name),
            controlAffinity: ListTileControlAffinity.leading,
          );
        }));
      }
      return _bookList;
    }

    return DefaultTabController(
      initialIndex: tabValue,
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Filter'),
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
  }
}
