part of model;

class UIMessageCompose extends UIModel {
  final Keyboard   _keyboard = new Keyboard();
  HtmlElement      _myFirstTabElement;
  HtmlElement      _myFocusElement;
  HtmlElement      _myLastTabElement;
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIMessageCompose(DivElement this._myRoot) {
    _help.text = 'alt+b';

    _myFocusElement    = _messageTextarea;
    _myFirstTabElement = _callerNameInput;
    _myLastTabElement  = _draftInput;

    _setupWidgetKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _myFirstTabElement;
  @override HtmlElement get _focusElement    => _myFocusElement;
  @override SpanElement get _header          => _root.querySelector('h4 > span');
  @override SpanElement get _headerExtra     => _root.querySelector('h4 > span + span');
  @override DivElement  get _help            => _root.querySelector('div.help');
  @override HtmlElement get _lastTabElement  => _myLastTabElement;
  @override HtmlElement get _root            => _myRoot;

  InputElement         get _callerNameInput    => _root.querySelector('.names input.caller');
  InputElement         get _callsBackInput     => _root.querySelector('.checks .calls-back');
  ButtonElement        get _cancelButton       => _root.querySelector('.buttons .cancel');
  InputElement         get _cellphoneInput     => _root.querySelector('.phone-numbers input.cell');
  InputElement         get _companyNameInput   => _root.querySelector('.names input.company');
  InputElement         get _draftInput         => _root.querySelector('.checks .draft');
  InputElement         get _extensionInput     => _root.querySelector('.phone-numbers input.extension');
  InputElement         get _landlineInput      => _root.querySelector('.phone-numbers input.landline');
  TextAreaElement      get _messageTextarea    => _root.querySelector('.message textarea');
  InputElement         get _pleaseCallInput    => _root.querySelector('.checks .please-call');
  DivElement           get _recipientsDiv      => _root.querySelector('.recipients');
  ButtonElement        get _saveButton         => _root.querySelector('.buttons .save');
  ButtonElement        get _sendButton         => _root.querySelector('.buttons .send');
  SpanElement          get _showRecipientsSpan => _root.querySelector('.show-recipients');
  ElementList<Element> get _tabElements        => _root.querySelectorAll('[tabindex]');
  InputElement         get _urgentInput        => _root.querySelector('.checks .urgent');

  /**
   * Make sure we never take focus away from an already focused element, unless
   * we're [event].target is another widget member with tabindex set > 0.
   */
  void _handleMouseDown(MouseEvent event) {
    if((event.target as HtmlElement).tabIndex < 1) {
      /// NOTE (TL): This keeps focus on the currently focused field when
      /// clicking the _root.
      event.preventDefault();
    }
  }

  /**
   * Return the click event stream for the cancel button.
   */
  Stream<MouseEvent> get onCancel => _cancelButton.onClick;

  /**
   * Return the click event stream for the save button.
   */
  Stream<MouseEvent> get onSave => _saveButton.onClick;

  /**
   * Return the click event stream for the send button.
   */
  Stream<MouseEvent> get onSend => _sendButton.onClick;

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);

    _root.onMouseDown.listen(_handleMouseDown);

    /// Enables focused element memory for this widget.
    _tabElements.forEach((HtmlElement element) {
      element.onFocus.listen((Event event) => _myFocusElement = (event.target as HtmlElement));
    });

    _showRecipientsSpan.onMouseOver.listen(_toggleRecipients);
    _showRecipientsSpan.onMouseOut .listen(_toggleRecipients);

    _callerNameInput.onInput.listen(_toggleButtons);
    _messageTextarea.onInput.listen(_toggleButtons);
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupWidgetKeys() {
    final Map<String, EventListener> bindings =
        {'Shift+Tab': _handleShiftTab,
         'Tab'      : _handleTab};

    _hotKeys.registerKeys(_keyboard, bindings);
  }

  /**
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * [_myLastTabElement] as this depends on the state of the buttons.
   */
  void _toggleButtons(_) {
    final bool toggle = !(_callerNameInput.value.trim().isNotEmpty && _messageTextarea.value.trim().isNotEmpty);

    _cancelButton.disabled = toggle;
    _saveButton.disabled = toggle;
    _sendButton.disabled = toggle;

    _myLastTabElement = toggle ? _draftInput : _sendButton;
  }

  /**
   * Show/hide the recipients list.
   */
  void _toggleRecipients(_) {
    _recipientsDiv.classes.toggle('recipients-hidden');
  }
}
