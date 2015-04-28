part of model;

/**
 * TODO (TL): Comment
 */
class UICalendarEditor extends UIModel {
  HtmlElement      _myFirstTabElement;
  HtmlElement      _myFocusElement;
  HtmlElement      _myLastTabElement;
  final DivElement _myRoot;

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
  InputElement         get _startYearInput   => _root.querySelector('.start-year');
  InputElement         get _stopHourInput    => _root.querySelector('.stop-hour');
  InputElement         get _stopMinuteInput  => _root.querySelector('.stop-minute');
  InputElement         get _stopDayInput     => _root.querySelector('.stop-day');
  InputElement         get _stopMonthInput   => _root.querySelector('.stop-month');
  InputElement         get _stopYearInput    => _root.querySelector('.stop-year');
  ElementList<Element> get _tabElements      => _root.querySelectorAll('[tabindex]');
  TextAreaElement      get _textArea         => _root.querySelector('textarea');

  /**
   * Populate the calendar editor fields with [calendarEntry].  Note if the
   * [calendarEntry] is a empty entry, then the widget renders with its default
   * values.
   */
  set calendarEntry(ORModel.CalendarEntry calendarEntry) {
    /// TODO (TL): Add the actual calendar entry data to the widget.
    /// Distinguish between empty entry and actual entry.
    /// Add switch case on calendarEntry type (ContactCalendarEntry/ReceptionCalendarEntry)
    _textArea.text = calendarEntry.content;
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
   * Mark [input] with the bad-input class if the validity of the data does not
   * match the requirements defined by the input attributes.
   * If [input] is OK, then call [_toggleButtons].
   */
  void _checkInput(InputElement input) {
    input.classes.toggle('bad-input', input.validity.badInput);
    if(!input.validity.badInput) {
      _toggleButtons();
    }
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
    final bool toggle = !_inputFields.any((element) => element.value.isEmpty);

    _deleteButton.disabled = !toggle;
    _saveButton.disabled   = !toggle;

    _myLastTabElement = toggle ? _saveButton : _cancelButton;
  }
}
