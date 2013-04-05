import 'dart:html';

import 'package:web_ui/web_ui.dart';

class Context extends WebComponent {
  void inserted() {
    query('x-context-switcher').xtag.foo(this.id);
  }
}
