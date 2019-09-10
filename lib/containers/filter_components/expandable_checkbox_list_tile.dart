import 'package:flutter/material.dart';

class ExpandableCheckboxListTile extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final Function(bool) onChanged;
  final ListTileControlAffinity controlAffinity;
  final bool value;
  final Widget secondary;
  final bool initiallyExpanded;

  const ExpandableCheckboxListTile({
    Key key,
    @required this.title,
    @required this.children,
    this.onChanged,
    this.controlAffinity,
    this.value,
    this.secondary,
    this.initiallyExpanded = false,
  })  : assert(title != null),
  assert(children != null),
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

  @override
  Widget build(BuildContext context) {
    final topicListTile = CheckboxListTile(
      title: widget.title,
      value: widget.value,
      controlAffinity: widget.controlAffinity,
      secondary: IconButton(
        icon: Icon(!_expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
        onPressed: (){
          setState(() {
            _expanded = !_expanded;
          });
        },
      ),
      onChanged: (b)=>widget.onChanged(b),
    );

    return !_expanded 
    ? topicListTile : Column(
      children: <Widget>[topicListTile] + widget.children
      );
  }
}
