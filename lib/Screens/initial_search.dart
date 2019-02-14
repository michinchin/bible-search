import 'package:flutter/material.dart';
import '../UI/extended_appbar.dart';
import '../UI/gradient_overlay_image.dart';
import '../UI/search_bar.dart';
import '../Model/votd_image.dart';
import '../Screens/results_page.dart';
import '../Screens/translation_book_filter.dart';
import '../Model/singleton.dart';
import '../Model/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _grabTranslations();
    _loadSearchHistory();
    searchController.addListener(_printLatestValue);
  }
  _printLatestValue() {
    setState(() {
      _searchTerm = searchController.text;
    });
    print('Search field input: $_searchTerm');
  }

  _loadSearchHistory() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        searchQueries = (prefs.getStringList('searchHistory') ?? []);
      });
  }

  _updateSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('searchHistory', searchQueries = searchQueries.toSet().toList());
  }

  _grabTranslations() async {
    final temp = await BibleTranslations.fetch();
    temp.data.sort((f,k)=>f.lang.id.compareTo(k.lang.id));
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      translationIds = prefs.getString('translations') ?? prefs.setString('translations', temp.formatIds());
      //select only translations that are in the formatted Id 
      translations = temp;
      translations.selectTranslations(translationIds);
     });
  }
  
  Widget _buildSearchHistoryWidgets() {

      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final words = searchQueries.reversed.toList();
          return ListTileTheme(
          textColor: Colors.black,
          iconColor: Colors.black,
          child: Dismissible(
            key: Key(words[index]),
            onDismissed: (direction){
                Scaffold.of(context).showSnackBar(SnackBar(content:Text('The search term "${words[index]}" has been removed')));
                setState(() {
                  searchQueries.removeWhere((w)=>(w == words[index]));  
                  _updateSearchHistory();
                });
            },
            background: Container(
              color: Colors.red,
            ),
            child: ListTile(
              title: Text('${words[index]}',),
              // subtitle: Text('${dates[index]}'),
              leading: Icon(Icons.access_time),
              onTap: () => _navigateToResults(context, words[index]),
            ),
          ),
          );
        },
        itemCount: searchQueries.length,
      );
    }

  void _navigateToResults(BuildContext context, String keywords) {
    // searchQueries[keywords] = '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}';
    searchQueries.add(keywords);
    _updateSearchHistory();
    searchController.text = keywords;
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return ResultsPage(
          keywords: keywords, 
          searchController: searchController,
          updateSearchHistory: _updateSearchHistory,
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
    // final _categoryList = <Dismissible>[];

    // searchQueries.forEach((k,v){
    //   _categoryList.add(
    //     Dismissible(
    //       child: ListTile(
    //         title: Text('$k',),
    //         subtitle: Text('$v'),
    //         leading: Icon(Icons.access_time),
            
    //         onTap: () => _navigateToResults(context, k),
    //       ),
    //     ),
    //   );
    // });
    //TODO: Create a list view of the Categories
    final searchHistoryList = Container(
      color: Colors.white,
      child: _buildSearchHistoryWidgets(),
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


