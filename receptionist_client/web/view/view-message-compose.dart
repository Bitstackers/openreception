part of view;

class MessageCompose {
  static final MessageCompose _singleton = new MessageCompose._internal();
  factory MessageCompose() => _singleton;

  /**
   *
   */
  MessageCompose._internal() {
    _focusOnMe = _callerName;

    _registerEventListeners();
  }

  static final DivElement _root = querySelector('#message-compose');

  final InputElement    _callerName     = _root.querySelector('.names input.caller');
  final InputElement    _callsBack      = _root.querySelector('.checks .calls-back');
  final ButtonElement   _cancel         = _root.querySelector('.buttons .cancel');
  final InputElement    _cell           = _root.querySelector('.phone-numbers input.cell');
  final InputElement    _companyName    = _root.querySelector('.names input.company');
  final InputElement    _draft          = _root.querySelector('.checks .draft');
  final InputElement    _extension      = _root.querySelector('.phone-numbers input.extension');
        HtmlElement     _focusOnMe;
  final InputElement    _hasCalled      = _root.querySelector('.checks .has-called');
  final Place           _here           = new Place('context-home', _root.id);
  final InputElement    _landline       = _root.querySelector('.phone-numbers input.landline');
  final TextAreaElement _message        = _root.querySelector('.message textarea');
  final InputElement    _pleaseCall     = _root.querySelector('.checks .please-call');
  final DivElement      _recipients     = _root.querySelector('.recipients');
  final ButtonElement   _save           = _root.querySelector('.buttons .save');
  final ButtonElement   _send           = _root.querySelector('.buttons .send');
  final SpanElement     _showRecipients = _root.querySelector('.show-recipients');
  final InputElement    _urgent         = _root.querySelector('.checks .urgent');

  /**
   *
   */
  void _registerEventListeners() {
    _root    .onClick.listen((_) => _activateMe(_root, _here));
    _hotKeys .onAltB .listen((_) => _activateMe(_root, _here));
    _navigate.onGo   .listen((Place place) => _setWidgetState(_root, _focusOnMe, place));

    _showRecipients.onMouseOver.listen((_) => _toggleRecipients());
    _showRecipients.onMouseOut.listen((_) => _toggleRecipients());

    /// This is here to enable the widget to remember the last focused element.
    _root.querySelectorAll('[tabindex]').forEach((HtmlElement element) {
      element.onFocus.listen(_setFocusOnMe);
    });
  }

  /**
   * Assign [event].target to [_focusOnMe]
   * This enables focus memory for this widget.
   */
  void _setFocusOnMe(Event event) {
    _focusOnMe = (event.target as HtmlElement);
  }

  /**
   *
   */
  void _toggleRecipients() {
    _recipients.classes.toggle('recipients-hidden');
  }
}
