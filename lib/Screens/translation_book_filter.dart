import 'package:flutter/material.dart';
import '../Model/translation.dart';
import '../Model/singleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationBookFilterPage extends StatefulWidget {
  final int tabValue;
  final VoidCallback updateTranslations;

  const TranslationBookFilterPage({Key key, this.tabValue, this.updateTranslations}) : super(key: key);
  @override
  _TranslationBookFilterPageState createState() =>
      _TranslationBookFilterPageState();
}

class _TranslationBookFilterPageState extends State<TranslationBookFilterPage>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'BOOK'),
    Tab(text: 'TRANSLATION'),
  ];

  bool checked = false;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _tabController.animateTo(widget.tabValue);
     _grabTranslations();
    _updateTranslations();
    _loadLanguagePref();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // _updateTranslations();
    super.dispose();
  }

  _loadLanguagePref(){
    if (translations != null) {
      for (final each in translations.data) {
        if (!each.isSelected) {
          each.lang.isSelected = false;
        }
      }
    }
  }


  _grabTranslations() async {
    final temp = await BibleTranslations.fetch();
    temp.data.sort((f,k)=>f.lang.id.compareTo(k.lang.id));
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString('translations') == null) {
        prefs.setString('translations', temp.formatIds());
      } 
      translationIds = prefs.getString('translations');
      //select only translations that are in the formatted Id 
      translations = temp;
      translations.selectTranslations(translationIds);
     });
  }
  

  _updateTranslations() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('translations', translationIds = translations.formatIds());
    widget.updateTranslations();
  }

  List<Widget> _createTranslationList() {
    var _translationList = <Widget>[];
    for (var i = 0; i < translations.data.length; i++) {
      _translationList.add(CheckboxListTile(
        onChanged: (bool b) {
          setState(() {
            translations.data[i].isSelected = b;
            if (!b) {translations.data[i].lang.isSelected = b;}
            _updateTranslations();
          });
        },
        value: translations.data[i].isSelected,
        title: Text(translations.data[i].a),
        subtitle: Text('${translations.data[i].name}'),
        controlAffinity: ListTileControlAffinity.leading,
      ));
    }

    for (var i = languages.length -1; i >= 0; i--){
      final lang = languages[i];
      _translationList.insert(translations.data
            .indexOf(translations.data.firstWhere((test) => test.lang.a == lang.a)), 
        SwitchListTile(
          onChanged: (bool b) {
            _selectLang(lang,b);
          },
          value: lang.isSelected,
          title: Text(lang.name),
          secondary: Icon(Icons.library_books),
        )
      );
    }

    return _translationList;
  }

  _selectLang(Language lang, bool b){
    translations.data.forEach((each) {
      if (each.lang == lang) {
        each.isSelected = b;
      }
    });
    _updateTranslations();
    setState(() {
      lang.isSelected = b;
    });
  }

  List<Widget> _createBookList() {
    var _bookList = <Widget>[];

    for (var i = 0; i < bookNames.length; i++) {
      _bookList.add(
        CheckboxListTile(
          onChanged: (bool b) {
            setState(() {
              bookNames[i].isSelected = b;
              if (!b) {bookNames[i].isOT() ? otSelected = b : ntSelected = b;}
            });
          },
          value: bookNames[i].isSelected,
          title: Text(bookNames[i].name),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      );
    }
    //Old Testament Filter
    _bookList.insert(
      0,
      SwitchListTile(
        onChanged: (bool b) {
          _selectOT(b);
        },
        value: otSelected,
        title: Text('Old Testament'),
        secondary: Icon(Icons.library_books),
      ),
    );

    //New Testament Filter
    _bookList.insert(
      40,
      SwitchListTile(
        onChanged: (bool b) {
          _selectNT(b);
        },
        value: ntSelected,
        title: Text('New Testament'),
        secondary: Icon(Icons.library_books),
      ),
    );
    return _bookList;
  }

  _selectOT(bool b) {
    bookNames.forEach((each) {
      if (each.isOT()) {
        each.isSelected = b;
      }
    });
    setState(() {
      otSelected = b;
    });
  }

  _selectNT(bool b) {
    bookNames.forEach((each) {
      if (!each.isOT()) {
        each.isSelected = b;
      }
    });
    setState(() {
      ntSelected = b;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          if (tab.text == "BOOK") {
            return Container(
              key: PageStorageKey(tab.text),
              child: _buildBookWidgets(),
            );
          } else {
            return Container(
              key: PageStorageKey(tab.text),
              child: _buildTranslationWidgets(),
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _buildTranslationWidgets() {
    searchResults = [];
    return Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: _createTranslationList(),
        )
    );
  }

  Widget _buildBookWidgets() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: ListView(
        children: _createBookList(),
      ),
    );
  }
}
