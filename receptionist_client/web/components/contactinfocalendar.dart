part of components;

abstract class CalendarLabels {
  static final String CALENDAR = 'Kalender';
}

/**
 * View for the Contact's calendar.
 * Listens for  
 *  - global contactChanged events
 *  - 
 */
class ContactInfoCalendar {
  UListElement calendarBody;
  model.Contact currentContact;
  Context context;
  DivElement element;
  Element widget;

  model.CalendarEventList eventList;
  model.Reception reception;

  bool hasFocus = false;

  ContactInfoCalendar(DivElement this.element, Context this.context, Element this.widget) {
    this.calendarBody = this.element.querySelector("#contact-calendar");
    this._setTitle(CalendarLabels.CALENDAR);
    _registerEventListeners();
  }
  
  void _setTitle (String newTitle) {
    this.element.querySelectorAll(".calendar-title").forEach((var node) {
        node..text = newTitle;
    }); 
  }

  void _registerEventListeners() {
    calendarBody.onClick.listen((MouseEvent e) {
      event.bus.fire(event.locationChanged, new nav.Location(context.id, widget.id, calendarBody.id));
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == widget.id;
      widget.classes.toggle(FOCUS, active);
      if (location.elementId == calendarBody.id) {
        calendarBody.focus();
      }
    });

    event.bus.on(event.receptionChanged).listen((model.Reception reception) {
      this.reception = reception;
    });

    event.bus.on(event.contactChanged).listen((model.Contact newContact) {
      this.currentContact = newContact;
      
      /*  */
      if (newContact != model.Contact.noContact) {
        protocol.getContactCalendar(reception.id, this.currentContact.id).then((protocol.Response<model.CalendarEventList> response) {
          if (response.status == protocol.Response.OK) {
            eventList = response.data;
          } else {
            log.error('ContactInfoCalendar.ContactInfoCalendar. Request for getContactCalendar failed: ${response.statusText}');
          }
          render();
        }).catchError((error) {
          log.error('components.ContactInfoCalendar._registerEventListeners Error while fetching contact calendar ${error}');
        });
      }
    });

  }

  void render() {
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

      calendarBody.children.add(new DocumentFragment.html(html).children.first);
    }
  }
}
