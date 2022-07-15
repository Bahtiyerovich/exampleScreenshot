import 'package:examplscreenshot/screens/share.dart';
import 'package:flutter/material.dart';

import '../screens/home_page.dart';
import '../screens/scrsho.dart';

class MyRoutes {
  static final MyRoutes _instance = MyRoutes.init();
  static MyRoutes get instance => MyRoutes._instance;
  MyRoutes.init();

  Route? onGenerate(RouteSettings s) {
    var args = s.arguments;
    switch (s.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) =>  HomePage(title: '',));
       case '/scr':
        return MaterialPageRoute(builder: (_) =>  ScreenshotPage(title: '',));
     case '/share':
        // return MaterialPageRoute(builder: (_) =>  DemoApp());
    
    }
  }
}