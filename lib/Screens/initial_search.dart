import 'package:flutter/material.dart';
import '../UI/extended_appbar.dart';
import '../UI/gradient_overlay_image.dart';
import '../UI/search_bar.dart';
import '../Services/votd_image_api.dart';

// Initial Search Route (screen)
// 
// This is the 'home' screen of the Bible Search app. It shows an app bar, a search bar,
// and a list of recent searches. 

class InitialSearchScreen extends StatefulWidget {
  InitialSearchScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _InitialSearchScreenState createState() => _InitialSearchScreenState();
}

class _InitialSearchScreenState extends State<InitialSearchScreen> {

  final searchController = TextEditingController();
  final votd = VOTDImageAPI();
  String _imageURL = 'https://cf-stream.tecartabible.com/7/votd/699.jpg';
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
    _updateURL();
    super.initState();
    searchController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  _printLatestValue() {
    setState(() {
      _searchTerm = searchController.text;
    });
    print('Search field input: ${_searchTerm}');

  }

  Future<void> _updateURL() async {
    final imageURL = await votd.getImageURL();
    setState(() {
      _imageURL = 'https://cf-stream.tecartabible.com/7/votd/$imageURL';
    });
  }
  


  Widget _buildSearchHistoryWidgets(List<ListTile> searchHistory) {
      return ListView.builder(

        itemBuilder: (BuildContext context, int index) {
          return searchHistory[index];
          // return filter == null || filter == "" ? searchHistory[index] : (searchHistory[index].title as Text).data.contains(filter) ? searchHistory[index] : new ListTile();
          //TODO: If you want the list builder to rebuild the list of list tiles, 
          // rather than showing the results in place, make _categoryList a list of strings
          // of the titles and build each tile in the list view 
          // https://medium.com/@thedome6/how-to-create-a-searchable-filterable-listview-in-flutter-4faf3e300477
        },
        itemCount: searchHistory.length,
      );
    }
  
  @override
  Widget build(BuildContext context) {
    final _imageHeight = MediaQuery.of(context).size.height/3;
    final _orientation = MediaQuery.of(context).orientation;
    final _searchBarHeight = 50.0;
    final _categoryList = <ListTile>[];

    for(int i = 0; i < _searchHistoryExamples.length; i++) {
      _categoryList.add(
        ListTile(
          title: Text('${_searchHistoryExamples[i]}'),
          subtitle: Text('data'),
          leading: Icon(Icons.access_time),
          onTap: () => print('${_searchHistoryExamples[i]}'),
        ),
      );
    }
    //TODO: Create a list view of the Categories
    final searchHistoryList = Container(
      color: Colors.white,
      child: _buildSearchHistoryWidgets(_categoryList),
    );

    final gradientAppBarImage = GradientOverlayImage(
      height: _imageHeight,
      imageURL: _imageURL,
      topColor: Colors.black,
      bottomColor: Colors.transparent,
    );

    final appBar = Container(
        height: _imageHeight,
        child: ExtendedAppBar(),
    );

    final searchBox = SearchBar(
      orientation: _orientation,
      height: _searchBarHeight,
      imageHeight: _imageHeight,
      controller: searchController,
    );

    final title = Container(
      padding: EdgeInsets.only(
        left: 20.0,
        top: _orientation == Orientation.portrait ? 15.0 : _searchBarHeight/2 + 15.0,
      ),
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

    final appBarAndList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        appBar,
        title,    
        Expanded(child: searchHistoryList),
      ],
    );

    return Scaffold(
      body:
      Stack(
        children: [     
          gradientAppBarImage,                         
          SafeArea(
            child: appBarAndList,
          ),
          searchBox,
        ],
      ),
    );
  }
}


