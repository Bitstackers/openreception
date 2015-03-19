part of view;

class CalendarEventEditor {
  static final CalendarEventEditor _singleton = new CalendarEventEditor._internal();
  factory CalendarEventEditor() => _singleton;

  final ButtonElement     cancelButton      = querySelector('.cancel');
  final ContactCalendar   contactCalendar   = new ContactCalendar();
  final ReceptionCalendar receptionCalendar = new ReceptionCalendar();
  final DivElement        root              = querySelector('#calendar-event-editor');
  final TextAreaElement   textArea          = querySelector('#calendar-event-editor textarea');

  CalendarEventEditor._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    cancelButton.onClick.listen((_) => setHidden());

    contactCalendar.onEdit.listen((String data) {
      setVisible();
      root.querySelector('h4').text = data;
    });

    receptionCalendar.onEdit.listen((String data) {
      setVisible();
      root.querySelector('h4').text = data;
    });
  }

  void setHidden() {
    root.hidden = true;
    textArea.focus();
  }

  void setVisible() {
    root.hidden = false;
    textArea.focus();
  }
}
