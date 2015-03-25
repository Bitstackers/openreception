part of view;

/**
 * Component for creating/editing and saving/sending messages.
 */
class MessageCompose extends Widget {
  HtmlElement      _firstTabElement;
  HtmlElement      _focusOnMe;
  HtmlElement      _lastTabElement;
  Place            _myPlace;
  UIMessageCompose _ui;

  /**
   * [root] is the parent element of the widget, and [_myPlace] is the [Place]
   * object that this widget reacts on when Navigate.go fires.
   */
  MessageCompose(UIMessageCompose this._ui, Place this._myPlace) {
    _focusOnMe       = _ui.callerNameInput;
    _firstTabElement = _ui.callerNameInput;
    _lastTabElement  = _ui.draftInput;

    _registerEventListeners();
  }

  void _activateMe(_) {
    _activate();
  }

  void _buttonCancelHandler() {

  }

  HtmlElement get focusElement => _focusOnMe;

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

  Place get myPlace => _myPlace;

  void _registerEventListeners() {
    _navigate.onGo.listen(_setWidgetState);

    _ui.root.onClick.listen(_activateMe);

    _hotKeys.onAltB    .listen(_activateMe);
    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);

    /// Enables focused element memory for this widget.
    _ui.root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
      element.onFocus.listen(_setFocusOnMe);
    });

    _ui.showRecipientsSpan.onMouseOver.listen(_toggleRecipients);
    _ui.showRecipientsSpan.onMouseOut .listen(_toggleRecipients);

    _ui.callerNameInput.onInput.listen(_toggleButtons);
    _ui.messageTextarea.onInput.listen(_toggleButtons);

    _ui.cancelButton.onClick.listen(null);
    _ui.saveButton  .onClick.listen(null);
    _ui.sendButton  .onClick.listen(null);
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
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * [_lastTabElement] as this depends on the state of the buttons.
   */
  void _toggleButtons(_) {
    bool toggle = !(_ui.callerNameInput.value.trim().isNotEmpty && _ui.messageTextarea.value.trim().isNotEmpty);
    _ui.cancelButton.disabled = toggle;
    _ui.saveButton.disabled = toggle;
    _ui.sendButton.disabled = toggle;

    _lastTabElement = toggle ? _ui.draftInput : _ui.sendButton;
  }

  /**
   * Show/hide the recipients list.
   */
  void _toggleRecipients(_) {
    _ui.recipientsDiv.classes.toggle('recipients-hidden');
  }
}
