import 'package:flutter/material.dart';

// class TranslationBookFilter extends StatefulWidget {
//   @override
//   _TranslationBookFilterState createState() => _TranslationBookFilterState();
// }

// class _TranslationBookFilterState extends State<TranslationBookFilter> {
//   @override
//   Widget build(BuildContext context) {
//     return TabBarCo
//   }
// }

class TranslationBookFilterPage extends StatefulWidget {
  const TranslationBookFilterPage({ Key key }) : super(key: key);
  @override
  _TranslationBookFilterPageState createState() => _TranslationBookFilterPageState();
}

class _TranslationBookFilterPageState extends State<TranslationBookFilterPage> with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'BOOK'),
    Tab(text: 'TRANSLATION'),
  ];

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
          return Center(child: Text(tab.text));
        }).toList(),
      ),
    );
  }
}