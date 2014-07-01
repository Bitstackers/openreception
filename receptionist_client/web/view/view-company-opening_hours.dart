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

part of view;

abstract class CompanyOpeningHoursLabels {
  static const HeaderText = 'Åbningstider';
}

class CompanyOpeningHours {
  Context         context;
  Element         element;
  bool            hasFocus  = false;
  model.Reception reception = model.nullReception;
  UListElement    get openingHoursList      => this.element.querySelector('#${id.COMPANY_OPENINGHOURS_LIST}');
  Element         get header                => this.element.querySelector('legend');

  
  CompanyOpeningHours(Element this.element, Context this.context) {
    String defaultElementId = 'data-default-element';
    assert(element.attributes.containsKey(defaultElementId));
    
    header.text = CompanyOpeningHoursLabels.HeaderText;

    registerEventListeners();
  }

  void registerEventListeners() {
    event.bus.on(event.receptionChanged).listen((model.Reception reception) {
      render(reception);
    });
    
    element.onClick.listen((_) {
      event.bus.fire(event.locationChanged, new nav.Location(context.id, element.id, this.openingHoursList.id));
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      element.classes.toggle(FOCUS, active);
      if(active) {
        this.openingHoursList.focus();
      }
    });
  }

  void render(model.Reception reception) {
    openingHoursList.children.clear();

    for(var value in reception.openingHoursList) {
      openingHoursList.children.add(new LIElement()
                        ..text = value.value);
    }
  }
}
