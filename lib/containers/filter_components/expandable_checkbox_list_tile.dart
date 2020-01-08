import 'package:flutter/material.dart';

class ExpandableCheckboxListTile extends StatefulWidget {
  final Widget title;
  final Widget child;
  final Function(bool) onChanged;
  final ListTileControlAffinity controlAffinity;
  final bool value;
  final Widget secondary;
  final bool initiallyExpanded;
  final Color color;

  const ExpandableCheckboxListTile({
    Key key,
    @required this.title,
    @required this.child,
    this.onChanged,
    this.controlAffinity = ListTileControlAffinity.leading,
    this.value,
    this.secondary,
    this.initiallyExpanded = false,
    this.color = Colors.white,
  })  : assert(title != null),
        assert(child != null),
        super(key: key);
  @override
  _ExpandableCheckboxListTileState createState() =>
      _ExpandableCheckboxListTileState();
}

class _ExpandableCheckboxListTileState
    extends State<ExpandableCheckboxListTile> {
  bool _expanded;

  @override
  void initState() {
    _expanded = widget.initiallyExpanded;
    super.initState();
  }

  void onExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget topicListTile;
    if (widget.value == null || widget.onChanged == null) {
      topicListTile = ListTile(
        title: widget.title,
        onTap: onExpanded,
        trailing: IconButton(
          icon: Icon(
              !_expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
          onPressed: onExpanded,
        ),
      );
    } else {
      topicListTile = CheckboxListTile(
        checkColor: widget.color,
        title: widget.title,
        value: widget.value,
        controlAffinity: widget.controlAffinity,
        secondary: IconButton(
          icon: Icon(
              !_expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
          onPressed: onExpanded,
        ),
        onChanged: (b) => widget.onChanged(b),
      );
    }

    return !_expanded
        ? topicListTile
        : Column(children: <Widget>[topicListTile] + [widget.child]);
  }
}
