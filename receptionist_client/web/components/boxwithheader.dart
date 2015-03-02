/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of view;

class Box {
  DivElement element;
  HeadingElement header;
  DivElement _body;

  Box.noChrome(DivElement this.element, Element bodyContent) {
    element
      ..children.add(bodyContent)
      ..classes.add(CssClass.noChrome);
  }

  Box.withHeader(DivElement this.element, Element headerContent, [Element bodyContent]) {
    String html = '''
      <h1 class="${CssClass.boxWithHeaderHeadline} ${CssClass.boxWithHeaderMedium}">
      </h1>
      <div class="${CssClass.boxWithHeaderContent}">
      </div>
    ''';

    element.children.addAll(new DocumentFragment.html(html).children);
    element.classes.add(CssClass.boxWithHeaderOuter);

    header = element.querySelector('.${CssClass.boxWithHeaderHeadline}');
    _body = element.querySelector('.${CssClass.boxWithHeaderContent}');

    header.children.add(headerContent);
    if (bodyContent != null) {
      _body.children.add(bodyContent);
    }

    _registerEventListeners();
    _resize();
  }

  Box.withHeaderStatic(DivElement this.element, HeadingElement this.header, DivElement this._body) {
    element.classes.add(CssClass.boxWithHeaderOuter);
    header.classes.addAll([CssClass.boxWithHeaderHeadline, CssClass.boxWithHeaderMedium]);
    _body.classes.add(CssClass.boxWithHeaderContent);
    _registerEventListeners();
    _resize();
  }

  void addBody(Element bodyContent) {
    _body.children.add(bodyContent);
  }

  void _registerEventListeners() {
    window.onResize.listen((_) => _resize());
  }

  void _resize() {
    _body.style.height = '${element.client.height - header.client.height}px';
  }
}
