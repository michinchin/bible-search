import 'package:auto_size_text/auto_size_text.dart';
import 'package:bible_search/containers/filter_components/language_list.dart';
import 'package:bible_search/labels.dart';
import 'package:bible_search/models/app_state.dart';
import 'package:bible_search/presentation/translation_book_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class ChooseDefaultTranslationScreen extends StatelessWidget {
  const ChooseDefaultTranslationScreen();
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FilterViewModel>(
        converter: (store) => FilterViewModel(store),
        builder: (context, vm) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Priority Translations'),
              ),
              body: SafeArea(
                child: Container(
                    child: Column(children: [
                  Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                              'Select up to $maxDefaultTranslations translations. This will prioritize them (when available) in search results.',
                              minFontSize: defaultMinFontSize))),
                  Expanded(
                      child: LanguageList(
                    vm,
                    isFilterView: false,
                  ))
                ])),
              ));
        });
  }
}
