part of view;

class CalendarEditor extends Widget {
  HtmlElement           _firstTabElement;
  HtmlElement           _focusOnMe;
  HtmlElement           _lastTabElement;
  static CalendarEditor _singleton;
  UICalendarEditor      _ui;

  factory CalendarEditor(UICalendarEditor ui) {
    if(_singleton == null) {
      _singleton = new CalendarEditor._internal(ui);
    }

    return _singleton;
  }

  CalendarEditor._internal(UICalendarEditor this._ui) {
    _focusOnMe       = _ui.textArea;
    _firstTabElement = _ui.textArea;
    _lastTabElement  = _ui.stopYear;

    _registerEventListeners();
  }

  /**
   *
   */
  void activate(String data) {
    _setTabIndex(1);
    _setVisible();
    _ui.header.text = data;
  }

  /**
   *
   */
  void _cancel() {
    _setTabIndex(-1);
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

  HtmlElement get focusElement => _ui.textArea;

  /**
   * Focus on [_lastTabElement] when [_firstTabElement] is in focus and a
   * Shift+Tab keyboard event is captured.
   */
  void _handleShiftTab(KeyboardEvent event) {
    if(_focusOnMe == _firstTabElement) {
      event.preventDefault();
      _lastTabElement.focus();
    }
  }

  /**
     * Focus on [_firstTabElement] when [_lastTabElement] is in focus and a Tab
     * keyboard event is captured.
     */
  void _handleTab(KeyboardEvent event) {
    if(_focusOnMe == _lastTabElement) {
      event.preventDefault();
      _firstTabElement.focus();
    }
  }

  Place get myPlace => null;

  /**
   *
   */
  void _registerEventListeners() {
    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);

    /// Enables focused element memory for this widget.
    _ui.root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
      print(element);
      element.onFocus.listen(_setFocusOnMe);
    });

    _ui.startHour.onInput  .listen((_) => _sanitizeInput(_ui.startHour));
    _ui.startMinute.onInput.listen((_) => _sanitizeInput(_ui.startMinute));
    _ui.startDay.onInput   .listen((_) => _sanitizeInput(_ui.startDay));
    _ui.startMonth.onInput .listen((_) => _sanitizeInput(_ui.startMonth));
    _ui.startYear.onInput  .listen((_) => _sanitizeInput(_ui.startYear));
    _ui.stopHour.onInput   .listen((_) => _sanitizeInput(_ui.stopHour));
    _ui.stopMinute.onInput .listen((_) => _sanitizeInput(_ui.stopMinute));
    _ui.stopDay.onInput    .listen((_) => _sanitizeInput(_ui.stopDay));
    _ui.stopMonth.onInput  .listen((_) => _sanitizeInput(_ui.stopMonth));
    _ui.stopYear.onInput   .listen((_) => _sanitizeInput(_ui.stopYear));

    _ui.cancelButton.onClick.listen((_) => _cancel());
    _ui.deleteButton.onClick.listen((_) => _delete());
    _ui.saveButton.onClick  .listen((_) => _save());
  }

  HtmlElement get root => _ui.root;

  /**
   * Enables focus memory for this widget, so we can blur the widget and come
   * back and have the same field focused as when we left.
   */
  void _setFocusOnMe(Event event) {
    _focusOnMe = (event.target as HtmlElement);
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

    _toggleButtons();
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
    _ui.root.hidden = true;
    _ui.textArea.focus();
  }

  /**
   *
   */
  void _setVisible() {
    _ui.root.hidden = false;
    _ui.textArea.focus();
  }

  /**
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * [_lastTabElement] as this depends on the state of the buttons.
   */
  void _toggleButtons() {
    bool toggle = _ui.root.querySelectorAll('input').any((InputElement element) => element.value.isEmpty);

    _ui.deleteButton.disabled = toggle;
    _ui.saveButton.disabled   = toggle;

    _lastTabElement = toggle ? _ui.stopYear : _ui.saveButton;
  }
}
