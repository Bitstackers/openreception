part of view;

class CalendarEditor {
  static final CalendarEditor _singleton = new CalendarEditor._internal();
  factory CalendarEditor() => _singleton;

  /**
   *
   */
  CalendarEditor._internal() {
    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#calendar-editor');

  final ButtonElement     _cancelButton      = _root.querySelector('.cancel');
  final ButtonElement     _deleteButton      = _root.querySelector('.delete');
  final ButtonElement     _saveButton        = _root.querySelector('.save');
  final ContactCalendar   _contactCalendar   = new ContactCalendar();
  final ReceptionCalendar _receptionCalendar = new ReceptionCalendar();
  final InputElement      _startHour         = _root.querySelector('.start-hour');
  final InputElement      _startMinute       = _root.querySelector('.start-minute');
  final InputElement      _startDay          = _root.querySelector('.start-day');
  final InputElement      _startMonth        = _root.querySelector('.start-month');
  final InputElement      _startYear         = _root.querySelector('.start-year');
  final InputElement      _stopHour          = _root.querySelector('.stop-hour');
  final InputElement      _stopMinute        = _root.querySelector('.stop-minute');
  final InputElement      _stopDay           = _root.querySelector('.stop-day');
  final InputElement      _stopMonth         = _root.querySelector('.stop-month');
  final InputElement      _stopYear          = _root.querySelector('.stop-year');
  final TextAreaElement   _textArea          = _root.querySelector('textarea');

  /**
   *
   */
  void _activate(String data) {
    _setVisible();
    _root.querySelector('h4').text = data;
  }

  /**
   *
   */
  void _cancel() {
    _setHidden();
    print('view-calendar-editor.cancel() not implemented');
  }

  /**
   *
   */
  void _delete() {
    _setHidden();
    print('view-calendar-editor.delete() not implemented');
  }

  /**
   *
   */
  void _registerEventListeners() {
    _startHour.onInput  .listen((_) => _sanitizeInput(_startHour));
    _startMinute.onInput.listen((_) => _sanitizeInput(_startMinute));
    _startDay.onInput   .listen((_) => _sanitizeInput(_startDay));
    _startMonth.onInput .listen((_) => _sanitizeInput(_startMonth));
    _startYear.onInput  .listen((_) => _sanitizeInput(_startYear));
    _stopHour.onInput   .listen((_) => _sanitizeInput(_stopHour));
    _stopMinute.onInput .listen((_) => _sanitizeInput(_stopMinute));
    _stopDay.onInput    .listen((_) => _sanitizeInput(_stopDay));
    _stopMonth.onInput  .listen((_) => _sanitizeInput(_stopMonth));
    _stopYear.onInput   .listen((_) => _sanitizeInput(_stopYear));

    _cancelButton.onClick.listen((_) => _cancel());
    _deleteButton.onClick.listen((_) => _delete());
    _saveButton.onClick  .listen((_) => _save());

    _contactCalendar  .onEdit.listen(_activate);
    _receptionCalendar.onEdit.listen(_activate);
  }

  /**
   *
   */
  void _sanitizeInput(InputElement input) {
    if(input.validity.badInput) {
      input.classes.toggle('bad-input', true);
    } else {
      input.classes.toggle('bad-input', false);
    }

//    TODO (TL): Possibly do something with over-/underflow?
//    if(input.validity.rangeOverflow) {
//
//    }
//
//    if(input.validity.rangeUnderflow) {
//
//    }
  }

  /**
   *
   */
  void _save() {
    _setHidden();
    print('view-calendar-editor.save() not implemented');
  }

  /**
   *
   */
  void _setHidden() {
    _root.hidden = true;
    _textArea.focus();
  }

  /**
   *
   */
  void _setVisible() {
    _root.hidden = false;
    _textArea.focus();
  }
}
