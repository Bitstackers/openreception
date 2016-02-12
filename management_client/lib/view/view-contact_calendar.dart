part of management_tool.view;

class ContactCalendarComponent {
  final DateFormat RFC3339 = new DateFormat('yyyy-MM-dd');
  final Logger _log = new Logger('$_libraryName.ContactCalendarComponent');

  final controller.Calendar _calendarController;
  ButtonElement _newButton = new ButtonElement()..text = 'Opret ny';
  Function _onChange;
  List<model.CalendarEntry> _originalEvents;
  Element _parent;

  UListElement _ul = new UListElement()
    ..classes.add('zebra-even')
    ..classes.add('contact-calendar-list');

  ContactCalendarComponent(Element this._parent, Function this._onChange,
      controller.Calendar this._calendarController) {
    DivElement editContainer = new DivElement();
    ParagraphElement header = new ParagraphElement()..text = 'Kalender';
    _parent.children.addAll([header, _newButton, _ul]);

    _newButton.onClick.listen((_) {
      _ul.children.insert(0, _makeEventRow(new model.CalendarEntry.empty()));
    });
  }

  model.CalendarEntry _extractValue(LIElement li) {
    model.CalendarEntry event = new model.CalendarEntry.empty();

    try {
      HiddenInputElement idField =
          li.querySelector('.contact-calendar-event-id');
      TextAreaElement textField =
          li.querySelector('.contact-calendar-event-text');

      NumberInputElement startHourField =
          li.querySelector('.contact-calendar-event-start-hour');
      NumberInputElement startMinuteField =
          li.querySelector('.contact-calendar-event-start-minute');
      DateInputElement startDateField =
          li.querySelector('.contact-calendar-event-start-date');

      NumberInputElement stopHourField =
          li.querySelector('.contact-calendar-event-stop-hour');
      NumberInputElement stopMinuteField =
          li.querySelector('.contact-calendar-event-stop-minute');
      DateInputElement stopDateField =
          li.querySelector('.contact-calendar-event-stop-date');

      if (idField.value != null && idField.value.trim().isNotEmpty) {
        event.ID = int.parse(idField.value);
      }

      DateTime startDate = startDateField.valueAsDate;
      int startHour = int.parse(startHourField.value);
      int startMinute = int.parse(startMinuteField.value);
      DateTime start = new DateTime(startDate.year, startDate.month,
          startDate.day, startHour, startMinute);

      DateTime stopDate = stopDateField.valueAsDate;
      int stopHour = int.parse(stopHourField.value);
      int stopMinute = int.parse(stopMinuteField.value);
      DateTime stop = new DateTime(
          stopDate.year, stopDate.month, stopDate.day, stopHour, stopMinute);

      event.beginsAt = start;
      event.until = stop;
      event.content = textField.value;
    } catch (error, stack) {
      _log.severe(
          'CalendarComponent _extractValue error: ${error} stack: ${stack}]');
    }
    return event;
  }

  Future load(int receptionId, int contactId) {
    return _calendarController
        .listContact(contactId)
        .then((Iterable<model.CalendarEntry> events) {
      //TODO: Sort.
      _originalEvents = events.toList();
      _ul.children
        ..clear()
        ..addAll(events.map(_makeEventRow));
    });
  }

  LIElement _makeEventRow(model.CalendarEntry event) {
    LIElement li = new LIElement();

    if (event.start == null) {
      event.beginsAt = new DateTime.now();
    }

    if (event.stop == null) {
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

    TextAreaElement textField =
        li.querySelector('.contact-calendar-event-text');

    NumberInputElement startHourField =
        li.querySelector('.contact-calendar-event-start-hour');
    NumberInputElement startMinuteField =
        li.querySelector('.contact-calendar-event-start-minute');
    DateInputElement startDateField =
        li.querySelector('.contact-calendar-event-start-date');

    NumberInputElement stopHourField =
        li.querySelector('.contact-calendar-event-stop-hour');
    NumberInputElement stopMinuteField =
        li.querySelector('.contact-calendar-event-stop-minute');
    DateInputElement stopDateField =
        li.querySelector('.contact-calendar-event-stop-date');
    List<Element> inputs = [
      textField,
      startHourField,
      startMinuteField,
      startDateField,
      stopHourField,
      stopMinuteField,
      stopDateField
    ];
    inputs.forEach((Element element) {
      element.onInput.listen((_) => _notifyChange());
    });

    ButtonElement deleteButton =
        li.querySelector('.contact-calendar-event-delete')
          ..onClick.listen((_) {
            _notifyChange();
            li.parent.children.remove(li);
          });

    return li;
  }

  void _notifyChange() {
    if (_onChange != null) {
      _onChange();
    }
  }

  Future save(int receptionId, int contactId) {
    List<model.CalendarEntry> currentEvents =
        _ul.children.map(_extractValue).toList();

    List<Future> worklist = new List<Future>();

    //Inserts
    for (model.CalendarEntry event in currentEvents) {
      //TODO: Verify that the contact and reception ID's are on the entries.
      if (!_originalEvents.any((model.CalendarEntry e) => e.ID == event.ID)) {
        //Insert event
        worklist.add(_calendarController
            .create(event, config.user)
            .catchError((error, stack) {
          _log.severe(
              'Request to create a contacts calendarevent failed. receptionId: "${receptionId}", contactId: "${receptionId}", event: "${JSON.encode(event)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Deletes
    for (model.CalendarEntry event in _originalEvents) {
      if (!currentEvents.any((model.CalendarEntry e) => e.ID == event.ID)) {
        //Delete event
        worklist.add(_calendarController
            .remove(event, config.user)
            .catchError((error, stack) {
          _log.severe(
              'Request to delete a contacts calendarevent failed. receptionId: "${receptionId}", contactId: "${receptionId}", event: "${JSON.encode(event)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Update
    for (model.CalendarEntry event in currentEvents) {
      model.CalendarEntry e = _originalEvents.firstWhere(
          (model.CalendarEntry e) => e.ID == event.ID,
          orElse: () => null);
      if (e != null) {
        //Check if there is made a change
        if (e.content != event.content ||
            e.start != event.start ||
            e.stop != event.stop) {
          //Update event
          worklist.add(_calendarController
              .remove(event, config.user)
              .catchError((error, stack) {
            _log.severe(
                'Request to update a contacts calendarevent failed. receptionId: "${receptionId}", contactId: "${receptionId}", event: "${JSON.encode(event)}" but got: ${error} ${stack}');
            // Rethrow.
            throw error;
          }));
        }
      }
    }
    return Future.wait(worklist);
  }
}
