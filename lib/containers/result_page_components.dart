import 'package:bible_search/containers/result_card.dart';
import 'package:bible_search/models/filter_model.dart';
import 'package:bible_search/presentation/translation_book_filter.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:bible_search/presentation/results_page.dart';
import 'package:tec_native_ad/tec_native_ad.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function(String) update;
  final Function(BuildContext, bool, String) shareSelection;
  final bool isInSelectionMode;
  final String Function() getText;
  final Function() changeToSelectionMode;
  final Function(bool) changeTheme;
  final int numSelected;
  final bool isDarkTheme;

  SearchAppBar(
      {Key key,
      @required this.title,
      @required this.update,
      @required this.shareSelection,
      @required this.getText,
      this.isInSelectionMode = false,
      @required this.changeToSelectionMode,
      @required this.numSelected,
      @required this.isDarkTheme,
      @required this.changeTheme})
      : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  // only expose a getter to prevent bad usage
  TextEditingController _controller;
  bool _isInSelectionMode;

  @override
  initState() {
    _isInSelectionMode = widget.isInSelectionMode;
    _controller = TextEditingController(text: widget.title);
    super.initState();
  }

  @override
  void didUpdateWidget(SearchAppBar oldWidget) {
    _isInSelectionMode = widget.isInSelectionMode;
    super.didUpdateWidget(oldWidget);
  }

  void onFieldChange(String newValue) {
    setState(() {
      _controller.text = newValue;
    });
  }

  void _changeToSelectionMode() {
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
      widget.changeToSelectionMode();
    });
  }

  void _navigateToFilter(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return TranslationBookFilterPage(tabValue: 0);
        },
        fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    return !_isInSelectionMode
        ? Stack(children: [
            AppBar(
              elevation: 0.0,
              brightness: Brightness.light,
              backgroundColor: Colors.transparent,
              bottomOpacity: 0.0,
              toolbarOpacity: 0.0,
            ),
            SafeArea(
                minimum: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Container(
                    height: widget.preferredSize.height,
                    width: widget.preferredSize.width,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10.0),
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            offset: Offset(0, 5.0),
                            blurRadius: 5.0,
                          ),
                        ]),
                    child: Center(
                      child: TextField(
                        controller: _controller,
                        onChanged: (s) {
                          setState(() {});
                        },
                        onSubmitted: (s) {
                          setState(() {
                            widget.update(s);
                          });
                        },
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          border: InputBorder.none,
                          suffixIcon: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      end: 80.0),
                                  child: (_controller.text.length > 0)
                                      ? IconButton(
                                          color:
                                              Theme.of(context).disabledColor,
                                          icon: Icon(Icons.close),
                                          onPressed: () {
                                            setState(() {
                                              _controller.clear();
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      end: 40.0),
                                  child: IconButton(
                                    icon: Icon(Icons.filter_list),
                                    onPressed: () => _navigateToFilter(context),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 0.0),
                                    child: IconButton(
                                      icon: Icon(Icons.more_horiz),
                                      onPressed: () => {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (BuildContext c) {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.check_circle),
                                                        title: Text(
                                                            'Selection Mode'),
                                                        onTap: () =>
                                                            _changeToSelectionMode(),
                                                      ),
                                                      SwitchListTile(
                                                          secondary: Icon(Icons
                                                              .lightbulb_outline),
                                                          value: widget
                                                              .isDarkTheme,
                                                          title: Text(
                                                              'Light/Dark Mode'),
                                                          onChanged: (b) {
                                                            DynamicTheme.of(
                                                                    context)
                                                                .setThemeData(
                                                                    ThemeData(
                                                              primarySwatch: b
                                                                  ? Colors.teal
                                                                  : Colors
                                                                      .orange,
                                                              primaryColorBrightness:
                                                                  Brightness
                                                                      .dark,
                                                              brightness: b
                                                                  ? Brightness
                                                                      .dark
                                                                  : Brightness
                                                                      .light,
                                                            ));
                                                            widget
                                                                .changeTheme(b);
                                                          }),
                                                      ListTile(
                                                          leading: new Icon(
                                                              Icons.videocam),
                                                          title:
                                                              new Text('Video'),
                                                          onTap: () => {}),
                                                    ],
                                                  );
                                                })
                                          },
                                    )),
                              ]),
                        ),
                      ),
                    ))),
          ])
        : AppBar(
            title: Text('${widget.numSelected}'),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => _changeToSelectionMode(),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.content_copy),
                onPressed: () =>
                    widget.shareSelection(context, true, widget.getText()),
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () =>
                    widget.shareSelection(context, false, widget.getText()),
              )
            ],
          );
  }
}

class CardView extends StatefulWidget {
  final ResultsViewModel vm;
  CardView(this.vm);

  @override
  State<StatefulWidget> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  NativeAdController nativeAdController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    nativeAdController = NativeAdController(
        // test app id google provides
        applicationId: 'ca-app-pub-5279916355700267/7203757709',
        numberOfAds: 1,
        updateLoadingState: updateLoadingState);
  }

  void updateLoadingState(bool loading) {
    if (_loading != loading) {
      setState(() {
        _loading = loading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var res = widget.vm.filteredRes;
    var container = Container(
        key: PageStorageKey(
            widget.vm.searchQuery + '${res[0].ref}' + '${res.length}'),
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: _buildResults(res),
        ));
    return container;
  }

  List<Widget> _buildResults(List res) {
    List<Widget> results = [];
    for (var i = 0; i < res.length; i++) {
      results.add(ResultCard(
        index: i,
        res: res[i],
        keywords: widget.vm.searchQuery,
        isInSelectionMode: widget.vm.isInSelectionMode,
        selectCard: widget.vm.selectCard,
        bookNames: widget.vm.bookNames,
        toggleSelectionMode: widget.vm.changeToSelectionMode,
      ));
    }
    if (res.length > 0) {
      results.insert(
          0,
          Container(
            padding: EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.caption,
                  children: [
                    TextSpan(
                      text: 'Showing ${res.length} results for ',
                    ),
                    TextSpan(
                        text: '${widget.vm.searchQuery}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ));
      if (nativeAdController.adCount > 0 && res.length > 3) {
        results.insert(
            3,
            TecNativeAd(
              index: 0,
              loadingIndicator: _loading
                  ? const Center(child: const CircularProgressIndicator())
                  : null,
            ));
      }
    }
    return results;
  }
}
