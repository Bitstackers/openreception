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

abstract class CompanySalesCallsLabels {
  static const String HeaderText = 'Sælgere / Analyser';
}

class CompanySalesCalls {
  Box          box;
  Context      context;
  final Element   element;
  bool         hasFocus  = false;
  Element      get header           => this.element.querySelector('legend');
  UListElement get instructionList  => this.element.querySelector('#${id.COMPANY_SALES_LIST}');

  CompanySalesCalls(Element this.element, Context this.context) {
    String defaultElementId = 'data-default-element';
    assert(element.attributes.containsKey(defaultElementId));
    
    header.text = CompanySalesCallsLabels.HeaderText;

    registerEventListeners();
  }

  void registerEventListeners() {
    event.bus.on(event.receptionChanged).listen(render);

    element.onClick.listen((_) {
      event.bus.fire(event.locationChanged, new nav.Location(context.id, element.id, instructionList.id));
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      element.classes.toggle(FOCUS, active);
      if(active) {
        instructionList.focus();
      }
    });
    
  }

  void render(model.Reception reception) {
    instructionList.children.clear();

    for(var value in reception.crapcallHandlingList) {
      instructionList.children.add(new LIElement()
                        ..text = value.value);
    }
  }
}
