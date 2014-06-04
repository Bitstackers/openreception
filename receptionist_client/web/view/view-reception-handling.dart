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

abstract class ReceptionHandlingLabels {
  static const String title = 'Håndtering';
}

/**
 * Widget for cleartext instruction used for instructing users on how to 
 * handle the call for the reception.
 * 
 * It is a selectable context, and thus subscribes for 
 * [event.locationChanged] events.
 * 
 * The data used in this widget is [model.Reception].
 */
class ReceptionHandling {

  static const String className = '${libraryName}.ReceptionHandling';

  Context          context;
  Element          element;
  UListElement get listElement => this.element.querySelector('ul');
  Element      get header      => this.element.querySelector('legend');

  ReceptionHandling(Element this.element, Context this.context) {
    assert(element.attributes.containsKey(defaultElementId));

    this.header.text = ReceptionHandlingLabels.title;
    _registerEventListeners();
  }

  void _registerEventListeners() {
    event.bus.on(event.receptionChanged).listen(render);
    event.bus.on(event.locationChanged).listen((nav.Location location) => location.setFocusState(element, listElement));
    element.onClick.listen((_) => event.bus.fire(event.locationChanged, new nav.Location(context.id, element.id, listElement.id)));
  }

  void render(model.Reception reception) {
    listElement.children.clear();


    reception.handlingList.forEach((value) => listElement.children.add(new LIElement()..text = value.value));
  }
}
