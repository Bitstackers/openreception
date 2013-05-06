import 'dart:html';
import 'package:web_ui/web_ui.dart';

class Box extends WebComponent {
  bool chrome = true;

  String get outerboxChrome => chrome ? '' : 'hideborder';
}
