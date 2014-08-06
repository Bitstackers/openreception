part of contact.view;

class ContactCalendarComponent {
  final DateFormat RFC3339 = new DateFormat('yyyy-MM-dd');
  Element _parent;
  Function _onChange;
  ButtonElement _newButton = new ButtonElement()
    ..text = 'Opret ny';

  UListElement _ul = new UListElement()
    ..classes.add('zebra')
    ..classes.add('contact-calendar-list');

  List<CalendarEvent> originalEvents;

  ContactCalendarComponent(Element this._parent, Function this._onChange) {
    DivElement editContainer = new DivElement();
    LabelElement header = new LabelElement()
      ..text = 'Kalender';
    _parent.children.addAll([header, _newButton, _ul]);

    _newButton.onClick.listen((_) {
      _ul.children.insert(0, _makeEventRow(new CalendarEvent()));
    });
  }

  Future load(int receptionId, int contactId) {
    return request.getReceptionContactCalendar(receptionId, contactId)
        .then((List<CalendarEvent> events) {
      events.sort(CalendarEvent.sortByStartThenStop);
      originalEvents = events;
      _ul.children
        ..clear()
        ..addAll(events.map(_makeEventRow));
    }).catchError((error) {
      log.error('Tried to fetch contact ${contactId} in reception ${receptionId} calendar events but got: ${error}');
      notify.error('Der skete en fejl i forbindelse med heningen af Calender beginvenheder. Fejl ${error}');
    });
  }

  LIElement _makeEventRow(CalendarEvent event) {
    LIElement li = new LIElement();

    if(event.start == null) {
      event.start = new DateTime.now();
    }

    if(event.stop == null) {
      event.stop = new DateTime.now().add(new Duration(hours: 2));
    }

    String _html = '''
<fieldset class="contact-calendar-event">
  <legend class="contact-calendar-event-legend">Kalender Aftale</legend>

  <input class="contact-calendar-event-id" type="hidden" value="${event.id == null ? "" : event.id}">
  <textarea class="contact-calendar-event-text" placeholder=" Aftale besked " tabindex=1>${event.message == null ? "" : event.message}</textarea>

  <fieldset class="contact-calendar-timebox">
    <legend> Start </legend>
    <input class="contact-calendar-event-start-hour" type="number" min="0" max="23" placeholder="tt" tabindex=1 maxlength=2 value="${event.start.hour}"/>
    <span class="contact-calendar-seperator">:</span>
    <input class="contact-calendar-event-start-minute" type="number" min="0" max="59" placeholder="mm" tabindex=1 maxlength=2 value="${event.start.minute}"/>

    <input class="contact-calendar-event-start-date" type="date" value="${RFC3339.format(event.start)}">

  </fieldset>

  <fieldset class="contact-calendar-timebox">
    <legend> Slut </legend>
    <input class="contact-calendar-event-stop-hour" type="number" min="0" max="23" placeholder="tt" tabindex=1 maxlength=2 value="${event.stop.hour}"/>
    <span class="contact-calendar-seperator">:</span>
    <input class="contact-calendar-event-stop-minute" type="number" min="0" max="59" placeholder="mm" tabindex=1 maxlength=2 value="${event.stop.minute}"/>

    <input class="contact-calendar-event-stop-date" type="date" value="${RFC3339.format(event.stop)}">

    </fieldset>
  <button class="contact-calendar-event-delete"> Slet <button>
</fieldset>
  ''';

    DocumentFragment fragment = new DocumentFragment.html(_html);
    li.children.addAll(fragment.children);

    TextAreaElement textField = li.querySelector('.contact-calendar-event-text');

    NumberInputElement startHourField   = li.querySelector('.contact-calendar-event-start-hour');
    NumberInputElement startMinuteField = li.querySelector('.contact-calendar-event-start-minute');
    DateInputElement startDateField    = li.querySelector('.contact-calendar-event-start-date');

    NumberInputElement stopHourField   = li.querySelector('.contact-calendar-event-stop-hour');
    NumberInputElement stopMinuteField = li.querySelector('.contact-calendar-event-stop-minute');
    DateInputElement stopDateField    = li.querySelector('.contact-calendar-event-stop-date');
    List<Element> inputs = [textField,
                            startHourField, startMinuteField, startDateField,
                            stopHourField, stopMinuteField, stopDateField];
    inputs.forEach((Element element) {
      element.onInput.listen((_) => _notifyChange());
    });

    ButtonElement deleteButton = li.querySelector('.contact-calendar-event-delete')
        ..onClick.listen((_) {
      _notifyChange();
      li.parent.children.remove(li);
    });

    return li;
  }

  CalendarEvent extractValue(LIElement li) {
    CalendarEvent event = new CalendarEvent();

    try {
      HiddenInputElement idField = li.querySelector('.contact-calendar-event-id');
      TextAreaElement textField = li.querySelector('.contact-calendar-event-text');

      NumberInputElement startHourField   = li.querySelector('.contact-calendar-event-start-hour');
      NumberInputElement startMinuteField = li.querySelector('.contact-calendar-event-start-minute');
      DateInputElement startDateField    = li.querySelector('.contact-calendar-event-start-date');

      NumberInputElement stopHourField   = li.querySelector('.contact-calendar-event-stop-hour');
      NumberInputElement stopMinuteField = li.querySelector('.contact-calendar-event-stop-minute');
      DateInputElement stopDateField    = li.querySelector('.contact-calendar-event-stop-date');

      if(idField.value != null && idField.value.trim().isNotEmpty) {
        event.id = int.parse(idField.value);
      }

      DateTime startDate  = startDateField.valueAsDate;
      int startHour   = int.parse(startHourField.value);
      int startMinute = int.parse(startMinuteField.value);
      DateTime start = new DateTime(startDate.year, startDate.month, startDate.day, startHour, startMinute);

      DateTime stopDate  = stopDateField.valueAsDate;
      int stopHour   = int.parse(stopHourField.value);
      int stopMinute = int.parse(stopMinuteField.value);
      DateTime stop = new DateTime(stopDate.year, stopDate.month, stopDate.day, stopHour, stopMinute);

      event.start   = start;
      event.stop    = stop;
      event.message = textField.value;
    } catch(error, stack) {
      log.error('CalendarComponent error: ${error} stack: ${stack}]');
    }
    return event;
  }

  Future save(int receptionId, int contactId) {
    List<CalendarEvent> currentEvents = _ul.children.map(extractValue).toList();

    List<Future> worklist = new List<Future>();

    //Inserts
    for(CalendarEvent event in currentEvents) {
      if(!originalEvents.any((CalendarEvent e) => e.id == event.id)) {
        //Insert event
        worklist.add(request.createContactCalendarEvent(receptionId, contactId, JSON.encode(event)));
      }
    }

    //Deletes
    for(CalendarEvent event in originalEvents) {
      if(!currentEvents.any((CalendarEvent e) => e.id == event.id)) {
        //Delete event
        worklist.add(request.deleteContactCalendarEvent(receptionId, contactId, event.id));
      }
    }

    //Update
    for(CalendarEvent event in currentEvents) {
      CalendarEvent e = originalEvents.firstWhere((CalendarEvent e) => e.id == event.id, orElse: () => null);
      if(e != null) {
        //Check if there is made a change
        if(e.message != event.message ||
           e.start != event.start ||
           e.stop != event.stop) {
          //Update event
          worklist.add(request.updateContactCalendarEvent(receptionId, contactId, event.id, JSON.encode(event)));
        }
      }
    }
    return Future.wait(worklist);
  }

  void _notifyChange() {
    if(_onChange != null) {
      _onChange();
    }
  }
}
