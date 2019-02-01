import 'package:flutter/material.dart';

class ExtendedAppBar extends StatelessWidget {
  
  void _infoButtonPressed(BuildContext context){
    //TODO: Show popup for different settings 
    print('info button pressed');
  }

  void _navigateToFilter (BuildContext context) {
    //TODO: Navigate to Filter Route--Filter Route can be a single route, tab bar page controller 😄
    print('filter button pressed');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
          children: <TextSpan>[
            TextSpan(text: 'Tecarta'),
            TextSpan(
              text: 'Bible', 
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            TextSpan(text: ' Search')
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info_outline),
          color: Colors.white,
          onPressed: () => _infoButtonPressed(context),
          //TODO: onPressed action
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          color: Colors.white,
          onPressed: () => _navigateToFilter(context),
          //TODO: onPressed action
        ),
      ],
      leading: Icon(Icons.search, color: Colors.white,),  
    );
  }
}

