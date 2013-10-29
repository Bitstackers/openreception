part of components;

class ContactInfoCalendar {
  Box           box;
  UListElement  calendarBody;
  String        calendarTitle = 'Kalender';
  model.Contact contact;
  DivElement    element;

  ContactInfoCalendar(DivElement this.element) {
    SpanElement calendarHeader = new SpanElement()
      ..classes.add('boxheader')
      ..text = calendarTitle;

    calendarBody = new UListElement()
      ..classes.addAll(['contact-info-container', 'zebra']);

    box = new Box.withHeader(element, calendarHeader, calendarBody);

    event.bus.on(event.contactChanged).listen((model.Contact value) {
      contact = value;
      render();
    });
  }

  void render() {
    calendarBody.children.clear();
    for(var event in contact.calendarEventList) {
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