import 'package:flutter/material.dart';
import '../UI/extended_appbar.dart';
import '../UI/gradient_overlay_image.dart';
import '../UI/search_bar.dart';
import '../Model/votd_image.dart';
import '../Screens/results_page.dart';
import '../Model/search_result.dart';
import '../Screens/translation_book_filter.dart';
import '../Model/singleton.dart';
import '../Model/translation.dart';

// Initial Search Route (screen)
// 
// This is the 'home' screen of the Bible Search app. It shows an app bar, a search bar,
// and a list of recent searches. 

class InitialSearchPage extends StatefulWidget {
  final Future<VOTDImage> votd;

  InitialSearchPage({Key key, this.votd}) : super(key: key);

  @override
  _InitialSearchPageState createState() => _InitialSearchPageState();
}

class _InitialSearchPageState extends State<InitialSearchPage> {
  
  final searchController = TextEditingController();
  String _searchTerm;

  static const _searchHistoryExamples = <String>[
    'Length',
    'Area',
    'Volume',
    'Mass',
    'Time',
    'Digital Storage',
    'Energy',
    'Currency',
    ];

  @override
  void initState() {
    super.initState();
    _grabTranslations();
    searchController.addListener(_printLatestValue);
  }

  // @override
  // void dispose() {
  //   searchController.dispose();
  //   super.dispose();
  // }

  _printLatestValue() {
    setState(() {
      _searchTerm = searchController.text;
    });
    print('Search field input: $_searchTerm');
  }

  _grabTranslations() async {
    final test = await BibleTranslations.fetch();
    setState(() {
      translations = test;
    });
  }
  
  Widget _buildSearchHistoryWidgets(List<ListTile> searchHistory) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTileTheme(
          textColor: Colors.black,
          iconColor: Colors.black,
          child: searchHistory[index]);
        },
        itemCount: searchHistory.length,
      );
    }

  void _navigateToResults(BuildContext context, String keywords) {
    searchResults = SearchResults.fetch(keywords, translations);
    searchQueries[keywords] = '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}';
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return ResultsPage(
          keywords: keywords, 
          searchController: searchController,
        );
      },
    ));
  }

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return TranslationBookFilterPage();
      },
      fullscreenDialog: true,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    final _imageWidth = MediaQuery.of(context).size.width;
    final _imageHeight = MediaQuery.of(context).size.height/3;
    final _orientation = MediaQuery.of(context).orientation;
    final _searchBarHeight = 50.0;
    final _categoryList = <ListTile>[];

    searchQueries.forEach((k,v){
      _categoryList.add(
        ListTile(
          title: Text('$k',),
          subtitle: Text('$v'),
          leading: Icon(Icons.access_time),
          
          onTap: () => print('$k'),
        ),
      );
    });
    //TODO: Create a list view of the Categories
    final searchHistoryList = Container(
      color: Colors.white,
      child: _buildSearchHistoryWidgets(_categoryList),
    );

    final gradientAppBarImage = GradientOverlayImage(
      width: _imageWidth,
      height: _imageHeight,
      votd: widget.votd,
      topColor: Colors.black,
      bottomColor: Colors.transparent,
    );

    final searchBox = SearchBar(
      orientation: _orientation,
      height: _searchBarHeight,
      imageHeight: _imageHeight,
      controller: searchController,
      navigation: _navigateToResults,
    );

    final title = Container(
      padding: EdgeInsets.only(
        left: 20.0,
        top: _searchBarHeight/4,
      ),
      color: Colors.transparent,
      child: Text(
        'SEARCH HISTORY',
        style: TextStyle(
          color: Colors.grey[800],
          fontFamily: 'Roboto',
          fontSize: 18.0,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    final seachHistoryListWithTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        title,    
        Expanded(child: searchHistoryList),
      ],
    );

    final ps = Size.fromHeight(_orientation == Orientation.portrait ? _imageHeight : _imageHeight+_searchBarHeight/2);
    final appBar = PreferredSize(

      preferredSize: ps,
      child: Stack(children: <Widget>[
        gradientAppBarImage,
        ExtendedAppBar(height: _imageHeight, navigate: _navigateToFilter,),
        searchBox,
      ],)
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: Stack(
        children: [     
          SafeArea(
            child: seachHistoryListWithTitle,
          ),
        ],
      ),
    );
  }
}


