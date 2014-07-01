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

  static const String   className = '${libraryName}.ReceptionEvents';
  static const String NavShortcut = 'A'; 
  
  final Context       context;
  final Element       element;
  Element         get header         => this.element.querySelector('#company-events-header');
  UListElement    get listElement    => this.element.querySelector('#company_events_list');
  List<Element>   get nudges         => this.element.querySelectorAll('.nudge');


  Element lastActive = null;
  FieldSetElement get newEventWidget => this.element.querySelector('#receptioninfo-calendar-event-create');
  TextAreaElement     get newEventField  => this.element.querySelector('.contact-calendar-event-create-body');

  ///Dateinput starts fields:
  InputElement get startsHourField   => this.newEventWidget.querySelector('.contactinfo-calendar-event-create-starts-hour');
  InputElement get startsMinuteField => this.newEventWidget.querySelector('.contactinfo-calendar-event-create-starts-minute');
  InputElement get startsDayField    => this.newEventWidget.querySelector('.contactinfo-calendar-event-create-starts-day');
  InputElement get startsMonthField  => this.newEventWidget.querySelector('.contactinfo-calendar-event-create-starts-month');
  InputElement get startsYearField   => this.newEventWidget.querySelector('.contactinfo-calendar-event-create-starts-year');

  ///Dateinput ends fields:
  InputElement get endsHourField   => this.newEventWidget.querySelector('.contactinfo-calendar-event-create-ends-hour');
  InputElement get endsMinuteField => this.newEventWidget.querySelector('.contactinfo-calendar-event-create-ends-minute');
  InputElement get endsDayField    => this.newEventWidget.querySelector('.contactinfo-calendar-event-create-ends-day');
  InputElement get endsMonthField  => this.newEventWidget.querySelector('.contactinfo-calendar-event-create-ends-month');
  InputElement get endsYearField   => this.newEventWidget.querySelector('.contactinfo-calendar-event-create-ends-year');

  ///Dateinput getter values
  int get startsHourValue   => int.parse(this.startsHourField.value);
  int get startsMinuteValue => int.parse(this.startsMinuteField.value);
  int get startsDayValue    => int.parse(this.startsDayField.value);
  int get startsMonthValue  => int.parse(this.startsMonthField.value);
  int get startsYearValue   => int.parse(this.startsYearField.value);

  int get endsHourValue   => int.parse(this.endsHourField.value);
  int get endsMinuteValue => int.parse(this.endsMinuteField.value);
  int get endsDayValue    => int.parse(this.endsDayField.value);
  int get endsMonthValue  => int.parse(this.endsMonthField.value);
  int get endsYearValue   => int.parse(this.endsYearField.value);

  ///Dateinput setters
  void set startsHourValue   (int value) {this.startsHourField.value = value.toString();}
  void set startsMinuteValue (int value) {this.startsMinuteField.value = value.toString();}
  void set startsDayValue    (int value) {this.startsDayField.value = value.toString();}
  void set startsMonthValue  (int value) {this.startsMonthField.value = value.toString();}
  void set startsYearValue   (int value) {this.startsYearField.value = value.toString();}

  void set endsHourValue   (int value) {this.endsHourField.value = value.toString();}
  void set endsMinuteValue (int value) {this.endsMinuteField.value = value.toString();}
  void set endsDayValue    (int value) {this.endsDayField.value = value.toString();}
  void set endsMonthValue  (int value) {this.endsMonthField.value = value.toString();}
  void set endsYearValue   (int value) {this.endsYearField.value = value.toString();}

  DateTime get _selectedStartDate =>
     new DateTime(this.startsYearValue, this.startsMonthValue, this.startsDayValue, this.startsHourValue, this.startsMinuteValue);

  DateTime get _selectedEndDate =>
      new DateTime(this.endsYearValue, this.endsMonthValue, this.endsDayValue, this.endsHourValue, this.endsMinuteValue);

  void set _selectedStartDate (DateTime newTime) {
    this.startsDayValue    = newTime.day;
    this.startsMonthValue  = newTime.month;
    this.startsYearValue   = newTime.year;
    this.startsHourValue   = newTime.hour;
    this.startsMinuteValue = newTime.minute;
   }

   void set _selectedEndDate (DateTime newTime) {
     this.endsDayValue    = newTime.day;
     this.endsMonthValue  = newTime.month;
     this.endsYearValue   = newTime.year;
     this.endsHourValue   = newTime.hour;
     this.endsMinuteValue = newTime.minute;
   }
   
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  ReceptionEvents(Element this.element, Context this.context) {
    ///Navigation shortcuts
    this.element.insertBefore(new Nudge(NavShortcut).element,  this.header);
    keyboardHandler.registerNavShortcut(NavShortcut, (_) => Controller.Context.changeLocation(new nav.Location(context.id, element.id, listElement.id)));
    
    assert(element.attributes.containsKey(defaultElementId));

    this.header.text = ReceptionEventsLabels.title;

    this.newEventWidget.hidden = true;
    _registerEventListeners();
  }

  void _registerEventListeners() {
    
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);
    
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
      element.classes.toggle(FOCUS, active);
      if(active) {
        listElement.focus();
      }
    });

    event.bus.on(event.CreateNewContactEvent).listen((_) {
      if(nav.Location.isActive(this.element)) {
        //Toggle the widget to create new calendar events.
        this.newEventWidget.hidden = !this.newEventWidget.hidden;

        //Toggle the list of events based on the widget for creatings visability.
        this.listElement.hidden = !this.newEventWidget.hidden;

        if (!this.newEventWidget.hidden) {
          this._selectedStartDate = new DateTime.now();
          this._selectedEndDate = new DateTime.now().add(new Duration(hours: 1));
          this.newEventField.value = "";

          this.lastActive = document.activeElement;
          this.newEventField.focus();
        } else {
          if (this.lastActive != null) {
            this.lastActive.focus();
          }
        }
      }
    });

    event.bus.on(event.Save).listen((_) {
      if (nav.Location.isActive(element) && !this.newEventWidget.hidden) {
        (new model.CalendarEvent.forReception(model.Reception.selectedReception.ID)
          ..content = this.newEventField.value
          ..beginsAt = this._selectedStartDate
          ..until    = this._selectedEndDate
         ).save().then((_) {
          this.newEventWidget.hidden = true;
          this.listElement.hidden = !this.newEventWidget.hidden;
        });
      }
    });

    model.CalendarEventList.events.on(model.CalendarEventList.reload).listen((Map eventStub) {
      const String context = '${className}.reload (listener)';

      log.debugContext(eventStub.toString(), context);

      if (eventStub['receptionID'] == model.Reception.selectedReception.ID && !eventStub.containsKey('contactID')) {
        log.debugContext('Reloading calendarlist for ${eventStub['receptionID']}', context);
        storage.Reception.calendar(model.Reception.selectedReception.ID).then((model.CalendarEventList eventList) {
            this._render(eventList);
          }).catchError((error) {
            log.error('${className}._registerEventListeners Error while fetching reception calendar ${error}');
          });
      } else {
        log.debugContext('Skipping reloading calendarlist for ${eventStub['receptionID']} (not selected)', context);
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
