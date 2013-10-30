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

part of components;

class Box {
  DivElement element;
  HeadingElement header;
  DivElement body;

  Box.noChrome(DivElement this.element, Element bodyContent) {
    element
      ..children.add(bodyContent)
      ..classes.add('no-chrome');
  }

  Box.withHeader(DivElement this.element, Element headerContent, Element bodyContent) {
    print('[${element.id}] ${bodyContent.clientHeight}');
    String html = '''
      <h1 class="box-with-header-headline box-with-header-medium">
      </h1>
      <div class="box-with-header-content">
      </div>
    ''';

    element.children.addAll(new DocumentFragment.html(html).children);
    element.classes.add('box-with-header-outer');

    header = element.querySelector('.box-with-header-headline');
    body = element.querySelector('.box-with-header-content');

    header.children.add(headerContent);
    body.children.add(bodyContent);

    _registerEventListeners();
    _resize();
  }

  Box.withHeaderStatic(DivElement this.element, HeadingElement this.header, DivElement this.body) {
    element.classes.add('box-with-header-outer');
    header.classes.addAll(['box-with-header-headline','box-with-header-medium']);
    body.classes.add('box-with-header-content');
    _registerEventListeners();
    _resize();
  }

  void _registerEventListeners() {
    window.onResize.listen((_) => _resize());
  }

  void _resize() {
    print('BOX.WITHHEADER: [${element.className} / ${element.id}] ${element.client.height} - ${header.client.height}px');
    body.style.height = '${element.client.height - header.client.height}px';
  }
}
