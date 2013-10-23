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

import 'package:polymer/polymer.dart';

import '../classes/common.dart';

@CustomTag('box-with-header')
class BoxWithHeader extends PolymerElement with ApplyAuthorStyle {
              DivElement     body;
              HeadingElement header;
  @published  String         headerfontsize = '1.0em';
  @published  String         headerpadding  = '5px 10px';
              DivElement     outer;
  @observable String         focusborder    = '';

  BoxWithHeader.created() : super.created() {}

  void enteredView() {
    _queryElements();
    _registerEventListeners();
    _styling();
    _resize();
  }

  void _queryElements() {
    outer = getShadowRoot('box-with-header').querySelector('div');
    header = outer.querySelector('h1');
    body = outer.querySelector('div');
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
