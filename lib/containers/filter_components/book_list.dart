import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/presentation/translation_book_filter_screen.dart';
import 'package:flutter/material.dart';

class BookList extends StatelessWidget {
  final FilterViewModel vm;
  final int tabValue;

  const BookList(this.vm, this.tabValue);

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      SwitchListTile.adaptive(
        title: const AutoSizeText(
          'Old Testament',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onChanged: (b) => vm.selectBook(b, -2),
        value: vm.otSelected,
        activeColor: Theme.of(context).accentColor,
      ),
      _BookChildren(
        vm,
        isOT: true,
        isFirstScreen: tabValue == 1,
      ),
      SwitchListTile.adaptive(
        title: const AutoSizeText(
          'New Testament',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onChanged: (b) => vm.selectBook(b, -1),
        value: vm.ntSelected,
        activeColor: Theme.of(context).accentColor,
      ),
      _BookChildren(
        vm,
        isOT: false,
        isFirstScreen: tabValue == 1,
      )
    ]);
  }
}

class _BookChildren extends StatelessWidget {
  final bool isOT;
  final FilterViewModel vm;
  final bool isFirstScreen;
  const _BookChildren(this.vm, {this.isOT, this.isFirstScreen});
  @override
  Widget build(BuildContext context) {
    final _bookList = <Widget>[];

    for (var i = isOT ? 0 : 39; i < (isOT ? 39 : vm.bookNames.length); i++) {
      if (vm.bookNames[i].numResults != 0 && !isFirstScreen) {
        _bookList.add(MultiSelectChip(
          isSelected: vm.bookNames[i].isSelected,
          title: '${vm.bookNames[i].name} (${vm.bookNames[i].numResults})',
          onSelected: (b) => vm.selectBook(b, i),
        ));
      } else if (isFirstScreen) {
        _bookList.add(MultiSelectChip(
          isSelected: vm.bookNames[i].isSelected,
          title: '${vm.bookNames[i].name}',
          onSelected: (b) => vm.selectBook(b, i),
        ));
      }
    }

    return Wrap(
        spacing: 5.0, alignment: WrapAlignment.center, children: _bookList);
  }
}

class MultiSelectChip extends StatelessWidget {
  final bool isSelected;
  final String title;
  final Function(bool) onSelected;
  const MultiSelectChip({this.isSelected, this.title, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      elevation: isSelected ? 5 : 0,
      shape: StadiumBorder(
          side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : Theme.of(context).accentColor)),
      selectedColor: Theme.of(context).accentColor,
      label: Text(
        title,
        style: TextStyle(
            color: isSelected
                ? Theme.of(context).brightness == Brightness.dark
                    ? ThemeData.dark().cardColor
                    : Colors.white
                : Theme.of(context).accentColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
      backgroundColor: isSelected
          ? Theme.of(context).accentColor
          : Theme.of(context).cardColor,
      onSelected: onSelected,
      selected: isSelected,
    );
  }
}
