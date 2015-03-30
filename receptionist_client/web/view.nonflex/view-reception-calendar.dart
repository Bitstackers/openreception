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

/**
 * Calendar widget.
 *
 * Hooks into Model.Reception event stream and responds to the following events:
 *  - ReceptionChanged
 *  - ContactChanged
 */
class ReceptionCalendar {
  static const String   className   = '${libraryName}.ReceptionEvents';
  static const String NavShortcut   = 'A';

  bool get muted    => this.context != Context.current;
  bool get _inFocus => nav.Location.isActive(this.element);

  final Context            context;
  final Element            element;
  final Controller.HotKeys hotKeys = new Controller.HotKeys();
        nav.Location       location;

  Element         get header          => this.element.querySelector('#${Id.receptionEventsHeader}');
  UListElement    get eventList       => this.element.querySelector('#${Id.receptionEventsList}');
  List<Element>   get nudges          => this.element.querySelectorAll('.nudge');

  LIElement       get selectedElement
    => this.eventList.children.firstWhere((LIElement child)
      => child.classes.contains(CssClass.selected),
         orElse : () => new LIElement()..hidden = true..value = model.CalendarEvent.noID);

  void            set selectedElement (LIElement element) {
    assert (element != null);

    this.selectedElement.classes.toggle(CssClass.selected, false);
    element.classes.toggle(CssClass.selected, true);

    if (_inFocus) {
      element.focus();
    }
  }

  Element lastActive = null;
  InputElement    get eventIDField     => this.element.querySelector('.${CssClass.calendarEventId}');
  int             get eventID          => int.parse(this.eventIDField.value);
  void            set eventID (int ID)   {this.eventIDField.value = ID.toString();}
  FieldSetElement get newEventWidget   => this.element.querySelector('#${Id.receptionCalendarEventCreate}');
  TextAreaElement get newEventField    => this.element.querySelector('.${CssClass.contactCalendarEventCreateBody}');

  ///Dateinput starts fields:
  InputElement get startsHourField   => this.newEventWidget.querySelector('.${CssClass.contactCalendarEventCreateStartsHour}');
  InputElement get startsMinuteField => this.newEventWidget.querySelector('.${CssClass.contactCalendarEventCreateStartsMinute}');
  InputElement get startsDayField    => this.newEventWidget.querySelector('.${CssClass.contactCalendarEventCreateStartsDay}');
  InputElement get startsMonthField  => this.newEventWidget.querySelector('.${CssClass.contactCalendarEventCreateStartsMonth}');
  InputElement get startsYearField   => this.newEventWidget.querySelector('.${CssClass.contactCalendarEventCreateStartsYear}');

  ///Dateinput ends fields:
  InputElement get endsHourField   => this.newEventWidget.querySelector('.${CssClass.contactCalendarEventEndsHour}');
  InputElement get endsMinuteField => this.newEventWidget.querySelector('.${CssClass.contactCalendarEventEndsMinute}');
  InputElement get endsDayField    => this.newEventWidget.querySelector('.${CssClass.contactCalendarEventEndsDay}');
  InputElement get endsMonthField  => this.newEventWidget.querySelector('.${CssClass.contactCalendarEventEndsMonth}');
  InputElement get endsYearField   => this.newEventWidget.querySelector('.${CssClass.contactCalendarEventEndsYear}');

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

  ReceptionCalendar(Element this.element, Context this.context) {
    assert(element.attributes.containsKey(defaultElementId));

    this.location = new nav.Location(context.id, element.id, eventList.id);

    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);

    this.header.children = [Icon.Calendar,
                            new SpanElement()..text = Label.ReceptionEvents,
                            new Nudge(NavShortcut).element];

    this.newEventWidget.hidden = true;
    _registerEventListeners();
  }

  /**
   * Create a new calendar event.
   */
  void _createEvent() {
    //Toggle the widget to create new calendar events.
    this.newEventWidget.hidden = !this.newEventWidget.hidden;

    //Toggle the list of events based on the widget for creatings visability.
    this.eventList.hidden = !this.newEventWidget.hidden;

    if(!this.newEventWidget.hidden) {
      this._selectedStartDate = new DateTime.now();
      this._selectedEndDate = new DateTime.now().add(new Duration(hours: 1));
      this.newEventField.value = "";
      this.eventID = model.CalendarEvent.noID;

      this.lastActive = document.activeElement;
      this.newEventField.focus();
    } else {
      if(this.lastActive != null) {
        this.lastActive.focus();
      }
    }
  }

  /**
   * Delete event handler.
   * Responds to delete commands and deletes the event currently being edited.
   */
  void _deleteEvent() {
    if(!this.newEventWidget.hidden) {
      model.deleteCalendarEvent(this._getEvent()).then((_) {
        this.newEventWidget.hidden = true;
        this.eventList.hidden = !this.newEventWidget.hidden;
      });
    }
  }

  /**
   * Edit event handler.
   */
  void _editEvent() {
    //Toggle the widget to create new calendar events.
    this.newEventWidget.hidden = !this.newEventWidget.hidden;

    //Toggle the list of events based on the widget for creatings visability.
    this.eventList.hidden = !this.newEventWidget.hidden;
    int eventID = this.selectedElement.value;

    if (!this.newEventWidget.hidden) {
      storage.Reception.calendar(model.Reception.selectedReception.ID)
                .then((List<model.CalendarEvent> events) {

        model.CalendarEvent selectedEvent = model.findEvent(events, eventID);

        this._selectedStartDate = selectedEvent.startTime;
        this._selectedEndDate = selectedEvent.stopTime;
        this.newEventField.value = selectedEvent.content;
        this.eventID = eventID;
      });

      this.lastActive = document.activeElement;
      this.newEventField.focus();
    } else {
      if (this.lastActive != null) {
        this.lastActive.focus();
      }
    }
  }

  /**
   * Harvests the typed information from the widget and returns a CalendarEvent
   * object.
   */
  model.CalendarEvent _getEvent() {
    assert (_inFocus && !this.newEventWidget.hidden);

    return new model.CalendarEvent.forReception(model.Reception.selectedReception.ID)
              ..ID       = this.eventID
              ..content  = this.newEventField.value
              ..beginsAt = this._selectedStartDate
              ..until    = this._selectedEndDate;
  }

  /**
   * Register all event listeners for this widget.
   */
  void _registerEventListeners() {
    hotKeys.onCtrlBackspace.listen((_) => _inFocus ? _deleteEvent() : null);
    hotKeys.onCtrlE.listen((_) => _inFocus ? _editEvent() : null);
    hotKeys.onCtrlK.listen((_) => _inFocus ? _createEvent() : null);
    hotKeys.onCtrlS.listen((_) => _inFocus ? _saveEvent() : null);

    /// Nudge boiler plate code.
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    model.Reception.onReceptionChange..listen((model.Reception reception) {
      Storage.Reception.calendar(reception.ID).then((List<model.CalendarEvent> events) {
        print(events);
        _render(events);
      });
    });

    element.onClick.listen((Event event) {
      if (!_inFocus) {
        this._select(null);
      }
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      element.classes.toggle(CssClass.focus, location.targets(this.element));

      if (location.targets(this.element)) {
        this.selectedElement.focus();
      }
    });

    this.eventList.onKeyDown.listen((KeyboardEvent e) {
      LIElement lastFocusLI = this.selectedElement;
      LIElement newFocusLI;

      if (lastFocusLI == null) {
        newFocusLI = this.eventList.children.first;
      } else if (e.keyCode == Keys.DOWN){
        newFocusLI = lastFocusLI.nextElementSibling;
        e.preventDefault();
      } else if (e.keyCode == Keys.UP){
        newFocusLI = lastFocusLI.previousElementSibling;
        e.preventDefault();
      }
      if (newFocusLI != null) {
        selectedElement = newFocusLI;
      }
    });

    model.CalendarEvent.events.on(model.CalendarEvent.reload).listen((Map eventStub) {
      const String context = '${className}.reload (listener)';

      log.debugContext(eventStub.toString(), context);

      if (eventStub['receptionID'] == model.Reception.selectedReception.ID && !eventStub.containsKey('contactID')) {
        log.debugContext('Reloading calendarlist for ${eventStub['receptionID']}', context);
        storage.Reception.calendar(model.Reception.selectedReception.ID).then((List<model.CalendarEvent> events) {
            this._render(events);
          }).catchError((error) {
            log.error('${className}._registerEventListeners Error while fetching reception calendar ${error}');
          });
      } else {
        log.debugContext('Skipping reloading calendarlist for ${eventStub['receptionID']} (not selected)', context);
      }
    });
  }

  /**
   * TODO (TL): comment
   */
  void _render(List<model.CalendarEvent> events) {
    List<model.CalendarEvent> listCopy = []..addAll(events)
                                           ..sort();

    Element eventToDOM (model.CalendarEvent event) {
      String html = '''
        <li class="${event.active ? CssClass.receptionEventsActive : ''}" value=${event.ID}>
          <table class="${CssClass.calendarEventTable}">
            <tbody>
              <tr>
                <td class="${CssClass.calendarEventContent} ${event.active ? '' : CssClass.calendarEventNotActive}">
                  ${event.content}
                <td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td class="${CssClass.calendarEventTimestamp} ${event.active ? '' : CssClass.calendarEventNotActive}">
                  ${event.start} - ${event.stop}
                <td>
              </tr>
            </tfoot>
          </table>
        </li>
      ''';

      return new DocumentFragment.html(html).children.first..tabIndex = -1;
    }

    eventList.children = listCopy.map((model.CalendarEvent event) {
      Element domElement = eventToDOM(event);
              domElement.onClick.listen((_) => this.selectedElement = domElement);

      return domElement;
    }).toList(growable: false);

    if (eventList.children.length > 0) {
      this.selectedElement = eventList.children.first;
    }
  }

  /**
   * Save event handler.
   */
  void _saveEvent() {
    if(!this.newEventWidget.hidden) {
      model.saveCalendarEvent(this._getEvent()).then((_) {
        this.newEventWidget.hidden = true;
        this.eventList.hidden = !this.newEventWidget.hidden;
      });
    }
  }

  /**
   * Selects the widget and puts the default element in focus.
   */
  void _select(_) {
    if (!this.muted) {
      Controller.Context.changeLocation(this.location);
    }
  }
}
