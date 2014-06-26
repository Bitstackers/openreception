part of view;

abstract class CalendarLabels {
  static final String calendar            = 'Kalender';
  static final String newEventPlaceholder = 'Opret aftale';
}

/**
 * View for the Contact's calendar.
 * Listens for
 *  - global contactChanged events
 *  -
 */
class ContactInfoCalendar {

  static final String  id        = constant.ID.CALL_MANAGEMENT;
  static const String  className = '${libraryName}.ContactInfoCalendar';
  final        Element element;
  final        Context context;
               Element lastActive = null;

  bool                get active         => nav.Location.isActive(this.element);
  InputElement        get numberField    => this.element.querySelector('#call-originate-number-field');
  ButtonElement       get dialButton     => this.element.querySelector('.call-originate-number-button');
  List<Element>       get nuges          => this.element.querySelectorAll('.nudge');
  Element             get newEventWidget => this.element.querySelector('.contactinfo-calendar-event-create');
  TextAreaElement     get newEventField  => this.element.querySelector('.contact-calendar-event-create-body');
  List<InputElement>  get inputFields    => this.element.querySelectorAll('input');

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


  UListElement get calendarBody => this.element.querySelector("#contact-calendar");
  model.Contact currentContact;
  Element widget;

  model.Reception reception;

  bool hasFocus = false;

  void set inputDisabled (bool disabled) {

    this.newEventField.disabled = disabled;
    this.inputFields.forEach((InputElement element) => element.disabled = disabled);
  }


  ContactInfoCalendar(Element this.element, Context this.context, Element this.widget) {
    this._setTitle(CalendarLabels.calendar);

    newEventField.placeholder = CalendarLabels.newEventPlaceholder;
    this.newEventWidget.hidden = true;
    _registerEventListeners();

  }

  void _setTitle (String newTitle) {
    this.element.querySelectorAll(".calendar-title").forEach((var node) {
        node.text = newTitle;
    });
  }


  void _registerEventListeners() {
    calendarBody.onClick.listen((MouseEvent e) {
      Controller.Context.changeLocation(new nav.Location(context.id, widget.id, calendarBody.id));
    });

    void onkeydown(KeyboardEvent e) {
      LIElement li = this.calendarBody.children.firstWhere((LIElement child) => child == document.activeElement);
        if (li == null) {
          li = this.calendarBody.children.first;
        } else if (e.keyCode == Keys.DOWN){
          li = li.nextElementSibling;
        } else if (e.keyCode == Keys.UP){
          li = li.previousElementSibling;
        }
        if (li != null) {
          li.focus();
        }
        e.preventDefault();
    }

    //this.calendarBody.onKeyDown.listen(onkeydown);

    event.bus.on(event.locationChanged).listen((nav.Location location) {

      element.classes.toggle(FOCUS, this.element.id == location.widgetId);
      if (location.elementId == calendarBody.id) {
        calendarBody.focus();
      }
    });

    event.bus.on(event.CreateNewContactEvent).listen((_) {

      if(nav.Location.isActive(this.element)) {
        this.newEventWidget.hidden = !this.newEventWidget.hidden;

        this.calendarBody.hidden = !this.newEventWidget.hidden;
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
      if (!this.newEventWidget.hidden) {
        (new model.CalendarEvent.forContact(this.currentContact.id, this.currentContact.receptionID)
          ..content = this.newEventField.value
          ..beginsAt = this._selectedStartDate
          ..until    = this._selectedEndDate
          ).save().then((_) {
          this.newEventWidget.hidden = true;
          this.calendarBody.hidden = !this.newEventWidget.hidden;
        });
      }
    });


    model.CalendarEventList.events.on(model.CalendarEventList.reload).listen((Map eventStub) {
      const String context = '${className}.reload (listener)';

      log.debugContext(eventStub.toString(), context);

      if (eventStub['contactID'] == this.currentContact.id && eventStub['receptionID'] == this.reception.ID) {
        log.debugContext('Reloading calendarlist for ${eventStub['contactID']}@${eventStub['receptionID']}', context);
        storage.Contact.calendar(this.currentContact.id, reception.ID).then((model.CalendarEventList eventList) {
            this.render(eventList);
          }).catchError((error) {
            log.error('components.ContactInfoCalendar._registerEventListeners Error while fetching contact calendar ${error}');
          });
      } else {
        log.debugContext('Skipping reloading calendarlist for ${eventStub['contactID']}@${eventStub['receptionID']} (not selected)', context);
      }
    });

    event.bus.on(event.receptionChanged).listen((model.Reception reception) {
      this.reception = reception;
    });

    event.bus.on(event.contactChanged).listen((model.Contact newContact) {
      this.currentContact = newContact;

      /*  */
      if (newContact != model.Contact.noContact) {
        storage.Contact.calendar(this.currentContact.id, reception.ID).then((model.CalendarEventList eventList) {
          this.render(eventList);
        }).catchError((error) {
          log.error('components.ContactInfoCalendar._registerEventListeners Error while fetching contact calendar ${error}');
        });
      }
    });
  }

  void render(model.CalendarEventList eventList) {
    calendarBody.children.clear();
    if (eventList == null) {
      return;
    }

    for (model.CalendarEvent event in eventList) {
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
      //frag.tabIndex = 1;
      calendarBody.children.add(frag);
    }
  }

}
