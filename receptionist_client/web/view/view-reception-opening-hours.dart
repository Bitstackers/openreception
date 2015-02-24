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

class ReceptionOpeningHours {

  static const String className   = '${libraryName}.ReceptionOpeningHours';
  static const String NavShortcut = 'X';

  bool get muted => this.context != Context.current;

  Context         context;
  Element         element;
  bool            hasFocus  = false;
  UListElement    get openingHoursList      => this.element.querySelector('#${Id.receptionOpeningHoursList}');
  Element         get header                => this.element.querySelector('legend');
  List<Element> get nudges => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);


  ReceptionOpeningHours(Element this.element, Context this.context) {
    assert(element.attributes.containsKey(defaultElementId));

    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);

    header.children = [Icon.Clock,
                       new SpanElement()..text = Label.OpeningHours,
                       new Nudge(NavShortcut).element];

    registerEventListeners();
  }

  void registerEventListeners() {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    event.bus.on(model.Reception.activeReceptionChanged).listen((model.Reception reception) {
      render(reception);
    });

    element.onClick.listen((_) {
      Controller.Context.changeLocation(new nav.Location(context.id, element.id, openingHoursList.id));
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      element.classes.toggle(FOCUS, active);
      if(active) {
        this.openingHoursList.focus();
      }
    });
  }

  void _select(_) {
    if (!this.muted) {
      Controller.Context.changeLocation(new nav.Location(context.id, element.id, openingHoursList.id));
    }
  }

  void render(model.Reception reception) {
    openingHoursList.children.clear();

    for(var value in reception.openingHours) {
      openingHoursList.children.add(new LIElement()
                        ..text = value);
    }
  }
}
