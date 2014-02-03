part of components;

class ContactInfoCalendar {
  Box           box;
  UListElement  calendarBody;
  String        calendarTitle = 'Kalender';
  model.Contact contact;
  Context       context;
  DivElement    element;
  
  model.CalendarEventList eventList;
  model.Reception reception;

  bool hasFocus = false;

  ContactInfoCalendar(DivElement this.element, Context this.context) {
    SpanElement calendarHeader = new SpanElement()
      ..classes.add('boxheader')
      ..text = calendarTitle;

    calendarBody = new UListElement()
      ..classes.addAll(['contact-info-container', 'zebra'])
      ..id = 'contact-calendar';

    box = new Box.withHeader(element, calendarHeader, calendarBody);

    event.bus.on(event.receptionChanged).listen((model.Reception value) {
      reception = value;
    });
    
    event.bus.on(event.contactChanged).listen((model.Contact value) {
      contact = value;
      protocol.getContactCalendar(reception.id, contact.id).then((protocol.Response<model.CalendarEventList> response) {
        if (response.status == protocol.Response.OK) {
          eventList = response.data;
        } else {
          log.error('ContactInfoCalendar.ContactInfoCalendar. Request for getContactCalendar failed: ${response.statusText}');
        }
        render();
      });
    });

    _registerEventListeners();
  }

  void _registerEventListeners() {
    calendarBody.onFocus.listen((_) {
      setFocus(calendarBody.id);
    });

    element.onClick.listen((_) {
      setFocus(calendarBody.id);
    });

    event.bus.on(event.focusChanged).listen((Focus value) {
      if(value.old == calendarBody.id) {
        hasFocus = false;
        element.classes.remove(focusClassName);
      }

      if(value.current == calendarBody.id) {
        hasFocus = true;
        element.classes.add(focusClassName);
        calendarBody.focus();
      }
    });

    context.registerFocusElement(calendarBody);
  }

  void render() {
    calendarBody.children.clear();
    if(eventList == null) {
      return;
    }
    
    for(model.CalendarEvent event in eventList) {
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