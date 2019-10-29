import 'package:flutter/material.dart';

class SearchHistoryList extends StatelessWidget {
  final List<String> searchHistory;
  final Function(String) onSearchEntered;
  final Function(List<String>) updateSearchHistory;

  const SearchHistoryList(
      {this.searchHistory, this.onSearchEntered, this.updateSearchHistory});

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
                  Scaffold.of(context).showSnackBar(SnackBar(
                      backgroundColor: Theme.of(context).cardColor,
                      content: Text(
                        'The search term "${words[index]}" has been removed',
                        style: Theme.of(context).textTheme.body1,
                      )));
                  words.removeWhere((w) => (w == words[index]));
                  updateSearchHistory(words.reversed.toList());
                },
                background: Container(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete)),
                  color: Colors.red,
                ),
                child: Semantics(
                  label: 'Search for',
                  child: ListTile(
                    title: Text(
                      '${words[index]}',
                    ),
                    leading: Icon(Icons.access_time),
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
