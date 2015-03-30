part of view;

/**
 * Component for creating/editing and saving/sending messages.
 */
class MessageCompose extends Widget {
  HtmlElement       _firstTabElement;
  HtmlElement       _focusOnMe;
  HtmlElement       _lastTabElement;
  Place             _myPlace;
  DomMessageCompose _dom;

  /**
   * [root] is the parent element of the widget, and [_myPlace] is the [Place]
   * object that this widget reacts on when Navigate.go fires.
   */
  MessageCompose(DomMessageCompose this._dom, Place this._myPlace) {
    _focusOnMe       = _dom.callerNameInput;
    _firstTabElement = _dom.callerNameInput;
    _lastTabElement  = _dom.draftInput;

    _registerEventListeners();
  }

  void _activateMe(_) {
    _navigateToMyPlace();
  }

  void _buttonCancelHandler() {

  }

  @override
  HtmlElement get focusElement => _focusOnMe;

  /**
   * Focus on [_lastTabElement] when [_firstTabElement] is in focus and a
   * Shift+Tab keyboard event is captured.
   */
  void _handleShiftTab(KeyboardEvent event) {
    if(_active && _focusOnMe == _firstTabElement) {
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
      event.preventDefault();
      _firstTabElement.focus();
    }
  }

  @override
  Place get myPlace => _myPlace;

  void _registerEventListeners() {
    _navigate.onGo.listen(_setWidgetState);

    _dom.root.onClick.listen(_activateMe);

    _hotKeys.onAltB    .listen(_activateMe);
    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);

    /// Enables focused element memory for this widget.
    _dom.root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
      element.onFocus.listen(_setFocusOnMe);
    });

    _dom.showRecipientsSpan.onMouseOver.listen(_toggleRecipients);
    _dom.showRecipientsSpan.onMouseOut .listen(_toggleRecipients);

    _dom.callerNameInput.onInput.listen(_toggleButtons);
    _dom.messageTextarea.onInput.listen(_toggleButtons);

    _dom.cancelButton.onClick.listen(null);
    _dom.saveButton  .onClick.listen(null);
    _dom.sendButton  .onClick.listen(null);
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
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * [_lastTabElement] as this depends on the state of the buttons.
   */
  void _toggleButtons(_) {
    bool toggle = !(_dom.callerNameInput.value.trim().isNotEmpty && _dom.messageTextarea.value.trim().isNotEmpty);
    _dom.cancelButton.disabled = toggle;
    _dom.saveButton.disabled = toggle;
    _dom.sendButton.disabled = toggle;

    _lastTabElement = toggle ? _dom.draftInput : _dom.sendButton;
  }

  /**
   * Show/hide the recipients list.
   */
  void _toggleRecipients(_) {
    _dom.recipientsDiv.classes.toggle('recipients-hidden');
  }
}
