/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

/**
 * Provides methods to manipulate and extract data from the widget UX parts.
 */
class UIMessageCompose extends UIModel {
  HtmlElement _myFirstTabElement;
  HtmlElement _myFocusElement;
  HtmlElement _myLastTabElement;
  final DivElement _myRoot;

  /**
   * Constructor.
   */
  UIMessageCompose(DivElement this._myRoot) {
    _myFocusElement = _callerNameInput;
    _myFirstTabElement = _callerNameInput;
    _myLastTabElement = _urgentInput;

    _haveCalledInput.checked = true;

    _setupLocalKeys();
    _observers();
  }

  @override HtmlElement get _firstTabElement => _myFirstTabElement;
  @override HtmlElement get _focusElement => _myFocusElement;
  @override HtmlElement get _lastTabElement => _myLastTabElement;
  @override HtmlElement get _root => _myRoot;

  InputElement get _callerNameInput => _root.querySelector('.names input.caller');
  InputElement get _callsBackInput => _root.querySelector('.checks .calls-back');
  InputElement get _cellphoneInput => _root.querySelector('.phone-numbers input.cell');
  InputElement get _companyNameInput => _root.querySelector('.names input.company');
  InputElement get _extensionInput => _root.querySelector('.phone-numbers input.extension');
  InputElement get _haveCalledInput => _root.querySelector('.checks .have-called');
  InputElement get _landlineInput => _root.querySelector('.phone-numbers input.landline');
  TextAreaElement get _messageTextarea => _root.querySelector('.message textarea');
  InputElement get _pleaseCallInput => _root.querySelector('.checks .please-call');
  DivElement get _prerequisites => _root.querySelector('.prerequisites');
  DivElement get _recipientsDiv => _root.querySelector('.recipients');
  OListElement get _recipientsList => _root.querySelector('.recipients .generic-widget-list');
  ButtonElement get _saveButton => _root.querySelector('.buttons .save');
  ButtonElement get _sendButton => _root.querySelector('.buttons .send');
  SpanElement get _showRecipientsSpan => _root.querySelector('.show-recipients');
  SpanElement get _showRecipientsText => _showRecipientsSpan.querySelector(':first-child');
  SpanElement get _showNoRecipientsText => _showRecipientsSpan.querySelector(':last-child');
  ElementList<Element> get _tabElements => _root.querySelectorAll('[tabindex]');
  InputElement get _urgentInput => _root.querySelector('.checks .urgent');

  /**
   * If a valid input field detects a mouse click, focus it. Valid input fields
   * are those that are part of the [_tabElements] list.
   */
  void _focusFromClick(MouseEvent event) {
    if (_tabElements.contains(event.target) || (event.target is LabelElement)) {
      (event.target as HtmlElement).focus();
    } else {
      event.preventDefault();
    }
  }

  /**
   * Sets focus on whichever widget element is currently considered the widget
   * default.
   */
  void focusOnCurrentFocusElement() {
    _focusElement.focus();
  }

  /**
   * Extracts a ORModel.Message from the information stored in the widget.
   *
   * This does NOT set the 'context' field.
   */
  ORModel.Message get message {
    final ORModel.CallerInfo callerInfo = new ORModel.CallerInfo.empty()
      ..cellPhone = _cellphoneInput.value.trim()
      ..company = _companyNameInput.value.trim()
      ..localExtension = _extensionInput.value.trim()
      ..name = _callerNameInput.value.trim()
      ..phone = _landlineInput.value.trim();
    final ORModel.MessageFlag messageFlag = new ORModel.MessageFlag.empty()
      ..called = _haveCalledInput.checked
      ..pleaseCall = _pleaseCallInput.checked
      ..urgent = _urgentInput.checked
      ..willCallBack = _callsBackInput.checked;

    return new ORModel.Message.empty()
      ..body = _messageTextarea.value.trim()
      ..callerInfo = callerInfo
      ..flag = messageFlag
      ..recipients = recipients;
  }

  /**
   * Populate widget fields with [message].
   */
  void set message(ORModel.Message message) {
    _callerNameInput.value = message.callerInfo.name;
    _companyNameInput.value = message.callerInfo.company;
    _landlineInput.value = message.callerInfo.phone;
    _cellphoneInput.value = message.callerInfo.cellPhone;
    _extensionInput.value = message.callerInfo.localExtension;
    _messageTextarea.value = message.body;
    _haveCalledInput.checked = message.flag.called;
    _pleaseCallInput.checked = message.flag.pleaseCall;
    _callsBackInput.checked = message.flag.willCallBack;
    _urgentInput.checked = message.flag.urgent;

    _toggleButtons();
  }

  /**
   * Set the message prerequisites for the current contact.
   *
   * Ignores whitespace only elements.
   */
  void set messagePrerequisites(List<String> prerequisites) {
    prerequisites.removeWhere((String prereg) => prereg.trim().isEmpty);

    if (prerequisites.isEmpty) {
      _prerequisites.style.display = 'none';
    } else {
      _prerequisites.style.display = 'block';
      _prerequisites.text = prerequisites.join(', ');
    }
  }

  /**
   * Observers.
   */
  void _observers() {
    _root.onKeyDown.listen(_keyboard.press);

    _root.onMouseDown.listen(_focusFromClick);

    _hotKeys.onCtrlSpace.listen((_) => _toggleRecipients());

    /// Enables focused element memory for this widget.
    _tabElements.forEach((Element element) {
      element.onFocus.listen((Event event) => _myFocusElement = (event.target as HtmlElement));
    });

    _showRecipientsSpan.onClick.listen((MouseEvent _) => _toggleRecipients());

    _callerNameInput.onInput.listen((Event _) => _toggleButtons());
    _messageTextarea.onInput.listen((Event _) => _toggleButtons());
  }

  /**
   * Return the click event stream for the save button.
   */
  Stream<MouseEvent> get onSave => _saveButton.onClick;

  /**
   * Return the click event stream for the send button.
   */
  Stream<MouseEvent> get onSend => _sendButton.onClick;

  /**
   * Return the Set of [ORModel.MessageRecipient]. May return the empty set.
   */
  Set<ORModel.MessageRecipient> get recipients {
    final String recipientsList = _recipientsList.dataset['recipients-list'];

    if (recipientsList != null && recipientsList.isNotEmpty) {
      return new Set<ORModel.MessageRecipient>.from(
          JSON.decode(recipientsList).map(ORModel.MessageRecipient.decode));
    } else {
      return new Set<ORModel.MessageRecipient>();
    }
  }

  /**
   * Add [recipients] to the recipients list.
   */
  void set recipients(Set<ORModel.MessageRecipient> recipients) {
    _showRecipientsText.hidden = true;
    _showNoRecipientsText.hidden = true;

    String contactString(ORModel.MessageRecipient recipient) =>
        '${recipient.contactName} @ ${recipient.receptionName} (${recipient.address})';

    Iterable<ORModel.MessageRecipient> toRecipients() =>
        recipients.where((ORModel.MessageRecipient r) => r.role == ORModel.Role.TO);

    Iterable<ORModel.MessageRecipient> ccRecipients() =>
        recipients.where((ORModel.MessageRecipient r) => r.role == ORModel.Role.CC);

    Iterable<ORModel.MessageRecipient> bccRecipients() =>
        recipients.where((ORModel.MessageRecipient r) => r.role == ORModel.Role.BCC);

    List<LIElement> list = new List<LIElement>();

    Iterable maps = recipients.map((ORModel.MessageRecipient r) => r.toJson());
    _recipientsList.dataset['recipients-list'] = JSON.encode(maps.toList());

    toRecipients().forEach((ORModel.MessageRecipient recipient) {
      list.add(new LIElement()..text = contactString(recipient));
    });

    ccRecipients().forEach((ORModel.MessageRecipient recipient) {
      list.add(new LIElement()
        ..text = contactString(recipient)
        ..classes.add('cc'));
    });

    bccRecipients().forEach((ORModel.MessageRecipient recipient) {
      list.add(new LIElement()
        ..text = contactString(recipient)
        ..classes.add('bcc'));
    });

    _recipientsList.children = list;

    _showRecipientsText.hidden = list.isEmpty;
    _showNoRecipientsText.hidden = list.isNotEmpty;

    _toggleButtons();
  }

  /**
   * Reset the widget fields to their pristine state and set focus on the
   * message body field. By default shis maintains the recipient list of the
   * currently selected contact.
   *
   * If [pristine] is true, then also clear and close the recipient list.
   */
  void reset({pristine: false}) {
    _callerNameInput.value = '';
    _callsBackInput.checked = false;
    _cellphoneInput.value = '';
    _companyNameInput.value = '';
    _extensionInput.value = '';
    _haveCalledInput.checked = true;
    _landlineInput.value = '';
    _messageTextarea.value = '';
    messagePrerequisites = [];
    _pleaseCallInput.checked = false;
    _urgentInput.checked = false;

    _myFocusElement = _callerNameInput;
    _myFirstTabElement = _callerNameInput;
    _myLastTabElement = _urgentInput;

    _toggleButtons();

    if (pristine) {
      _recipientsList.dataset['recipients-list'] = '';
      _recipientsList.children.clear();
      _recipientsDiv.classes.toggle('recipients-hidden', true);
      _showRecipientsSpan.classes.toggle('active', false);
      _showRecipientsText.hidden = true;
      _showNoRecipientsText.hidden = false;
    }
  }

  /**
   * Reset the recipients list and toggle buttons when receiving and empty contact.
   */
  void resetOnEmptyContact() {
    messagePrerequisites = [];
    _recipientsList.dataset['recipients-list'] = '';
    _recipientsList.children.clear();
    _showRecipientsText.hidden = true;
    _showNoRecipientsText.hidden = false;

    _toggleButtons();
  }

  /**
   * Setup keys and bindings to methods specific for this widget.
   */
  void _setupLocalKeys() {
    final Map<String, EventListener> bindings = {
      'Ctrl+enter': (Event _) => _sendButton.click(),
      'Ctrl+s': (Event _) => _saveButton.click()
    };

    _hotKeys.registerKeysPreventDefault(_keyboard, bindings);
    _hotKeys.registerKeys(_keyboard, _defaultKeyMap());
  }

  /**
   * Enable/disable the widget buttons and as a sideeffect set the value of
   * [_myLastTabElement] as this depends on the state of the buttons.
   */
  void _toggleButtons() {
    final bool toggle =
        !(_callerNameInput.value.trim().isNotEmpty && _messageTextarea.value.trim().isNotEmpty);

    _saveButton.disabled = toggle || _recipientsList.children.isEmpty;
    _sendButton.disabled = toggle || _recipientsList.children.isEmpty;

    _myLastTabElement = toggle ? _urgentInput : _sendButton;
  }

  /**
   * Show/hide the recipients list.
   */
  void _toggleRecipients() {
    _recipientsDiv.classes.toggle('recipients-hidden');
    _showRecipientsSpan.classes.toggle('active');
  }
}
