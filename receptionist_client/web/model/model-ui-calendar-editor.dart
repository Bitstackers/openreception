part of model;

class UICalendarEditor extends UIModel {
  HtmlElement _myFirstTabElement;
  HtmlElement _myFocusElement;
  HtmlElement _myLastTabElement;
  final DivElement _myRoot;

  UICalendarEditor(DivElement this._myRoot) {
    _myFocusElement    = _textAreaElement;
    _myFirstTabElement = _textAreaElement;
    _myLastTabElement  = _cancelButtonElement;

    _registerEventListeners();
  }

  @override HtmlElement get _firstTabElement => _myFirstTabElement;
  @override HtmlElement get _focusElement    => _myFocusElement;
  @override HtmlElement get _lastTabElement  => _myLastTabElement;
  @override HtmlElement get _root            => _myRoot;

  ButtonElement        get _cancelButtonElement => _root.querySelector('.cancel');
  ButtonElement        get _deleteButtonElement => _root.querySelector('.delete');
  HeadingElement       get _headerElement       => _root.querySelector('h4');
  ElementList<Element> get _inputFields         => _root.querySelectorAll('[input-field]');
  ButtonElement        get _saveButtonElement   => _root.querySelector('.save');
  InputElement         get _startHourElement    => _root.querySelector('.start-hour');
  InputElement         get _startMinuteElement  => _root.querySelector('.start-minute');
  InputElement         get _startDayElement     => _root.querySelector('.start-day');
  InputElement         get _startMonthElement   => _root.querySelector('.start-month');
  InputElement         get _startYearElement    => _root.querySelector('.start-year');
  InputElement         get _stopHourElement     => _root.querySelector('.stop-hour');
  InputElement         get _stopMinuteElement   => _root.querySelector('.stop-minute');
  InputElement         get _stopDayElement      => _root.querySelector('.stop-day');
  InputElement         get _stopMonthElement    => _root.querySelector('.stop-month');
  InputElement         get _stopYearElement     => _root.querySelector('.stop-year');
  ElementList<Element> get _tabElements         => _root.querySelectorAll('[tabindex]');
  TextAreaElement      get _textAreaElement     => _root.querySelector('textarea');

  /**
   * Set the widget header.
   */
  set header(String headline) => _headerElement.text = headline;

  /**
   * Return the click event stream for the cancel button.
   */
  Stream<MouseEvent> get onCancel => _cancelButtonElement.onClick;

  /**
   * Return the click event stream for the delete button.
   */
  Stream<MouseEvent> get onDelete => _deleteButtonElement.onClick;

  /**
   * Return the click event stream for the save button.
   */
  Stream<MouseEvent> get onSave => _saveButtonElement.onClick;

  void _registerEventListeners() {
    /// Enables focused element memory for this widget.
    _tabElements.forEach((HtmlElement element) {
      element.onFocus.listen((Event event) => _myFocusElement = (event.target as HtmlElement));
    });

    /// NOTE (TL): These onInput listeners is here because it's a bit of a pain
    /// to put them in the view. Also I don't think it's too insane to consider
    /// the inputs of this widget to have some intrinsic management of which
    /// values are allowed and which are not, especially considering the HTML5
    /// type="number" attribute.
    _textAreaElement.onInput   .listen((_) => _toggleButtons());
    _startHourElement.onInput  .listen((_) => _sanitizeInput(_startHourElement));
    _startMinuteElement.onInput.listen((_) => _sanitizeInput(_startMinuteElement));
    _startDayElement.onInput   .listen((_) => _sanitizeInput(_startDayElement));
    _startMonthElement.onInput .listen((_) => _sanitizeInput(_startMonthElement));
    _startYearElement.onInput  .listen((_) => _sanitizeInput(_startYearElement));
    _stopHourElement.onInput   .listen((_) => _sanitizeInput(_stopHourElement));
    _stopMinuteElement.onInput .listen((_) => _sanitizeInput(_stopMinuteElement));
    _stopDayElement.onInput    .listen((_) => _sanitizeInput(_stopDayElement));
    _stopMonthElement.onInput  .listen((_) => _sanitizeInput(_stopMonthElement));
    _stopYearElement.onInput   .listen((_) => _sanitizeInput(_stopYearElement));
  }

  void _sanitizeInput(InputElement input) {
    if(input.validity.badInput) {
      input.classes.toggle('bad-input', true);
    } else {
      input.classes.toggle('bad-input', false);
    }

    _toggleButtons();
  }

  /**
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * last tab element as this depends on the state of the buttons.
   */
  void _toggleButtons() {
    bool toggle = !_inputFields.any((element) => element.value.isEmpty);

    _deleteButtonElement.disabled = !toggle;
    _saveButtonElement.disabled   = !toggle;

    _myLastTabElement = toggle ? _saveButtonElement : _cancelButtonElement;
  }
}
