part of view;

/**
 * View for the Contact's calendar.
 * Listens for
 *  - global contactChanged events
 *  -
 */
class ContactInfoCalendar {

  static const String className      = '${libraryName}.ContactInfoSearch';
  static const String NavShortcut    = 'K';
  static const String EditShortcut   = 'E';
  static const String SaveShortcut   = 'S';
  static const String DeleteShortcut = 'Backspace';
  static const String SelectedClass  = 'selected';

  static final String  id        = constant.ID.CALL_MANAGEMENT;
  final        Element element;
  final        Context context;
          nav.Location location;
               Element lastActive = null;
               bool get muted     => this.context != Context.current;
               bool get inFocus    => nav.Location.isActive(this.element);


  Element             get header                    => this.element.querySelector('legend');
  bool                get active         => nav.Location.isActive(this.element);
  InputElement        get numberField    => this.element.querySelector('#call-originate-number-field');
  ButtonElement       get dialButton     => this.element.querySelector('.call-originate-number-button');
  List<Element>       get nuges          => this.element.querySelectorAll('.nudge');
  Element             get newEventWidget => this.element.querySelector('.contactinfo-calendar-event-create');
  TextAreaElement     get newEventField  => this.element.querySelector('.contact-calendar-event-create-body');
  List<InputElement>  get inputFields    => this.element.querySelectorAll('input');

  InputElement    get eventIDField     => this.element.querySelector('.calendar-event-id');
  int             get eventID          => int.parse(this.eventIDField.value);
  void            set eventID (int ID)   {this.eventIDField.value = ID.toString();}

  ///Buttons
  ButtonElement get createButton => this.element.querySelector('button.create');
  ButtonElement get saveButton   => this.element.querySelector('button.save');
  ButtonElement get deleteButton => this.element.querySelector('button.delete');

  ///Dateinput starts fields:
  InputElement get startsHourField   => this.element.querySelector('.contactinfo-calendar-event-create-starts-hour');
  InputElement get startsMinuteField => this.element.querySelector('.contactinfo-calendar-event-create-starts-minute');
  InputElement get startsDayField    => this.element.querySelector('.contactinfo-calendar-event-create-starts-day');
  InputElement get startsMonthField  => this.element.querySelector('.contactinfo-calendar-event-create-starts-month');
  InputElement get startsYearField   => this.element.querySelector('.contactinfo-calendar-event-create-starts-year');

  ///Dateinput ends fields:
  InputElement get endsHourField   => this.element.querySelector('.contactinfo-calendar-event-create-ends-hour');
  InputElement get endsMinuteField => this.element.querySelector('.contactinfo-calendar-event-create-ends-minute');
  InputElement get endsDayField    => this.element.querySelector('.contactinfo-calendar-event-create-ends-day');
  InputElement get endsMonthField  => this.element.querySelector('.contactinfo-calendar-event-create-ends-month');
  InputElement get endsYearField   => this.element.querySelector('.contactinfo-calendar-event-create-ends-year');

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

  UListElement get eventList => this.element.querySelector("#contact-calendar");
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
      => child.classes.contains(SelectedClass),
         orElse : () => new LIElement()..hidden = true..value = model.CalendarEvent.noID);

  void            set selectedElement (LIElement element) {
    assert (element != null);

    this.selectedElement.classes.toggle(SelectedClass, false);
    element.classes.toggle(SelectedClass, true);

    if (this.inFocus) {
      element.focus();
    }
  }


  ContactInfoCalendar(Element this.element, Context this.context, Element this.widget) {
    this.header.children   = [Icon.Calendar, new SpanElement()..text = Label.ContactCalendar, new Nudge(NavShortcut).element];

    this.createButton.text = Label.Create;
    this.saveButton.text = Label.Update;
    this.deleteButton.text = Label.Delete;

    this.location = new nav.Location(this.context.id, this.element.id, this.eventList.id);

    ///Navigation shortcuts
    this.newEventWidget.insertBefore(new Nudge(SaveShortcut, type : Nudge.Command ).element,  this.saveButton);
    this.newEventWidget.insertBefore(new Nudge(SaveShortcut, type : Nudge.Command ).element,  this.createButton);
    this.newEventWidget.insertBefore(new Nudge(DeleteShortcut, type : Nudge.Command).element,  this.deleteButton);
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);

    newEventField.placeholder = Label.CreateEvent;
    this.newEventWidget.hidden = true;
    _registerEventListeners();

  }

  /**
   * Selects the widget and puts the default element in focus.
   */
  void _select(_) {
    if (!this.muted) {
      Controller.Context.changeLocation(this.location);
    }
  }

  /**
   * Harvests the typed information from the widget and returns a CalendarEvent object.
   */
  model.CalendarEvent _getEvent() {
    assert (this.inFocus && !this.newEventWidget.hidden);

    return new model.CalendarEvent.forContact(this.currentContact.ID, this.currentContact.receptionID)
              ..ID       = this.eventID
              ..content = this.newEventField.value
              ..beginsAt = this._selectedStartDate
              ..until    = this._selectedEndDate;
   }


  void _registerEventListeners() {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    this.element.onClick.listen((MouseEvent e) {
      Controller.Context.changeLocation(new nav.Location(this.context.id, this.element.id, this.eventList.id));
    });

    void listNavigation(KeyboardEvent e) {
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
    }

    this.eventList.onKeyDown.listen(listNavigation);

    event.bus.on(event.locationChanged).listen((nav.Location location) {

      element.classes.toggle(FOCUS, this.element.id == location.widgetId);
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
          this.createButton.hidden = false;
          this.saveButton.hidden = true;
          this.deleteButton.hidden = true;

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
      if (this.inFocus && !this.newEventWidget.hidden) {
        model.saveCalendarEvent(this._getEvent()).then((_) {
          this.newEventWidget.hidden = true;
          this.eventList.hidden = !this.newEventWidget.hidden;
        });
      }
    });

    event.bus.on(event.Delete).listen((_) {
      if (this.inFocus && !this.newEventWidget.hidden && this.eventID != model.CalendarEvent.noID) {
        model.deleteCalendarEvent(this._getEvent()).then((_) {
          this.newEventWidget.hidden = true;
          this.eventList.hidden = !this.newEventWidget.hidden;
        });
      }
    });

    event.bus.on(event.Edit).listen((_) {

      if(!this.inFocus) {
        return;
      }

      //Toggle the widget to create new calendar events.
      this.newEventWidget.hidden = !this.newEventWidget.hidden;

      //Toggle the list of events based on the widget for creatings visability.
      this.eventList.hidden = !this.newEventWidget.hidden;
      int eventID = this.selectedElement.value;

      if (!this.newEventWidget.hidden) {
        model.Contact.selectedContact.calendarEventList().then((List<model.CalendarEvent> eventList) {
          model.CalendarEvent event = model.CalendarEvent.findEvent(eventID, eventList);
          this.createButton.hidden = true;
          this.saveButton.hidden = false;
          this.deleteButton.hidden = false;

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
    });

    model.CalendarEvent.events.on(model.CalendarEvent.reload).listen((Map eventStub) {
      const String context = '${className}.reload (listener)';

      log.debugContext(eventStub.toString(), context);

      if (eventStub['contactID'] == this.currentContact.ID && eventStub['receptionID'] == this.reception.ID) {
        log.debugContext('Reloading calendarlist for ${eventStub['contactID']}@${eventStub['receptionID']}', context);
        storage.Contact.calendar(this.currentContact.ID, reception.ID).then((List<model.CalendarEvent> eventList) {
            this.render(eventList);
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

    event.bus.on(event.contactChanged).listen((model.Contact newContact) {
      this.currentContact = newContact;

      /*  */
      if (newContact != model.Contact.noContact) {
        storage.Contact.calendar(this.currentContact.ID, reception.ID).then((List<model.CalendarEvent> eventList) {
          this.render(eventList);
        }).catchError((error) {
          log.error('components.ContactInfoCalendar._registerEventListeners Error while fetching contact calendar ${error}');
        });
      }
    });
  }

  void render(List<model.CalendarEvent> events) {
    eventList.children.clear();
    if (events == null) {
      return;
    }

    for (model.CalendarEvent event in events) {
      String html = '''
        <li class="${event.active ? 'company-events-active': ''}">
          <table class="calendar-event-table">
            <tbody>
              <tr>
                <td class="calendar-event-content  ${event.active ? '' : 'calendar-event-notactive'}">
                  ${event}
                <td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td class="calendar-event-timestamp  ${event.active ? '' : 'calendar-event-notactive'}">
                  ${event.start} - ${event.stop}
                <td>
              </tr>
            </tfoot>
          </table>
        <li>
      ''';

      var frag = new DocumentFragment.html(html).children.first;
      frag.tabIndex = -1;
      frag.value = event.ID;
      eventList.children.add(frag);
    }
    if (eventList.children.length > 0) {
      this.selectedElement = eventList.children.first;
    }
  }

}
