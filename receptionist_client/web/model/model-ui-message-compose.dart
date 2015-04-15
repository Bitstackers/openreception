part of model;

class UIMessageCompose extends UIModel {
  HtmlElement      _myFirstTabElement;
  HtmlElement      _myFocusElement;
  HtmlElement      _myLastTabElement;
  final DivElement _myRoot;

  UIMessageCompose(DivElement this._myRoot) {
    _myFocusElement    = _messageTextarea;
    _myFirstTabElement = _callerNameInput;
    _myLastTabElement  = _draftInput;

    _registerEventListeners();
  }

  @override HtmlElement    get _firstTabElement => _myFirstTabElement;
  @override HtmlElement    get _focusElement    => _myFocusElement;
  @override HeadingElement get _header          => _root.querySelector('h4');
  @override DivElement     get _help            => _root.querySelector('div.help');
  @override HtmlElement    get _lastTabElement  => _myLastTabElement;
  @override HtmlElement    get _root            => _myRoot;

  InputElement         get _callerNameInput    => _root.querySelector('.names input.caller');
  InputElement         get _callsBackInput     => _root.querySelector('.checks .calls-back');
  ButtonElement        get _cancelButton       => _root.querySelector('.buttons .cancel');
  InputElement         get _cellphoneInput     => _root.querySelector('.phone-numbers input.cell');
  InputElement         get _companyNameInput   => _root.querySelector('.names input.company');
  InputElement         get _draftInput         => _root.querySelector('.checks .draft');
  InputElement         get _extensionInput     => _root.querySelector('.phone-numbers input.extension');
  InputElement         get _hasCalledInput     => _root.querySelector('.checks .has-called');
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

  void _registerEventListeners() {
    /// Enables focused element memory for this widget.
    _tabElements.forEach((HtmlElement element) {
      element.onFocus.listen((Event event) => _myFocusElement = (event.target as HtmlElement));
    });

    _hotKeys.onTab     .listen(_handleTab);
    _hotKeys.onShiftTab.listen(_handleShiftTab);

    _showRecipientsSpan.onMouseOver.listen(_toggleRecipients);
    _showRecipientsSpan.onMouseOut .listen(_toggleRecipients);

    _callerNameInput.onInput.listen(_toggleButtons);
    _messageTextarea.onInput.listen(_toggleButtons);
  }

  /**
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * [_myLastTabElement] as this depends on the state of the buttons.
   */
  void _toggleButtons(_) {
    bool toggle = !(_callerNameInput.value.trim().isNotEmpty && _messageTextarea.value.trim().isNotEmpty);

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
