import 'package:flutter/material.dart';

class SearchHistoryTitle extends StatelessWidget {
  final double searchBarHeight;
  const SearchHistoryTitle(this.searchBarHeight);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        top: searchBarHeight / 4,
      ),
      color: Colors.transparent,
      child: Text(
        'SEARCH HISTORY',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[300]
              : Colors.grey[800],
          fontFamily: 'Roboto',
          fontSize: 18.0,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
