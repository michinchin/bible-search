import 'package:bible_search/containers/result_card.dart';
import 'package:bible_search/models/filter_model.dart';
import 'package:bible_search/presentation/translation_book_filter.dart';
import 'package:flutter/material.dart';
import 'package:bible_search/presentation/results_page.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function(String) update;
  final Function(BuildContext, bool, String) shareSelection;
  final bool isInSelectionMode;
  final String text;
  final Function() changeToSelectionMode;
  final int numSelected;

  SearchAppBar(
      {Key key,
      this.title,
      this.update,
      this.shareSelection,
      this.text,
      this.isInSelectionMode = false,
      this.changeToSelectionMode,
      this.numSelected})
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
        ? SafeArea(
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
                      suffixIcon:
                          Stack(alignment: Alignment.centerRight, children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 80.0),
                          child: (_controller.text.length > 0)
                              ? IconButton(
                                  color: Theme.of(context).disabledColor,
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
                          padding: const EdgeInsetsDirectional.only(end: 40.0),
                          child: IconButton(
                            icon: Icon(Icons.filter_list),
                            onPressed: () => _navigateToFilter(context),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsetsDirectional.only(end: 0.0),
                            child: IconButton(
                              icon: Icon(Icons.more_horiz),
                              onPressed: () => {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext c) {
                                          return new Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new ListTile(
                                                leading: new Icon(
                                                    Icons.check_circle),
                                                title:
                                                    new Text('Selection Mode'),
                                                onTap: () =>
                                                    _changeToSelectionMode(),
                                              ),
                                              new ListTile(
                                                  leading: new Icon(
                                                      Icons.photo_album),
                                                  title: new Text('Photos'),
                                                  onTap: () => {}),
                                              new ListTile(
                                                  leading:
                                                      new Icon(Icons.videocam),
                                                  title: new Text('Video'),
                                                  onTap: () => {}),
                                            ],
                                          );
                                        })
                                  },
                            )),
                      ]),
                    ),
                  ),
                )))
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
                    widget.shareSelection(context, true, widget.text),
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () =>
                    widget.shareSelection(context, false, widget.text),
              )
            ],
          );
  }
}

class CardView extends StatelessWidget {
  ResultsViewModel vm;
  CardView(this.vm);
  @override
  Widget build(BuildContext context) {
    var _controller = ScrollController();
    var res = FilterModel().filterByBook(vm.searchResults, vm.bookNames);
    var container = Container(
      key: PageStorageKey(vm.searchQuery +
          '${res[0].ref}' +
          '${res.length}'),
      padding: EdgeInsets.all(10.0),
      child: ListView.builder(
        itemCount: res == null ? 1 : res.length + 1,
        controller: _controller,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Container(
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
                          text: '${vm.searchQuery}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            );
          }
          index -= 1;

          return ResultCard(
            index: index,
            res: res[index],
            keywords: vm.searchQuery,
            isInSelectionMode: vm.isInSelectionMode,
            selectCard: vm.selectCard,
            bookNames: vm.bookNames,
            toggleSelectionMode: vm.changeToSelectionMode,
          );
        },
      ),
    );
    return container;
  }
}
