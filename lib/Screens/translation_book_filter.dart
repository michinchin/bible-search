import 'package:flutter/material.dart';
import '../Model/translation.dart';

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
              child: Center(child:Text('Book')),
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
  
            // CheckboxListTile(
            //   onChanged: (bool b){
            //     setState(() {
            //       checked = b;
            //     });
            //   },
            //   value: checked,
            //   title: Text(tab.text),
            // ),
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
          child: ListTile(
            title: Text(t.data[index].name),
          ),
          // return filter == null || filter == "" ? searchHistory[index] : (searchHistory[index].title as Text).data.contains(filter) ? searchHistory[index] : new ListTile();
          //TODO: If you want the list builder to rebuild the list of list tiles, 
          // rather than showing the results in place, make _categoryList a list of strings
          // of the titles and build each tile in the list view 
          // https://medium.com/@thedome6/how-to-create-a-searchable-filterable-listview-in-flutter-4faf3e300477
          );
        },
        itemCount: t.data.length,
      );
  }

  Widget _buildNoResults() {
    return Center(child: Text("No results ☹️", style: Theme.of(context).textTheme.title,),);
  }

}

