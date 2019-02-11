import 'package:flutter/material.dart';
import '../Model/translation.dart';
import '../Model/singleton.dart';
import '../Model/search_result.dart';

class TranslationBookFilterPage extends StatefulWidget {
  final String words;

  const TranslationBookFilterPage({ Key key, this.words}) : super(key: key);
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
              key: PageStorageKey(tab.text),
              child: _buildBookWidgets(),
            );
          } else {
            return Container(
              key: PageStorageKey(tab.text),
              child: _buildTranslationView(),
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _buildTranslationView(){
    // return FutureBuilder<BibleTranslations>(
    //     future: translations,
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData && snapshot.data.data.length == 0) {
    //         return _buildNoResults();
    //       } else if (snapshot.hasData) {
    //         return _buildTranslationWidgets(snapshot.data);
    //       } 
    //       return _buildLoading();
    //     }
    // );
    return _buildTranslationWidgets(translations);
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator(),);
  }

  Widget _buildTranslationWidgets(BibleTranslations t) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTileTheme(
            child: CheckboxListTile(
              onChanged: (bool b){
                setState(() {
                  t.data[index].isSelected = b;
                });
              },
              value: t.data[index].isSelected,
              title: Text(t.data[index].a),
              subtitle: Text(t.data[index].name),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        },
        itemCount: t.data.length,
      )
    );
  }

  Widget _buildBookWidgets() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            //TODO: OT & NT checkmark
            return ListTileTheme(
              child: CheckboxListTile(
                onChanged: (bool b){
                  setState(() {
                  bookNames[index].isSelected = b;
                  });
                },
                value: bookNames[index].isSelected,
                title: Text(bookNames[index].name),
                subtitle: Text('${bookNames[index].getotnt()}'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          },
          itemCount: bookNames.length,
        ),
    );
  }

  Widget _buildNoResults() {
    return Center(child: Text("No results ☹️", style: Theme.of(context).textTheme.title,),);
  }

}

