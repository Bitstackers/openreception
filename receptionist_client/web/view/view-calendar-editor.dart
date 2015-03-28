part of view;

class CalendarEditor extends Widget {
  HtmlElement           _firstTabElement;
  HtmlElement           _focusOnMe;
  HtmlElement           _lastTabElement;
  static CalendarEditor _singleton;
  DomCalendarEditor     _dom;

  factory CalendarEditor(DomCalendarEditor ui) {
    if(_singleton == null) {
      _singleton = new CalendarEditor._internal(ui);
    }

    return _singleton;
  }

  CalendarEditor._internal(DomCalendarEditor this._dom) {
    _focusOnMe       = _dom.textArea;
    _firstTabElement = _dom.textArea;
    _lastTabElement  = _dom.cancelButton;

    _registerEventListeners();
  }

  /**
   *
   */
  void activate(String data) {
    _active = true;
    _setTabIndex(1);
<<<<<<< Updated upstream
    _setVisible();
    _ui.header.text = data;
=======
//    _setVisible();
    _dom.header.text = data;
>>>>>>> Stashed changes
  }

  /**
   *
   */
  void _cancel() {
    _active = false;
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

  @override
  HtmlElement get focusElement => _dom.textArea;

  /**
   * Focus on [_lastTabElement] when [_firstTabElement] is in focus and a
   * Shift+Tab keyboard event is captured.
   */
  void _handleShiftTab(KeyboardEvent event) {
    if(_active && _focusOnMe == _firstTabElement) {
      print('editor ${_focusOnMe.hashCode}');
      event.preventDefault();
      _lastTabElement.focus();
    }
  }

  /**
     * Focus on [_firstTabElement] when [_lastTabElement] is in focus and a Tab
     * keyboard event is captured.
     */
  void _handleTab(KeyboardEvent event) {
    if(_active && _focusOnMe == _lastTabElement) {
      print('editor ${_focusOnMe.hashCode}');
      event.preventDefault();
      _firstTabElement.focus();
    }
  }

  /**
   *
   */
  void _registerEventListeners() {
    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);

    /// Enables focused element memory for this widget.
    _dom.root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
      element.onFocus.listen(_setFocusOnMe);
    });

    _dom.startHour.onInput  .listen((_) => _sanitizeInput(_dom.startHour));
    _dom.startMinute.onInput.listen((_) => _sanitizeInput(_dom.startMinute));
    _dom.startDay.onInput   .listen((_) => _sanitizeInput(_dom.startDay));
    _dom.startMonth.onInput .listen((_) => _sanitizeInput(_dom.startMonth));
    _dom.startYear.onInput  .listen((_) => _sanitizeInput(_dom.startYear));
    _dom.stopHour.onInput   .listen((_) => _sanitizeInput(_dom.stopHour));
    _dom.stopMinute.onInput .listen((_) => _sanitizeInput(_dom.stopMinute));
    _dom.stopDay.onInput    .listen((_) => _sanitizeInput(_dom.stopDay));
    _dom.stopMonth.onInput  .listen((_) => _sanitizeInput(_dom.stopMonth));
    _dom.stopYear.onInput   .listen((_) => _sanitizeInput(_dom.stopYear));

    _dom.cancelButton.onClick.listen((_) => _cancel());
    _dom.deleteButton.onClick.listen((_) => _delete());
    _dom.saveButton.onClick  .listen((_) => _save());
  }

  @override
  HtmlElement get root => _dom.root;

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
    bool toggle = _dom.root.querySelectorAll('input').any((InputElement element) => element.value.isEmpty);

    _dom.deleteButton.disabled = toggle;
    _dom.saveButton.disabled   = toggle;

    _lastTabElement = toggle ? _dom.cancelButton : _dom.saveButton;
  }
}
