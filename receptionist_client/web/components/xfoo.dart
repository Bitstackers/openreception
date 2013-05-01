import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart';

class Foo extends WebComponent {
  String contextid;

  void increaseAlert() {
    contextList.increaseAlert(contextid);
  }

  void decreaseAlert() {
    contextList.decreaseAlert(contextid);
  }
}
