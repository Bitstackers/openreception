part of view;

class CalendarEditor extends Widget {
  Place                 _myPlace;
  UICalendarEditor      _ui;

  CalendarEditor(UICalendarEditor this._ui, this._myPlace) {
    _ui.focusElement    = _ui.textAreaElement;
    _ui.firstTabElement = _ui.textAreaElement;
    _ui.lastTabElement  = _ui.cancelButtonElement;

    _registerEventListeners();
  }

  @override Place   get myPlace => _myPlace;
  @override UIModel get ui      => _ui;

  void _cancel(_) {
    /// TODO (TL):
    /// Clear form.
    /// Set focusElement to default.
    /// Navigate away (history.back perhaps??)
    print('view.CalendarEditor._cancel not fully implemented');
  }

  void _delete(_) {
    /// TODO (TL):
    /// Delete calendar entry.
    /// Call _cancel().
    print('view.CalendarEditor._delete not fully implemented');
  }

  void _registerEventListeners() {
    /// TODO (TL): On navigation to this widget:
    /// Figure out whether I got started from contact or reception calendar.
    /// Figure out whether this is a new calendar entry or an edit?
    /// If new: Add "now" data to the widget.
    /// If edit: Add data from the calendar entry to the widget.
    _navigate.onGo.listen(_setWidgetState);

    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);

    /// Enables focused element memory for this widget.
    _ui.tabElements.forEach((HtmlElement element) {
      element.onFocus.listen(_setFocusOnMe);
    });

    _ui.textAreaElement.onInput   .listen((_) => _toggleButtons());
    _ui.startHourElement.onInput  .listen((_) => _sanitizeInput(_ui.startHourElement));
    _ui.startMinuteElement.onInput.listen((_) => _sanitizeInput(_ui.startMinuteElement));
    _ui.startDayElement.onInput   .listen((_) => _sanitizeInput(_ui.startDayElement));
    _ui.startMonthElement.onInput .listen((_) => _sanitizeInput(_ui.startMonthElement));
    _ui.startYearElement.onInput  .listen((_) => _sanitizeInput(_ui.startYearElement));
    _ui.stopHourElement.onInput   .listen((_) => _sanitizeInput(_ui.stopHourElement));
    _ui.stopMinuteElement.onInput .listen((_) => _sanitizeInput(_ui.stopMinuteElement));
    _ui.stopDayElement.onInput    .listen((_) => _sanitizeInput(_ui.stopDayElement));
    _ui.stopMonthElement.onInput  .listen((_) => _sanitizeInput(_ui.stopMonthElement));
    _ui.stopYearElement.onInput   .listen((_) => _sanitizeInput(_ui.stopYearElement));

    _ui.cancelButtonElement.onClick.listen(_cancel);
    _ui.deleteButtonElement.onClick.listen(_delete);
    _ui.saveButtonElement  .onClick.listen(_save);
  }

  /**
   * Enables focus memory for this widget, so we can blur the widget and come
   * back and have the same field focused as when we left.
   */
  void _setFocusOnMe(Event event) {
    _ui.focusElement = (event.target as HtmlElement);
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
  }

  void _save(_) {
    /// TODO (TL):
    /// Validate input data
    /// Save calendar entry.
    /// Call _cancel().
    print('view.CalendarEditor._save not fully implemented');
  }

  /**
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * last tab element as this depends on the state of the buttons.
   */
  void _toggleButtons() {
    bool toggle = _validInput();

    _ui.deleteButtonElement.disabled = !toggle;
    _ui.saveButtonElement.disabled   = !toggle;

    _ui.lastTabElement = toggle ? _ui.saveButtonElement : _ui.cancelButtonElement;
  }

  /**
   * Return true when all input fields and the textarea contain data.
   */
  bool _validInput() =>
      !_ui.inputElements.any((InputElement element) => element.value.isEmpty) &&
          _ui.textAreaElement.value.isNotEmpty;
}
