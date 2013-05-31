/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/keyboardhandler.dart';
import '../classes/environment.dart' as environment;

class BoxWithHeader extends WebComponent {
  DivElement body;
  HeadingElement header;
  String headerfontsize = '1.0em';
  String headerpadding = '5px 10px';
  DivElement outer;
  String focuson = '';

  String get focusborder => (focuson != '' && environment.activeWidget == focuson) ? 'focusborder' : '';

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
    header.style.padding = headerpadding;
  }
}
