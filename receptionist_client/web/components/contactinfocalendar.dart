part of components;

class ContactInfoCalendar {
  Box           box;
  UListElement  calendarBody;
  String        calendarTitle = 'Kalender';
  model.Contact contact;
  Context       context;
  DivElement    element;
  Element       widget;
  
  model.CalendarEventList eventList;
  model.Reception reception;

  bool hasFocus = false;

  ContactInfoCalendar(DivElement this.element, Context this.context, Element this.widget) {
    SpanElement calendarHeader = new SpanElement()
      ..classes.add('boxheader')
      ..text = calendarTitle;

    calendarBody = new UListElement()
      ..tabIndex = -1
      ..classes.addAll(['contact-info-container', 'zebra'])
      ..id = 'contact-calendar';

    box = new Box.withHeader(element, calendarHeader, calendarBody);

    _registerEventListeners();
  }

  void _registerEventListeners() {
//    calendarBody.onFocus.listen((_) {
//      setFocus(calendarBody.id);
//    });
//
//    element.onClick.listen((_) {
//      setFocus(calendarBody.id);
//    });
//
//    event.bus.on(event.focusChanged).listen((Focus value) {
//      if(value.old == calendarBody.id) {
//        hasFocus = false;
//        element.classes.remove(FOCUS);
//      }
//
//      if(value.current == calendarBody.id) {
//        hasFocus = true;
//        element.classes.add(FOCUS);
//        calendarBody.focus();
//      }
//    });
//
//    context.registerFocusElement(calendarBody);
    
    calendarBody.onClick.listen((MouseEvent e) {
      event.bus.fire(event.locationChanged, new nav.Location(context.id, widget.id, calendarBody.id));
    });
    
    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == widget.id;
      widget.classes.toggle(FOCUS, active);
      if(location.elementId == calendarBody.id) {
        calendarBody.focus();
      }
    });

    event.bus.on(event.receptionChanged).listen((model.Reception value) {
      reception = value;
    });
    
    event.bus.on(event.contactChanged).listen((model.Contact value) {
      contact = value;
      if(value != model.nullContact) {
        protocol.getContactCalendar(reception.id, contact.id).then((protocol.Response<model.CalendarEventList> response) {
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