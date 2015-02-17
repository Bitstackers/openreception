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

class ReceptionSalesCalls {

  static const String className   = '${libraryName}.ReceptionSalesCalls';
  static const String NavShortcut = 'C';

  bool get muted => this.context != Context.current;

  final Context   context;
  final Element   element;
  bool         hasFocus  = false;
  Element      get header           => this.element.querySelector('legend');
  UListElement get instructionList  => this.element.querySelector('#${Id.COMPANY_SALES_LIST}');

  List<Element> get nudges => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  ReceptionSalesCalls(Element this.element, Context this.context) {
    String defaultElementId = 'data-default-element';
    assert(element.attributes.containsKey(defaultElementId));

    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);

    header.children = [Icon.Money, new SpanElement()..text = Label.SalesCalls, new Nudge(NavShortcut).element];

    registerEventListeners();
  }

  void registerEventListeners() {

    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    event.bus.on(event.receptionChanged).listen(render);

    element.onClick.listen((_) {
      Controller.Context.changeLocation(new nav.Location(context.id, element.id, instructionList.id));
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      element.classes.toggle(FOCUS, active);
      if(active) {
        instructionList.focus();
      }
    });
  }

  void _select(_) {
    if (!this.muted) {
      Controller.Context.changeLocation(new nav.Location(context.id, element.id, instructionList.id));
    }
  }

  void render(model.Reception reception) {
    instructionList.children.clear();

    for(var value in reception.salesMarketingHandling) {
      instructionList.children.add(new LIElement()
                        ..text = value);
    }
  }
}