/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

/**
 * The calendar editor UI model.
 */
class UICalendarEditor extends UIModel {
  ORModel.CalendarEntry _loadedEntry;
  HtmlElement           _myFirstTabElement;
  HtmlElement           _myFocusElement;
  HtmlElement           _myLastTabElement;
  final DivElement      _myRoot;

  /**
   * Constructor.
   */
  UICalendarEditor(DivElement this._myRoot) {
    _myFocusElement    = _textArea;
    _myFirstTabElement = _textArea;
    _myLastTabElement  = _cancelButton;

    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _myFirstTabElement;
  @override HtmlElement get _focusElement    => _myFocusElement;
  @override HtmlElement get _lastTabElement  => _myLastTabElement;
  @override HtmlElement get _root            => _myRoot;

  ButtonElement        get _cancelButton     => _root.querySelector('.cancel');
  ButtonElement        get _deleteButton     => _root.querySelector('.delete');
  ElementList<Element> get _inputFields      => _root.querySelectorAll('[input-field]');
  ButtonElement        get _saveButton       => _root.querySelector('.save');
  InputElement         get _startHourInput   => _root.querySelector('.start-hour');
  InputElement         get _startMinuteInput => _root.querySelector('.start-minute');
  InputElement         get _startDayInput    => _root.querySelector('.start-day');
  InputElement         get _startMonthInput  => _root.querySelector('.start-month');
  SpanElement          get _startReadable    => _root.querySelector('div.readable .start');
  SpanElement          get _stopReadable     => _root.querySelector('div.readable .stop');
  InputElement         get _startYearInput   => _root.querySelector('.start-year');
  InputElement         get _stopHourInput    => _root.querySelector('.stop-hour');
  InputElement         get _stopMinuteInput  => _root.querySelector('.stop-minute');
  InputElement         get _stopDayInput     => _root.querySelector('.stop-day');
  InputElement         get _stopMonthInput   => _root.querySelector('.stop-month');
  InputElement         get _stopYearInput    => _root.querySelector('.stop-year');
  ElementList<Element> get _tabElements      => _root.querySelectorAll('[tabindex]');
  TextAreaElement      get _textArea         => _root.querySelector('textarea');

  /**
   * Populate the calendar editor fields with [calendarEntry].
   */
  set calendarEntry(ORModel.CalendarEntry calendarEntry) {
    _loadedEntry = calendarEntry;

    _startReadable.text = _humanReadableTimestamp(calendarEntry.startTime);
    _stopReadable.text = _humanReadableTimestamp(calendarEntry.stopTime);

    _textArea.value = calendarEntry.content;

    _startHourInput.value = calendarEntry.startTime.hour.toString();
    _startMinuteInput.value = calendarEntry.startTime.minute.toString();
    _startDayInput.value = calendarEntry.startTime.day.toString();
    _startMonthInput.value = calendarEntry.startTime.month.toString();
    _startYearInput.value = calendarEntry.startTime.year.toString();

    _stopHourInput.value = calendarEntry.stopTime.hour.toString();
    _stopMinuteInput.value = calendarEntry.stopTime.minute.toString();
    _stopDayInput.value = calendarEntry.stopTime.day.toString();
    _stopMonthInput.value = calendarEntry.stopTime.month.toString();
    _stopYearInput.value = calendarEntry.stopTime.year.toString();

    _toggleButtons();
  }

  /**
   * Mark [input] with the bad-input class if the validity of the data does not
   * match the requirements defined by the input attributes.
   * If [input] is OK, then call [_toggleButtons].
   */
  void _checkInput(InputElement input) {
    input.classes.toggle('bad-input', input.validity.badInput);

    try {
    _startReadable.text = _humanReadableTimestamp(_harvestStartDateTime());
    } catch(_) {
      _startReadable.text = 'fejl';
    }

    try {
    _stopReadable.text = _humanReadableTimestamp(_harvestStopDateTime());
    } catch(_) {
      _stopReadable.text = 'fejl';
    }

    _toggleButtons();
  }

  /**
   *
   */
  ORModel.CalendarEntry get harvestedEntry {

    ///
    ///
    ///
    ///
    /// TODO: Harvest the data from DOM and create/return a new calendar entry
    /// from these data.
    ///
    ///
    ///

    return null;
  }

  /**
   *
   */
  DateTime _harvestStartDateTime() {
    return new DateTime.utc(_startYearInput.valueAsNumber.toInt(),
                            _startMonthInput.valueAsNumber.toInt(),
                            _startDayInput.valueAsNumber.toInt(),
                            _startHourInput.valueAsNumber.toInt(),
                            _startMinuteInput.valueAsNumber.toInt());
  }

  /**
   *
   */
  DateTime _harvestStopDateTime() {
    return new DateTime.utc(_stopYearInput.valueAsNumber.toInt(),
                            _stopMonthInput.valueAsNumber.toInt(),
                            _stopDayInput.valueAsNumber.toInt(),
                            _stopHourInput.valueAsNumber.toInt(),
                            _stopMinuteInput.valueAsNumber.toInt());
  }

  /**
   * Return the [timestamp] in a human readable format.
   *
   * TODO (TL): Use lang package for language specific words.
   * TODO (TL): Fix so this can handle different output formats.
   */
  String _humanReadableTimestamp(DateTime timestamp) {
    final StringBuffer sb = new StringBuffer();

    final Map<int, String> dayName = {1: 'Mandag',
                                      2: 'Tirsdag',
                                      3: 'Onsdag',
                                      4: 'Torsdag',
                                      5: 'Fredag',
                                      6: 'Lørdag',
                                      7: 'Søndag'};

    final String day = new DateFormat.d().format(timestamp);
    final String hourMinute = new DateFormat.Hm().format(timestamp);
    final String month = new DateFormat.M().format(timestamp);
    final String year = new DateFormat.y().format(timestamp);

    sb.write(dayName[timestamp.weekday]);
    sb.write(' d. ');
    sb.write('${day}-${month}-${year}');
    sb.write(' kl. ');
    sb.write(hourMinute);

    return sb.toString();
  }

  /**
   *
   */
  ORModel.CalendarEntry get loadedEntry => _loadedEntry;

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);

    /// Enables focused element memory for this widget.
    _tabElements.forEach((HtmlElement element) {
      element.onFocus.listen((Event event) => _myFocusElement = (event.target as HtmlElement));
    });

    _textArea.onInput        .listen((_) => _toggleButtons());
    _startHourInput.onInput  .listen((_) => _checkInput(_startHourInput));
    _startMinuteInput.onInput.listen((_) => _checkInput(_startMinuteInput));
    _startDayInput.onInput   .listen((_) => _checkInput(_startDayInput));
    _startMonthInput.onInput .listen((_) => _checkInput(_startMonthInput));
    _startYearInput.onInput  .listen((_) => _checkInput(_startYearInput));
    _stopHourInput.onInput   .listen((_) => _checkInput(_stopHourInput));
    _stopMinuteInput.onInput .listen((_) => _checkInput(_stopMinuteInput));
    _stopDayInput.onInput    .listen((_) => _checkInput(_stopDayInput));
    _stopMonthInput.onInput  .listen((_) => _checkInput(_stopMonthInput));
    _stopYearInput.onInput   .listen((_) => _checkInput(_stopYearInput));
  }

  /**
   * Return the click event stream for the cancel button.
   */
  Stream<MouseEvent> get onCancel => _cancelButton.onClick;

  /**
   * Return the click event stream for the delete button.
   */
  Stream<MouseEvent> get onDelete => _deleteButton.onClick;

  /**
   * Return the click event stream for the save button.
   */
  Stream<MouseEvent> get onSave => _saveButton.onClick;

  /**
   * Clear the widget of all data and reset focus element.
   */
  void reset() {
    _loadedEntry = null;
    _myFocusElement = _myFirstTabElement;

    _startReadable.text = '';
    _stopReadable.text = '';

    _inputFields.forEach((element) => element.value = '');

    _toggleButtons();
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    _hotKeys.registerKeys(_keyboard, _defaultKeyMap(myKeys: {'Esc': (_) => _cancelButton.click()}));
  }

  /**
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * last tab element as this depends on the state of the buttons.
   */
  void _toggleButtons() {
    final bool toggle = !_inputFields.any((element) => element.value.isEmpty)
        && !_inputFields.any((element) => element.validity.badInput);

    _deleteButton.disabled = !toggle || (_loadedEntry != null && _loadedEntry.ID == ORModel.CalendarEntry.noID);
    _saveButton.disabled   = !toggle;

    _myLastTabElement = toggle ? _saveButton : _cancelButton;
  }
}
