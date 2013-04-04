import 'dart:html';

import 'package:web_ui/web_ui.dart';

class BoxWithHeader extends WebComponent {
  HeadingElement header;
  DivElement body;
  DivElement outer;

  inserted() {
    outer = this.query('div');
    header = outer.query('h1');
    body = outer.query('div');

    _resize();
    window.onResize.listen((_) => _resize());
  }

  void _resize() {
    body.style.height = '${outer.client.height - header.client.height}px';
  }
}
