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

class CompanyAlternateNames {
  Box                box;
  String            contextId;
  DivElement         element;
  bool               hasFocus = false;
  SpanElement        header;
  model.Organization organization = model.nullOrganization;
  UListElement       ul;
  String             title        = 'Alternative firmanavne';

  CompanyAlternateNames(DivElement this.element, String this.contextId) {
    element.classes.add('minibox');

    ul = new UListElement()
      ..classes.add('zebra')
      ..id = 'company-alternate-names-list';

    header = new SpanElement()
      ..text = title;

    box = new Box.withHeader(element, header, ul);

    registerEventListeners();
  }

  void tabToggle(bool state) {
    ul.tabIndex = state ? getTabIndex(ul.id) : -1;
  }

  void registerEventListeners() {
    event.bus.on(event.organizationChanged).listen((model.Organization value) {
      organization = value;
      render();
    });

    event.bus.on(event.focusChanged).listen((Focus value) {
      if(value.old == ul.id) {
        hasFocus = false;
        element.classes.remove(focusClassName);
      }

      if(value.current == ul.id) {
        hasFocus = true;
        element.classes.add(focusClassName);
        ul.focus();
      }
    });

    ul.onFocus.listen((_) {
      setFocus(ul.id);
    });

    element.onClick.listen((_) {
      setFocus(ul.id);
    });

    event.bus.on(event.activeContextChanged).listen((String value) => tabToggle(contextId == value));
  }

  void render() {
    ul.children.clear();

    for(var value in organization.alternateNameList) {
      ul.children.add(new LIElement()
                        ..text = value.value);
    }
  }
}
