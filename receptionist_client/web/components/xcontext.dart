import 'dart:async';
import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/context.dart';
import '../classes/environment.dart' as environment;

class XContext extends WebComponent {
  void inserted() {
    environment.contextList.add(new Context(this));
  }
}
