import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/containers/filter_components/expandable_checkbox_list_tile.dart';
import 'package:bible_search/data/translation.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/presentation/translation_book_filter_screen.dart';
import 'package:flutter/material.dart';

class LanguageList extends StatelessWidget {
  final FilterViewModel vm;
  const LanguageList(this.vm);
  @override
  Widget build(BuildContext context) {
    final _languageList = <Widget>[];
    for (var i = 0; i < vm.languages.length; i++) {
      final lang = vm.languages[i];
      _languageList.add(ExpandableCheckboxListTile(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeData.dark().cardColor
            : null,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (b) {
          vm.selectLanguage(b, i);
        },
        value: lang.isSelected,
        title: Text(
          lang.name,
          // style: Theme.of(context).textTheme.title,
        ),
        children: [_LanguageChildren(vm, lang: lang)],
        initiallyExpanded: lang.a == 'en',
      ));
    }
    return ListView(children: _languageList);
  }
}

class _LanguageChildren extends StatelessWidget {
  final Language lang;
  final FilterViewModel vm;
  const _LanguageChildren(this.vm, {this.lang});
  @override
  Widget build(BuildContext context) {
    final _translationList = <Widget>[];
    final translations =
        vm.translations.data.where((t) => t.lang.id == lang.id).toList();
    for (var i = 0; i < translations.length; i++) {
      _translationList.add(Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: CheckboxListTile(
          checkColor: Theme.of(context).brightness == Brightness.dark
              ? ThemeData.dark().cardColor
              : null,
          onChanged: (b) => vm.selectTranslation(
              b, vm.translations.data.indexOf(translations[i])),
          value: translations[i].isSelected,
          title: AutoSizeText.rich(
            TextSpan(children: [
              TextSpan(
                text: '${translations[i].a}\t',
                // style: TextStyle(fontWeight: FontWeight.bold)
              ),
              TextSpan(
                text: translations[i].name,
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            ]),
          ),
          // subtitle: Text('${translations[i].name}'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ));
    }
    return Column(children: _translationList);
  }
}
