import 'dart:html';

import 'package:web_ui/web_ui.dart';

@observable
class Foo extends WebComponent {
  int clicks = 0;

  void increment() {
    clicks++;
  }
}
