import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';

class SearchHistoryList extends StatelessWidget {
  final List<String> searchHistory;
  final Function(String) onSearchEntered;
  final Function(List<String>) updateSearchHistory;

  const SearchHistoryList({this.searchHistory, this.onSearchEntered, this.updateSearchHistory});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemBuilder: (context, index) {
            final words = searchHistory.reversed.toList();
            return ListTileTheme(
              child: Dismissible(
                key: Key(words[index]),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  TecToast.show(context, 'The search term "${words[index]}" has been removed');
                  words.removeWhere((w) => (w == words[index]));
                  updateSearchHistory(words.reversed.toList());
                },
                background: Container(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: const Align(alignment: Alignment.centerRight, child: Icon(Icons.delete)),
                  color: Colors.red,
                ),
                child: Semantics(
                  label: 'Search for',
                  child: ListTile(
                    title: Text(
                      '${words[index]}',
                    ),
                    leading: const Icon(FeatherIcons.clock),
                    onTap: () {
                      onSearchEntered(words[index]);
                      Navigator.of(context).pushNamed('/results');
                    },
                  ),
                ),
              ),
            );
          },
          itemCount: searchHistory?.length ?? 0),
    );
  }
}
