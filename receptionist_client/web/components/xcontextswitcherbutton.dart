import 'dart:html';
import 'package:web_ui/web_ui.dart';

import '../classes/section.dart';

class ContextSwitcherButton extends WebComponent {
  ButtonElement button;
  Section section;

  String get _active => section.isActive ? _css['.active'] : '';
  bool get _disabled => section.isActive ? true : false;

  void inserted() {
    button = this.query('button');

    _resize();
    window.onResize.listen((_) => _resize());
  }

  void _resize() {
    button.style.height = '${button.client.width}px';
  }

  void activate() {
    section.activate();
  }
}
