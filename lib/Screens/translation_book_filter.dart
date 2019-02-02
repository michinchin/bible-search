import 'package:flutter/material.dart';
import '../Model/translation.dart';
import '../Model/book.dart';

class TranslationBookFilterPage extends StatefulWidget {
  final Future<BibleTranslations> translations;

  const TranslationBookFilterPage({ Key key, this.translations }) : super(key: key);
  @override
  _TranslationBookFilterPageState createState() => _TranslationBookFilterPageState();
}

class _TranslationBookFilterPageState extends State<TranslationBookFilterPage> with SingleTickerProviderStateMixin {
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
  }

 @override
 void dispose() {
   _tabController.dispose();
   super.dispose();
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
          onPressed: (){Navigator.pop(context);},
          icon: Icon(Icons.close),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          if (tab.text == "BOOK") {
            return Container(
              child: _buildBookWidgets(),
            );
          } else {
            return Container(
              child: _buildTranslationView(),
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _buildTranslationView(){
    return FutureBuilder<BibleTranslations>(
        future: widget.translations,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.data.length == 0) {
            return _buildNoResults();
          } else if (snapshot.hasData) {
            return _buildCenter(snapshot.data);
          } 
          return _buildLoading();
        }
    );
  }

  Widget _buildCenter(BibleTranslations data){
    return Container(
      padding: EdgeInsets.all(10),
      child: _buildTranslationWidgets(data),
    );
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator(),);
  }

  Widget _buildTranslationWidgets(BibleTranslations t) {
    
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: CheckboxListTile(
              onChanged: (bool b){setState(() {
                t.data[index].isSelected = b;
              });},
              value: t.data[index].isSelected,
              title: Text(t.data[index].name),
            ),
          );
        },
        itemCount: t.data.length,
      );
  }

  Widget _buildBookWidgets() {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: CheckboxListTile(
              onChanged: (bool b){setState(() {
                bookNames[index].isSelected = b;
              });},
              value: bookNames[index].isSelected,
              title: Text(bookNames[index].name),
            ),
          );
        },
        itemCount: bookNames.length,
      );
  }

  Widget _buildNoResults() {
    return Center(child: Text("No results ☹️", style: Theme.of(context).textTheme.title,),);
  }

}

