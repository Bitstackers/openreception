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

abstract class ReceptionOpeningHoursLabels {
  static const HeaderText = 'Åbningstider';
}

class ReceptionOpeningHours {
  
  static const String className   = '${libraryName}.CompanyOpeningHours';
  static const String NavShortcut = 'X'; 

  Context         context;
  Element         element;
  bool            hasFocus  = false;
  model.Reception reception = model.nullReception;
  UListElement    get openingHoursList      => this.element.querySelector('#${id.COMPANY_OPENINGHOURS_LIST}');
  Element         get header                => this.element.querySelector('legend');
  List<Element> get nudges => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  
  ReceptionOpeningHours(Element this.element, Context this.context) {
    assert(element.attributes.containsKey(defaultElementId));
    
    ///Navigation shortcuts
    this.element.insertBefore(new Nudge(NavShortcut).element, this.header);
    keyboardHandler.registerNavShortcut(NavShortcut, (_) => Controller.Context.changeLocation(new nav.Location(context.id, element.id, openingHoursList.id)));

    header.text = ReceptionOpeningHoursLabels.HeaderText;

    registerEventListeners();
  }

  void registerEventListeners() {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

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
