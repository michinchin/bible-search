import 'package:flutter/material.dart';

import 'package:tec_widgets/tec_widgets.dart' as tw;
import 'package:tec_util/tec_util.dart' as tec;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/containers/filter_components/book_list.dart';
import 'package:bible_search/containers/filter_components/expandable_checkbox_list_tile.dart';
import 'package:bible_search/data/translation.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/presentation/translation_book_filter_screen.dart';

class LanguageList extends StatelessWidget {
  final FilterViewModel vm;
  final bool isFilterView;
  const LanguageList(this.vm, {this.isFilterView = true});

  @override
  Widget build(BuildContext context) {
    final _languageList = <Widget>[];

    for (var i = 0; i < vm.languages.length; i++) {
      final lang = vm.languages[i];
      final languages = vm.translations.data
          .takeWhile((t) => t.isSelected)
          .map((t) => t.lang.a)
          .toSet()
          .toList();
      _languageList.add(ExpandableCheckboxListTile(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).cardColor
            : null,
        onChanged: isFilterView ? (b) => vm.selectLanguage(b, i) : null,
        value: isFilterView ? lang.isSelected : null,
        title: AutoSizeText(
          lang.name,
          style: Theme.of(context).textTheme.title,
        ),
        child: _LanguageChildren(
            lang: lang,
            translations: vm.translations.data,
            onClick: isFilterView
                ? vm.selectTranslation
                : vm.selectDefaultTranslation,
            isFilterView: isFilterView),
        // only expand if a translation in that language is selected
        initiallyExpanded:
            languages.where((l) => l == lang.a).toList().isNotEmpty,
      ));
    }

    return ListView(children: _languageList);
  }
}

class _LanguageChildren extends StatelessWidget {
  final Language lang;
  final List<BibleTranslation> translations;
  final Function onClick;
  final bool isFilterView;
  const _LanguageChildren(
      {@required this.lang,
      @required this.translations,
      @required this.onClick,
      @required this.isFilterView});
  @override
  Widget build(BuildContext context) {
    final _translationList = <Widget>[];
    final tl = translations?.where((t) => t.lang.id == lang.id)?.toList() ?? [];
    for (var i = 0; i < tl.length; i++) {
      if (isFilterView) {
        _translationList.add(Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: CheckboxListTile(
            checkColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : null,
            onChanged: (b) => onClick(b, translations.indexOf(tl[i])),
            value: tl[i].isSelected,
            title: AutoSizeText.rich(
              TextSpan(children: [
                TextSpan(
                    text: '${tl[i].a}\t',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text: tl[i].name,
                  style: const TextStyle(
                      fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ]),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ));
      } else {
        final defaults = translations.where((t) => t.isDefault).toList();
        final ids = tec.Prefs.shared
            .getString(defaultTranslationsPref, defaultValue: '');
        final number =
            ids.split('|').map(int.tryParse).toList().indexOf(tl[i].id);
        final defNum = number == -1 ? '' : '${number + 1}:';

        _translationList.add(MultiSelectChip(
            isSelected: tl[i].isDefault,
            title: '$defNum ${tl[i].a}',
            onSelected: (b) {
              if (defaults.length == maxDefaultTranslations && b) {
                tw.TecToast.show(context, 'Cannot select more than three items');
              } else {
                onClick(b, translations.indexOf(tl[i]));
              }
            }));
      }
    }
    return isFilterView
        ? Column(children: _translationList)
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Wrap(
              spacing: 10,
              children: _translationList,
            ),
          );
  }
}
