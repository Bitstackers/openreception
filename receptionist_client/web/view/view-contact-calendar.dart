/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

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
 * View for the Contact's calendar.
 * Listens for
 *  - global contactChanged events
 *  -
 */
class ContactCalendar {
  static const String className      = '${libraryName}.ContactInfoSearch';
  static const String NavShortcut    = 'K';
  static const String EditShortcut   = 'E';
  static const String SaveShortcut   = 'S';
  static const String DeleteShortcut = 'Backspace';

  final Context            context;
  final Element            element;
  final Controller.HotKeys hotKeys    = new Controller.HotKeys();
        Element            lastActive = null;
        nav.Location       location;

  bool                get muted          => this.context != Context.current;
  bool                get _inFocus       => nav.Location.isActive(this.element);
  Element             get header         => this.element.querySelector('legend');
  bool                get active         => nav.Location.isActive(this.element);
  List<Element>       get nuges          => this.element.querySelectorAll('.nudge');
  Element             get newEventWidget => this.element.querySelector('.${CssClass.contactCalendarEventCreate}');
  TextAreaElement     get newEventField  => this.element.querySelector('.${CssClass.contactCalendarEventCreateBody}');
  List<InputElement>  get inputFields    => this.element.querySelectorAll('input');

  InputElement    get eventIDField     => this.element.querySelector('.${CssClass.calendarEventId}');
  int             get eventID          => int.parse(this.eventIDField.value);
  void            set eventID (int Id)   {this.eventIDField.value = Id.toString();}

  ///Dateinput starts fields:
  InputElement get startsHourField   => this.element.querySelector('.${CssClass.contactCalendarEventCreateStartsHour}');
  InputElement get startsMinuteField => this.element.querySelector('.${CssClass.contactCalendarEventCreateStartsMinute}');
  InputElement get startsDayField    => this.element.querySelector('.${CssClass.contactCalendarEventCreateStartsDay}');
  InputElement get startsMonthField  => this.element.querySelector('.${CssClass.contactCalendarEventCreateStartsMonth}');
  InputElement get startsYearField   => this.element.querySelector('.${CssClass.contactCalendarEventCreateStartsYear}');

  ///Dateinput ends fields:
  InputElement get endsHourField   => this.element.querySelector('.${CssClass.contactCalendarEventEndsHour}');
  InputElement get endsMinuteField => this.element.querySelector('.${CssClass.contactCalendarEventEndsMinute}');
  InputElement get endsDayField    => this.element.querySelector('.${CssClass.contactCalendarEventEndsDay}');
  InputElement get endsMonthField  => this.element.querySelector('.${CssClass.contactCalendarEventEndsMonth}');
  InputElement get endsYearField   => this.element.querySelector('.${CssClass.contactCalendarEventEndsYear}');

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

  List<Element>   get nudges    => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  UListElement get eventList => this.element.querySelector("#${Id.contactCalendarList}");
  model.Contact currentContact;
  Element widget;

  model.Reception reception;

  bool hasFocus = false;

  void set inputDisabled (bool disabled) {

    this.newEventField.disabled = disabled;
    this.inputFields.forEach((InputElement element) => element.disabled = disabled);
  }

  LIElement       get selectedElement
    => this.eventList.children.firstWhere((LIElement child)
      => child.classes.contains(CssClass.selected),
         orElse : () => new LIElement()..hidden = true..value = model.CalendarEvent.noID);

  void            set selectedElement (LIElement element) {
    assert (element != null);

    this.selectedElement.classes.toggle(CssClass.selected, false);
    element.classes.toggle(CssClass.selected, true);

    if (this._inFocus) {
      element.focus();
    }
  }

  ContactCalendar(Element this.element, Context this.context, Element this.widget) {
    this.header.children = [Icon.Calendar, new SpanElement()..text = Label.ContactCalendar, new Nudge(NavShortcut).element];

    this.location = new nav.Location(this.context.id, this.element.id, this.eventList.id);

    keyboardHandler.registerNavShortcut(NavShortcut, this._select);

    newEventField.placeholder = Label.CreateEvent;
    this.newEventWidget.hidden = true;
    _registerEventListeners();

  }

  /**
   * Delete event handler.
   * Responds to delete commands and deletes the event currently being edited.
   *
   * TODO:
   *   - Disable input fields and event handler when the save operation is
   *     in progress and re-enable it onDone.
   *   - Add error handling in the form of a UI notification.
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
   * Edit event handler
   */
  void _editEvent() {
    //Toggle the widget to create new calendar events.
    this.newEventWidget.hidden = !this.newEventWidget.hidden;

    //Toggle the list of events based on the widget for creatings visability.
    this.eventList.hidden = !this.newEventWidget.hidden;
    int eventID = this.selectedElement.value;

    if (!this.newEventWidget.hidden) {
      model.Contact.selectedContact.calendarEventList().then((List<model.CalendarEvent> eventList) {
        model.CalendarEvent event = model.CalendarEvent.findEvent(eventID, eventList);

        this._selectedStartDate = event.startTime;
        this._selectedEndDate = event.stopTime;
        this.newEventField.value = event.content;
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
   * Harvests the typed information from the widget and returns a CalendarEvent object.
   */
  model.CalendarEvent _getEvent() {
    assert (_inFocus && !this.newEventWidget.hidden);

    return new model.CalendarEvent.forContact(this.currentContact.ID, this.currentContact.receptionID)
              ..ID       = this.eventID
              ..content = this.newEventField.value
              ..beginsAt = this._selectedStartDate
              ..until    = this._selectedEndDate;
   }

  /**
   * Register all event listeners for this widget.
   */
  void _registerEventListeners() {
    hotKeys.onCtrlBackspace.listen((_) => _inFocus ? _deleteEvent() : null);
    hotKeys.onCtrlE.listen((_) => _inFocus ? _editEvent() : null);
    hotKeys.onCtrlS.listen((_) => _inFocus ? _saveEvent() : null);

    /// Nudge boiler plate code.
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    /// Focus this widget if it is clicked.
    element.onClick.listen((Event event) {
      if (!_inFocus) {
        this._select(null);
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

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      element.classes.toggle(CssClass.focus, this.element.id == location.widgetId);
      if (location.elementId == eventList.id) {
        eventList.focus();
      }
    });

    event.bus.on(event.CreateNewContactEvent).listen((_) {
      if(nav.Location.isActive(this.element)) {
        eventID = model.CalendarEvent.noID;
        this.newEventWidget.hidden = !this.newEventWidget.hidden;

        this.eventList.hidden = !this.newEventWidget.hidden;
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

    model.CalendarEvent.events.on(model.CalendarEvent.reload).listen((Map eventStub) {
      const String context = '${className}.reload (listener)';

      log.debugContext(eventStub.toString(), context);

      if (eventStub['contactID'] == this.currentContact.ID && eventStub['receptionID'] == this.reception.ID) {
        log.debugContext('Reloading calendarlist for ${eventStub['contactID']}@${eventStub['receptionID']}', context);
        storage.Contact.calendar(this.currentContact.ID, reception.ID).then((List<model.CalendarEvent> eventList) {
            this._render(eventList);
          }).catchError((error) {
            log.error('components.ContactInfoCalendar._registerEventListeners Error while fetching contact calendar ${error}');
          });
      } else {
        log.debugContext('Skipping reloading calendarlist for ${eventStub['contactID']}@${eventStub['receptionID']} (not selected)', context);
      }
    });

    event.bus.on(model.Reception.activeReceptionChanged).listen((model.Reception reception) {
      this.reception = reception;
    });

    event.bus.on(model.Contact.activeContactChanged).listen((model.Contact newContact) {
      this.currentContact = newContact;

      /*  */
      if (newContact != model.Contact.noContact) {
        storage.Contact.calendar(this.currentContact.ID, reception.ID).then((List<model.CalendarEvent> eventList) {
          this._render(eventList);
        }).catchError((error) {
          log.error('components.ContactInfoCalendar._registerEventListeners Error while fetching contact calendar ${error}');
        });
      }
    });
  }

  /**
   * Re-render the widget with [events].
   *
   * TODO:
   *   - Figure out how to store which element was selected before rendering
   *     to be able to re-select it again after the rendering.
   */
  void _render(List<model.CalendarEvent> events) {
    // Make a copy before sorting to preserve function purity.
    List<model.CalendarEvent> listCopy = []..addAll(events)
                                           ..sort();

    /// Event-to-DOM template.
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

    // Turn every event into a DOM node and attach click handler that selects the event.
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
   * Responds to save commands and stores the the data typed into the create
   * widget if it is visible. Ignore events if the calendarwidget is not in
   * focus.
   *
   * TODO:
   *   - Disable input fields and event handler when the save operation is
   *     in progress and re-enable it onDone.
   *   - Add error handling in the form of a UI notification.
   */
  void _saveEvent() {
    if (!this.newEventWidget.hidden) {
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
