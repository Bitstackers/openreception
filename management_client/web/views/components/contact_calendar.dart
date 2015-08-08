part of contact.view;

class ContactCalendarComponent {
  final DateFormat RFC3339 = new DateFormat('yyyy-MM-dd');

  final Controller.Calendar _calendarController;
  ButtonElement _newButton = new ButtonElement()
    ..text = 'Opret ny';
  Function _onChange;
  List<ORModel.CalendarEntry> _originalEvents;
  Element _parent;

  UListElement _ul = new UListElement()
    ..classes.add('zebra-even')
    ..classes.add('contact-calendar-list');

  ContactCalendarComponent(Element this._parent, Function this._onChange, Controller.Calendar this._calendarController) {
    DivElement editContainer = new DivElement();
    LabelElement header = new LabelElement()
      ..text = 'Kalender';
    _parent.children.addAll([header, _newButton, _ul]);

    _newButton.onClick.listen((_) {
      _ul.children.insert(0, _makeEventRow(new ORModel.CalendarEntry.empty()));
    });
  }

  ORModel.CalendarEntry _extractValue(LIElement li) {
    ORModel.CalendarEntry event = new ORModel.CalendarEntry.empty();

    try {
      HiddenInputElement idField = li.querySelector('.contact-calendar-event-id');
      TextAreaElement textField  = li.querySelector('.contact-calendar-event-text');

      NumberInputElement startHourField   = li.querySelector('.contact-calendar-event-start-hour');
      NumberInputElement startMinuteField = li.querySelector('.contact-calendar-event-start-minute');
      DateInputElement startDateField     = li.querySelector('.contact-calendar-event-start-date');

      NumberInputElement stopHourField   = li.querySelector('.contact-calendar-event-stop-hour');
      NumberInputElement stopMinuteField = li.querySelector('.contact-calendar-event-stop-minute');
      DateInputElement stopDateField     = li.querySelector('.contact-calendar-event-stop-date');

      if(idField.value != null && idField.value.trim().isNotEmpty) {
        event.ID = int.parse(idField.value);
      }

      DateTime startDate  = startDateField.valueAsDate;
      int startHour   = int.parse(startHourField.value);
      int startMinute = int.parse(startMinuteField.value);
      DateTime start = new DateTime(startDate.year, startDate.month, startDate.day, startHour, startMinute);

      DateTime stopDate  = stopDateField.valueAsDate;
      int stopHour   = int.parse(stopHourField.value);
      int stopMinute = int.parse(stopMinuteField.value);
      DateTime stop = new DateTime(stopDate.year, stopDate.month, stopDate.day, stopHour, stopMinute);

      event.beginsAt   = start;
      event.until = stop;
      event.content = textField.value;
    } catch(error, stack) {
      log.error('CalendarComponent _extractValue error: ${error} stack: ${stack}]');
    }
    return event;
  }

  Future load(int receptionId, int contactId) {
    return _calendarController.listContact(receptionId, contactId)
        .then((List<ORModel.CalendarEntry> events) {
      events.sort();
      _originalEvents = events;
      _ul.children
        ..clear()
        ..addAll(events.map(_makeEventRow));
    }).catchError((error) {
      log.error('Tried to fetch contact ${contactId} in reception ${receptionId} calendar events but got: ${error}');
      notify.error('Der skete en fejl i forbindelse med heningen af Calender beginvenheder. Fejl ${error}');
    });
  }

  LIElement _makeEventRow(ORModel.CalendarEntry event) {
    LIElement li = new LIElement();

    if(event.start == null) {
      event.beginsAt = new DateTime.now();
    }

    if(event.stop == null) {
      event.until = new DateTime.now().add(new Duration(hours: 2));
    }

    String _html = '''
<fieldset class="contact-calendar-event">
  <legend class="contact-calendar-event-legend">Kalender Aftale</legend>

  <input class="contact-calendar-event-id" type="hidden" value="${event.ID == null ? "" : event.ID}">
  <textarea class="contact-calendar-event-text" placeholder=" Aftale besked " tabindex=1>${event.content == null ? "" : event.content}</textarea>

  <fieldset class="contact-calendar-timebox">
    <legend> Start </legend>
    <input class="contact-calendar-event-start-hour" type="number" min="0" max="23" placeholder="tt" tabindex=1 value="${event.start.hour}"/>
    <span class="contact-calendar-seperator">:</span>
    <input class="contact-calendar-event-start-minute" type="number" min="0" max="59" placeholder="mm" tabindex=1 value="${event.start.minute}"/>

    <input class="contact-calendar-event-start-date" type="date" value="${RFC3339.format(event.start)}">

  </fieldset>

  <fieldset class="contact-calendar-timebox">
    <legend> Slut </legend>
    <input class="contact-calendar-event-stop-hour" type="number" min="0" max="23" placeholder="tt" tabindex=1 value="${event.stop.hour}"/>
    <span class="contact-calendar-seperator">:</span>
    <input class="contact-calendar-event-stop-minute" type="number" min="0" max="59" placeholder="mm" tabindex=1 value="${event.stop.minute}"/>

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

  void _notifyChange() {
    if(_onChange != null) {
      _onChange();
    }
  }

  Future save(int receptionId, int contactId) {
    List<ORModel.CalendarEntry> currentEvents = _ul.children.map(_extractValue).toList();

    List<Future> worklist = new List<Future>();

    //Inserts
    for(ORModel.CalendarEntry event in currentEvents) {
      //TODO: Verify that the contact and reception ID's are on the entries.
      if(!_originalEvents.any((ORModel.CalendarEntry e) => e.ID == event.ID)) {
        //Insert event
        worklist.add(_calendarController.create(event)
            .catchError((error, stack) {
          log.error('Request to create a contacts calendarevent failed. receptionId: "${receptionId}", contactId: "${receptionId}", event: "${JSON.encode(event)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Deletes
    for(ORModel.CalendarEntry event in _originalEvents) {
      if(!currentEvents.any((ORModel.CalendarEntry e) => e.ID == event.ID)) {
        //Delete event
        worklist.add(_calendarController.remove(event)
            .catchError((error, stack) {
          log.error('Request to delete a contacts calendarevent failed. receptionId: "${receptionId}", contactId: "${receptionId}", event: "${JSON.encode(event)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Update
    for(ORModel.CalendarEntry event in currentEvents) {
      ORModel.CalendarEntry e = _originalEvents.firstWhere((ORModel.CalendarEntry e) => e.ID == event.ID, orElse: () => null);
      if(e != null) {
        //Check if there is made a change
        if(e.content != event.content ||
           e.start != event.start ||
           e.stop != event.stop) {
          //Update event
          worklist.add(_calendarController.remove(event)
              .catchError((error, stack) {
            log.error('Request to update a contacts calendarevent failed. receptionId: "${receptionId}", contactId: "${receptionId}", event: "${JSON.encode(event)}" but got: ${error} ${stack}');
            // Rethrow.
            throw error;
          }));
        }
      }
    }
    return Future.wait(worklist);
  }
}
