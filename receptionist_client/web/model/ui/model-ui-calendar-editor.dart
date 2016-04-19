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
  HtmlElement _myFirstTabElement;
  HtmlElement _myFocusElement;
  HtmlElement _myLastTabElement;
  final DivElement _myRoot;
  final ORUtil.WeekDays _weekDays;

  /**
   * Constructor.
   */
  UICalendarEditor(DivElement this._myRoot, ORUtil.WeekDays this._weekDays) {
    _myFocusElement = _textArea;
    _myFirstTabElement = _textArea;
    _myLastTabElement = _cancelButton;

    _setupLocalKeys();
    _observers();
  }

  @override
  HtmlElement get _firstTabElement => _myFirstTabElement;
  @override
  HtmlElement get _focusElement => _myFocusElement;
  @override
  HtmlElement get _lastTabElement => _myLastTabElement;
  @override
  HtmlElement get _root => _myRoot;

  SpanElement get _authorStamp => _root.querySelector('.author-stamp');
  ButtonElement get _cancelButton => _root.querySelector('.cancel');
  ButtonElement get _deleteButton => _root.querySelector('.delete');
  SpanElement get _entryDuration =>
      _root.querySelector('div.entry-duration-container .entry-duration');
  ElementList<InputElement> get _inputFields => _root.querySelectorAll('input');
  ButtonElement get _saveButton => _root.querySelector('.save');
  InputElement get _startHourInput =>
      _root.querySelector('div.entry-start-container .start-hour');
  InputElement get _startMinuteInput =>
      _root.querySelector('div.entry-start-container .start-minute');
  InputElement get _startDayInput =>
      _root.querySelector('div.entry-start-container .start-day');
  InputElement get _startMonthInput =>
      _root.querySelector('div.entry-start-container .start-month');
  SpanElement get _startReadable =>
      _root.querySelector('div.readable-container .readable-start');
  SpanElement get _stopReadable =>
      _root.querySelector('div.readable-container .readable-stop');
  InputElement get _startYearInput =>
      _root.querySelector('div.entry-start-container .start-year');
  InputElement get _stopHourInput =>
      _root.querySelector('div.entry-stop-container .stop-hour');
  InputElement get _stopMinuteInput =>
      _root.querySelector('div.entry-stop-container .stop-minute');
  InputElement get _stopDayInput =>
      _root.querySelector('div.entry-stop-container .stop-day');
  InputElement get _stopMonthInput =>
      _root.querySelector('div.entry-stop-container .stop-month');
  InputElement get _stopYearInput =>
      _root.querySelector('div.entry-stop-container .stop-year');
  ElementList<Element> get _tabElements => _root.querySelectorAll('[tabindex]');
  TextAreaElement get _textArea => _root.querySelector('textarea');

  /**
   * Set the authorStamp part of the widget header. The format of the String is:
   *
   *  name @ humanreadable timestamp
   *
   * Set [userName] and [timestamp] to null to set an empty authorStamp.
   */
  void authorStamp(String userName, DateTime timestamp) {
    if (userName == null && timestamp == null) {
      _authorStamp.text = '';
    } else {
      _authorStamp.text =
          '${userName} @ ${ORUtil.humanReadableTimestamp(timestamp, _weekDays)}';
    }
  }

  /**
   * Populate the calendar editor fields with [calendarEntry].
   */
  set calendarEntry(ORModel.CalendarEntry calendarEntry) {
    _loadedEntry = calendarEntry;

    _textArea.value = calendarEntry.content;

    _startHourInput.value = calendarEntry.start.hour.toString();
    _startMinuteInput.value = calendarEntry.start.minute.toString();
    _startDayInput.value = calendarEntry.start.day.toString();
    _startMonthInput.value = calendarEntry.start.month.toString();
    _startYearInput.value = calendarEntry.start.year.toString();

    _stopHourInput.value = calendarEntry.stop.hour.toString();
    _stopMinuteInput.value = calendarEntry.stop.minute.toString();
    _stopDayInput.value = calendarEntry.stop.day.toString();
    _stopMonthInput.value = calendarEntry.stop.month.toString();
    _stopYearInput.value = calendarEntry.stop.year.toString();

    _updateReadableAndDuration();
    _toggleButtons();
  }

  /**
   * Harvest a [ORModel.CalendarEntry] from the form.
   */
  ORModel.CalendarEntry get harvestedEntry => _loadedEntry
    ..beginsAt = _harvestStartDateTime
    ..until = _harvestStopDateTime
    ..content = _textArea.value;

  /**
   * Harvest the start [DateTime] from the form.
   */
  DateTime get _harvestStartDateTime => new DateTime(
      _startYearInput.valueAsNumber.toInt(),
      _startMonthInput.valueAsNumber.toInt(),
      _startDayInput.valueAsNumber.toInt(),
      _startHourInput.valueAsNumber.toInt(),
      _startMinuteInput.valueAsNumber.toInt());

  /**
   * Harvest the stop [DateTime] from the form.
   */
  DateTime get _harvestStopDateTime => new DateTime(
      _stopYearInput.valueAsNumber.toInt(),
      _stopMonthInput.valueAsNumber.toInt(),
      _stopDayInput.valueAsNumber.toInt(),
      _stopHourInput.valueAsNumber.toInt(),
      _stopMinuteInput.valueAsNumber.toInt());

  /**
   * Get the currently loaded [ORModel.CalendarEntry].
   */
  ORModel.CalendarEntry get loadedEntry => _loadedEntry;

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);

    /// Enables focused element memory for this widget.
    _tabElements.forEach((Element element) {
      element.onFocus.listen(
          (Event event) => _myFocusElement = (event.target as HtmlElement));
    });

    _textArea.onInput.listen((_) => _toggleButtons());
    _startHourInput.onInput.listen((_) => _update(_startHourInput));
    _startMinuteInput.onInput.listen((_) => _update(_startMinuteInput));
    _startDayInput.onInput.listen((_) => _update(_startDayInput));
    _startMonthInput.onInput.listen((_) => _update(_startMonthInput));
    _startYearInput.onInput.listen((_) => _update(_startYearInput));
    _stopHourInput.onInput.listen((_) => _update(_stopHourInput));
    _stopMinuteInput.onInput.listen((_) => _update(_stopMinuteInput));
    _stopDayInput.onInput.listen((_) => _update(_stopDayInput));
    _stopMonthInput.onInput.listen((_) => _update(_stopMonthInput));
    _stopYearInput.onInput.listen((_) => _update(_stopYearInput));
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

    _authorStamp.text = '';

    _startReadable.text = '';
    _stopReadable.text = '';

    _inputFields.forEach((element) {
      element.value = '';
      element.classes.remove('bad-input');
    });

    _textArea.value = '';
    _textArea.classes.remove('bad-input');

    _deleteButton.disabled = true;
    _saveButton.disabled = true;
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    Map<String, EventListener> myKeys = {
      'Ctrl+Backspace': (_) => _deleteButton.click(),
      'Ctrl+s': (_) => _saveButton.click()
    };

    _hotKeys.registerKeys(_keyboard,
        _defaultKeyMap(myKeys: {'Esc': (_) => _cancelButton.click()}));
    _hotKeys.registerKeysPreventDefault(_keyboard, myKeys);
  }

  /**
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * last tab element as this depends on the state of the buttons.
   */
  void _toggleButtons() {
    bool inputIsEmpty(InputElement input) => input.value.trim().isEmpty;
    bool inputIsInvalid(InputElement input) => input.validity.badInput;

    final bool toggle = !_inputFields.any(inputIsEmpty) &&
        !_inputFields.any(inputIsInvalid) &&
        !_textArea.value.trim().isEmpty &&
        !_textArea.validity.badInput &&
        _harvestStartDateTime.isBefore(_harvestStopDateTime);

    _deleteButton.disabled = !toggle ||
        (_loadedEntry != null && _loadedEntry.ID == ORModel.CalendarEntry.noID);
    _saveButton.disabled = !toggle;

    _myLastTabElement = toggle ? _saveButton : _cancelButton;
  }

  /**
   * Mark [input] with the bad-input class if the validity of the data does not
   * match the requirements defined by the input attributes.
   *
   * Output readable timestamps.
   *
   * Update duration.
   *
   * If [input] is OK, then call [_toggleButtons].
   */
  void _update(InputElement input) {
    input.classes.toggle('bad-input', input.validity.badInput);

    _toggleButtons();

    try {
      _updateReadableAndDuration();
    } catch (_) {
      /// NOTE (TL): Errors caught here are of the NaN type due to bad input in
      /// the start/stop fields.
    }
  }

  /**
   *
   */
  void _updateReadableAndDuration() {
    final StringBuffer duration = new StringBuffer();
    final DateTime start = _harvestStartDateTime;
    final DateTime stop = _harvestStopDateTime;

    try {
      _startReadable.text = ORUtil.humanReadableTimestamp(start, _weekDays);
    } catch (_) {
      _startReadable.text = '';
    }

    try {
      _stopReadable.text = ORUtil.humanReadableTimestamp(stop, _weekDays);
    } catch (_) {
      _stopReadable.text = '';
    }

    duration.write(stop.difference(start).inDays);
    duration.write(' ');
    duration.write(stop.difference(start).inHours.remainder(24));
    duration.write(':');
    duration.write(stop.difference(start).inMinutes.remainder(60));

    _entryDuration.text = duration.toString();

    _startReadable.classes.toggle('bad-input', stop.isBefore(start));
    _entryDuration.classes.toggle('bad-input', stop.isBefore(start));
  }
}
