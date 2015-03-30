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

class ReceptionProduct {
  final Context       uiContext;
  final Element       element;

  bool get muted     => this.uiContext != Context.current;

  static const String className   = '${libraryName}.ReceptionProduct';
  static const String NavShortcut = 'F';

  ParagraphElement get body     => this.element.querySelector('#${Id.receptionProductBody}');
  Element          get header   => this.element.querySelector('legend');
  List<Element> get nudges => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  ReceptionProduct(Element this.element, Context this.uiContext) {
    assert(element.attributes.containsKey(defaultElementId));

    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(NavShortcut, (_) => this._select());


    header.children = [Icon.Product,
                       new SpanElement()..text = Label.ProductDescription,
                       new Nudge(NavShortcut).element];

    registerEventListeners();
  }

  void _select() {
    if (!this.muted) {
      Controller.Context.changeLocation(new nav.Location(uiContext.id, element.id, body.id));
    }
  }

  void registerEventListeners() {

    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    event.bus.on(model.Reception.activeReceptionChanged).listen((model.Reception value) {
      body.text = value.product;
    });

    element.onClick.listen((_) {
      event.bus.fire(event.locationChanged, new nav.Location(uiContext.id, element.id, body.id));
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      element.classes.toggle(CssClass.focus, active);
      if(active) {
        body.focus();
      }
    });
  }
}
