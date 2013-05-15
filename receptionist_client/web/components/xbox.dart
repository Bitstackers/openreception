import 'dart:html';
import 'package:web_ui/web_ui.dart';

class Box extends WebComponent {
  bool chrome = true;

  Map<String, String> killChrome = {'border' : '0px', 'border-radius' : '0px'};

  Map get noChrome => chrome ? {} : killChrome;
}
