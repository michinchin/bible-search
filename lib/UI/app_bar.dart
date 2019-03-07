import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function(BuildContext) navigator;
  final Function(String) update;
  final Function(BuildContext) shareSelection;

  SearchAppBar(
      {Key key, this.title, this.navigator, this.update, this.shareSelection})
      : super(key: key);

  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        height: preferredSize.height,
        width: preferredSize.width,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            // boxShadow: [
            //   BoxShadow(
            //     color: Theme.of(context).backgroundColor,
            //     offset: Offset(0, 10.0),
            //     blurRadius: 10.0,
            //   ),
            //]
          ),
          child: TextField(
            onSubmitted: (s) {
              update(s);
            },
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              fillColor: Theme.of(context).cardColor,
              filled: true,
              prefixIcon: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(10.0),
                ),
              ),
              hintText: title,
              suffixIcon: Stack(alignment: Alignment.centerRight, children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 40.0),
                  child: IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () {
                      navigator(context);
                    },
                  ), // myIcon is a 48px-wide widget.
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 5.0),
                  child: IconButton(
                    icon:Icon(Icons.more_horiz),
                    onPressed: (){},
                  )
                ),
              ]),
              // suffix:
              //   IconButton(icon:Icon(Icons.filter_list),onPressed: (){navigator(context);},),
            ),
          ),
        ),
      ),
    );
  }
}
