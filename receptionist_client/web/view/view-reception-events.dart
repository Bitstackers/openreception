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

abstract class ReceptionEventsLabels {
  static const String title    = 'Kalender';
}

/**
 * Calendar widget. 
 * 
 * Hooks into Model.Reception event stream and responds to the following events:
 *  - ReceptionChanged 
 *  - ContactChanged
 */
class ReceptionEvents {
    
  Context      context;
  Element      element;
  Element      get header  => this.element.querySelector('legend');
  UListElement get listElement => this.element.querySelector('ul');

  ReceptionEvents(Element this.element, Context this.context) {
    assert(element.attributes.containsKey(defaultElementId));
    
    this.header.text = ReceptionEventsLabels.title;
    _registerEventListeners();
  }

  void _registerEventListeners() {
    event.bus.on(event.receptionChanged).listen((model.Reception reception) {
      Storage.Reception.calendar(reception.ID).then((model.CalendarEventList events) {
        _render(events);
      });
    });

    element.onClick.listen((_) {
      Controller.Context.changeLocation(new nav.Location(context.id, element.id, listElement.id));
    });
    
    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      //element.classes.toggle(FOCUS, active);
      if(active) {
        listElement.focus();
      }
    });
  }

  String getClass(model.CalendarEvent event) {
    return event.active ? 'company-events-active' : '';
  }

  void _render(model.CalendarEventList calendar) {
    listElement.children.clear();

    for(model.CalendarEvent event in calendar) {
      String html = '''
        <li class="${event.active ? 'company-events-active': ''}">
          <table class="calendar-event-table">
            <tbody>
              <tr>
                <td class="calendar-event-content ${event.active ? '' : 'calendar-event-notactive'}">
                  ${event}
                <td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td class="calendar-event-timestamp ${event.active ? '' : 'calendar-event-notactive'}">
                  ${event.start} - ${event.stop}
                <td>
              </tr>
            </tfoot>
          </table>
        </li>
      ''';

      listElement.children.add(new DocumentFragment.html(html).children.first);
    }
  }
}
