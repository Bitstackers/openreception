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

class CompanyEmailAddresses {
  Box                box;
  Context            context;
  DivElement         element;
  bool               hasFocus = false;
  SpanElement        header;
  model.Organization organization = model.nullOrganization;
  UListElement       ul;
  String             title        = 'Emailadresser';

  CompanyEmailAddresses(DivElement this.element, Context this.context) {
    element.classes.add('minibox');

    ul = new UListElement()
      ..classes.add('zebra')
      ..id = 'company-email-addresses-list';

    header = new SpanElement()
      ..text = title;

    box = new Box.withHeader(element, header, ul);

    registerEventListeners();
  }

  void registerEventListeners() {
    event.bus.on(event.organizationChanged).listen((model.Organization value) {
      organization = value;
      render();
    });

    event.bus.on(event.focusChanged).listen((Focus value) {
      hasFocus = handleFocusChange(value, [ul], element);
    });

    ul.onFocus.listen((_) {
      setFocus(ul.id);
    });

    element.onClick.listen((_) {
      setFocus(ul.id);
    });

    context.registerFocusElement(ul);
  }

  void render() {
    ul.children.clear();

    for(var value in organization.emailAddressList) {
      ul.children.add(new LIElement()
                        ..text = value.value);
    }
  }
}
