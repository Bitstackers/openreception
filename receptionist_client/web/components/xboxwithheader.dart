import 'dart:html';

import 'package:web_ui/web_ui.dart';

class BoxWithHeader extends WebComponent {
  DivElement body;
  String headerfontsize = '1.0em';
  HeadingElement header;
  DivElement outer;

  void inserted() {
    _queryElements();
    _registerEventListeners();
    _styling();
    _resize();
  }

  void _queryElements() {
    outer = this.query('div');
    header = outer.query('h1');
    body = outer.query('div');
  }

  void _registerEventListeners() {
    window.onResize.listen((_) => _resize());
  }

  void _resize() {
    body.style.height = '${outer.client.height - header.client.height}px';
  }

  void _styling() {
    header.style.fontSize = headerfontsize;
  }
}
