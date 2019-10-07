import 'package:bible_search/containers/filter_components/expandable_checkbox_list_tile.dart';
import 'package:bible_search/presentation/translation_book_filter_screen.dart';
import 'package:flutter/material.dart';

class BookList extends StatelessWidget {
  final FilterViewModel vm;

  const BookList(this.vm);

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      SwitchListTile.adaptive(
        title: const Text('Old Testament'),
        onChanged: (b) => vm.selectBook(b, -2),
        value: vm.otSelected,
        activeColor: Theme.of(context).accentColor,
      ),
      _BookChildren(
        vm,
        isOT: true,
      ),

      SwitchListTile.adaptive(
        title: const Text('New Testament'),
        onChanged: (b) => vm.selectBook(b, -1),
        value: vm.ntSelected,
        activeColor: Theme.of(context).accentColor,
      ),

      _BookChildren(
        vm,
        isOT: false,
      )
      // ExpandableCheckboxListTile(
      //   color: Theme.of(context).brightness == Brightness.dark
      //       ? ThemeData.dark().cardColor
      //       : null,
      //   initiallyExpanded: true,
      //   controlAffinity: ListTileControlAffinity.leading,
      //   onChanged: (b) {
      //     vm.selectBook(b, -2);
      //   },
      //   value: vm.otSelected,
      //   title: Text(
      //     'Old Testament',
      //     style: Theme.of(context).textTheme.title,
      //   ),
      //   children: [
      // _BookChildren(
      //   vm,
      //   isOT: true,
      // )
      //   ],
      // ),

      // ExpandableCheckboxListTile(
      //   initiallyExpanded: true,
      //   color: Theme.of(context).brightness == Brightness.dark
      //       ? ThemeData.dark().cardColor
      //       : null,
      //   controlAffinity: ListTileControlAffinity.leading,
      //   onChanged: (b) {
      //     vm.selectBook(b, -1);
      //   },
      //   value: vm.ntSelected,
      //   title: Text(
      //     'New Testament',
      //     style: Theme.of(context).textTheme.title,
      //   ),
      //   children: [

      //   ],
      // )
    ]);
  }
}

class _BookChildren extends StatelessWidget {
  final bool isOT;
  final FilterViewModel vm;
  const _BookChildren(this.vm, {this.isOT});
  @override
  Widget build(BuildContext context) {
    final _bookList = <Widget>[];

    for (var i = isOT ? 0 : 39; i < (isOT ? 39 : vm.bookNames.length); i++) {
      _bookList.add(ChoiceChip(
        elevation: vm.bookNames[i].isSelected ? 5 : 0,
        shape: StadiumBorder(
            side: BorderSide(
                color: vm.bookNames[i].isSelected
                    ? Colors.transparent
                    : Theme.of(context).accentColor)),
        selectedColor: Theme.of(context).accentColor,
        label: Text(
          vm.bookNames[i].name,
          style: TextStyle(
              fontSize: 12.0,
              color: vm.bookNames[i].isSelected
                  ? Theme.of(context).brightness == Brightness.dark
                      ? ThemeData.dark().cardColor
                      : Colors.white
                  : Theme.of(context).accentColor,
              fontWeight: vm.bookNames[i].isSelected
                  ? FontWeight.bold
                  : FontWeight.normal),
        ),
        backgroundColor: vm.bookNames[i].isSelected
            ? Theme.of(context).accentColor
            : Theme.of(context).cardColor,
        onSelected: (b) => vm.selectBook(b, i),
        selected: vm.bookNames[i].isSelected,
      ));
    }

    return Wrap(
        spacing: 5.0,
        alignment: WrapAlignment.center,
        // crossAxisAlignment: WrapCrossAlignment.center,
        // verticalDirection: VerticalDirection.down,
        children: _bookList);
  }
}
