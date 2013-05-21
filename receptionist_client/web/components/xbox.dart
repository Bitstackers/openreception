import 'dart:html';
import 'package:web_ui/web_ui.dart';

class Box extends WebComponent {
  bool chrome = true;
  Map get noChrome => chrome ? {} : {'border' : '0px', 'border-radius' : '0px'};
}
