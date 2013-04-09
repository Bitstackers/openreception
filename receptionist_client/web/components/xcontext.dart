import 'dart:async';
import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/context.dart';
import '../classes/environment.dart' as env;

class XContext extends WebComponent {
  void inserted() {
    // Make the environment aware of your existence.
    env.contextList.add(new Context(this));
  }
}
