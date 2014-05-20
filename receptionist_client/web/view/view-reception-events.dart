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


/**
 * Calendar widget. 
 * 
 * Hooks into Model.Calendar data feed.
 * 
 * Responds to global events:
 *  - ReceptionChanged 
 *  - ContactChanged
 */
part of view;

class ReceptionEvents {
    
  Context      context;
  DivElement   element;
  SpanElement  header;
  String       title    = 'Kalender';
  UListElement ul;


  ReceptionEvents(DivElement this.element, Context this.context) {
    String defaultElementId = 'data-default-element';
    assert(element.attributes.containsKey(defaultElementId));
    
    this.ul = element.querySelector('#${id.COMPANY_EVENTS_LIST}');

    _registerEventListeners();
  }

  void _registerEventListeners() {
    event.bus.on(event.receptionChanged).listen((model.Reception reception) {
      Storage.Reception.calendar(reception.ID).then((model.CalendarEventList events) {
        _render(events);
      });
    });

    element.onClick.listen((_) {
      Controller.Context.changeLocation(new nav.Location(context.id, element.id, ul.id));
    });
    
    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      //element.classes.toggle(FOCUS, active);
      if(active) {
        ul.focus();
      }
    });
  }

  String getClass(model.CalendarEvent event) {
    return event.active ? 'company-events-active' : '';
  }

  void _render(model.CalendarEventList calendar) {
    ul.children.clear();

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

      ul.children.add(new DocumentFragment.html(html).children.first);
    }
  }
}
