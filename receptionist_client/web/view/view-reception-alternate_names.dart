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

class ReceptionAlternateNames {
  final Context uiContext;
  final Element element;
  
  static const String className = '${libraryName}.ReceptionAlternateNames';
  static const String NavShortcut = 'F';

  bool get muted     => this.uiContext != Context.current;
  bool     hasFocus  =  false;
  
  Element         get header             => this.element.querySelector('legend');
  UListElement    get alternateNamesList => this.element.querySelector('#${id.COMPANY_ALTERNATE_NAMES_LIST}');
  String          title     = 'Alternative firmanavne';

  List<Element>   get nudges         => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  ReceptionAlternateNames(Element this.element, Context this.uiContext) {
    assert(element.attributes.containsKey(defaultElementId));
    ///Navigation shortcuts
    this.element.insertBefore(new Nudge(NavShortcut).element,  this.header);
    keyboardHandler.registerNavShortcut(NavShortcut, (_) => this._select());

    header.text = title;

    registerEventListeners();
  }
  
  void _select() {
    if (!this.muted) {
      Controller.Context.changeLocation(new nav.Location(uiContext.id, element.id, alternateNamesList.id));
    } 
  }

  void registerEventListeners() {
    
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    event.bus.on(event.receptionChanged).listen(render);

    element.onClick.listen((_) {
      event.bus.fire(event.locationChanged, new nav.Location(uiContext.id, element.id, alternateNamesList.id));
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      element.classes.toggle(FOCUS, active);
      if(active) {
        alternateNamesList.focus();
      }
    });
  }

  void render(model.Reception reception) {
    alternateNamesList.children.clear();

    for(var value in reception.alternateNameList) {
      alternateNamesList.children.add(new LIElement()
                        ..text = value.value);
    }
  }
}
