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

class CompanyHandling {
  Box                box;
  DivElement         body;
  Context            context;
  DivElement         element;
  SpanElement        header;
  model.Organization organization = model.nullOrganization;
  UListElement       ul;
  String             title        = 'Håndtering';

  CompanyHandling(DivElement this.element) {
    var html = '''
      <div class="company-handling-container">
        <ul class="zebra">
        </ul>
      </div>
    ''';

    var frag = new DocumentFragment.html(html);
    body = frag.querySelector('.company-handling-container');
    ul = body.querySelector('.zebra');

    header = new SpanElement()
      ..text = title;

    box = new Box.withHeader(element, header, body);
    _registerEventListeners();
  }

  void _registerEventListeners() {
    event.bus.on(event.organizationChanged).listen((model.Organization value) {
      organization = value;
      render();
    });
  }

  void render() {
    ul.children.clear();

    for(var value in organization.handlingList) {
      ul.children.add(new LIElement()
                        ..text = value.value);
    }
  }
}
