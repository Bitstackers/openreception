/*                     This file is part of Bob
                   Copyright (C) 2014-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of view;

/**
 * View for a message being edited. This widget listens for [selectedMessagesChanged]
 * events and render the selected message.
 */
class MessageEdit {

  static const String className = '${libraryName}.Message';
  static const String NavShortcut = 'B';

  final Element      element;
  final Context      context;
        nav.Location location;

  Element         get header                    => this.element.querySelector('legend');
  InputElement    get callerNameField           => this.element.querySelector('input.name');
  InputElement    get callerCompanyField        => this.element.querySelector('input.company');
  InputElement    get callerPhoneField          => this.element.querySelector('input.phone');
  InputElement    get callerCellphoneField      => this.element.querySelector('input.cellphone');
  InputElement    get callerLocalExtensionField => this.element.querySelector('input.local-extension');
  InputElement    get contextReceptionIDField   => this.element.querySelector('input.context-reception-id');
  InputElement    get contextReceptionNameField => this.element.querySelector('input.context-reception-name');
  InputElement    get contextContactIDField     => this.element.querySelector('input.context-contact-id');
  InputElement    get contextContactNameField   => this.element.querySelector('input.context-contact-name');

  TextAreaElement get messageBodyField          => this.element.querySelector('textarea.message-body');

  /// Checkboxes
  InputElement get pleaseCall => this.element.querySelector('input.message-tag.pleasecall');
  InputElement get callsBack  => this.element.querySelector('input.message-tag.callsback');
  InputElement get hasCalled  => this.element.querySelector('input.message-tag.hascalled');
  InputElement get urgent     => this.element.querySelector('input.message-tag.urgent');
  InputElement get draft      => this.element.querySelector('input.message-tag.draft');

  /// Widget control buttons
  ButtonElement get saveButton   => this.element.querySelector('button.save');
  ButtonElement get resendButton => this.element.querySelector('button.resend');

  bool hasFocus = false;
  bool get muted     => this.context != Context.current;
  bool get inFocus   => nav.Location.isActive(this.element);

  UListElement get recipientsList => this.element.querySelector('.message-recipient-list');

  List<Element>   get nudges         => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  List<Element> focusElements;

  model.Reception reception = model.nullReception;
  model.Contact contact = model.nullContact;

  model.Message activeMessage = null;

  /**
   * Update the disabled property.
   *
   * Used for locking the input fields upon sending
   * a message, or when no contact is selected.
   */
  void set disabled(bool disabled) {
    this.element.classes.toggle("disabled", disabled);
    this.element.querySelectorAll('input').forEach((InputElement element) {
      element.disabled = disabled;
    });

    this.element.querySelectorAll('textarea').forEach((TextAreaElement element) {
      element.disabled = disabled;
    });

    this.element.querySelectorAll('button').forEach((ButtonElement element) {
      element.disabled = disabled;
    });
  }

  /**
   * Update the disabled property.
   *
   * Used for locking the input fields upon sending
   * a message, or when no contact is selected.
   */
  void set loading(bool isLoading) {
    this.disabled = isLoading;
    this.messageBodyField.classes.toggle('loading', isLoading);
  }


  /**
   * Update the tabable property.
   *
   * Used for enabling and disabling the tab button for the widget.
   */
  void set tabable (bool enable) {
    this.element.querySelectorAll('input').forEach((InputElement element) {
      element.tabIndex = enable ? 1 : -1;
    });

    this.element.querySelectorAll('textarea').forEach((TextAreaElement element) {
      element.tabIndex = enable ? 1 : -1;
    });

    this.element.querySelectorAll('button').forEach((ButtonElement element) {
      element.tabIndex = enable ? 1 : -1;
    });
  }

  /**
   * Clears out the content of the input fields and textareas within the widget.
   */
  void _clearInputFields() {

    const String context = '${className}._clear';

    this.element.querySelectorAll('textarea').forEach((TextAreaElement element) => element.value = "");
    this.element.querySelectorAll('input').forEach((InputElement element) => element..value   = ""
                                                                                    ..checked = false);

    log.debugContext('Message Cleared', context);
  }

  /**
   * General constructor. Sets up the initial state of the widget.
   */
  MessageEdit(Element this.element, Context this.context) {
    this.location = new nav.Location(context.id, element.id, this.messageBodyField.id);

    this._setupLabels();

    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);

    this._registerEventListeners();
  }

  /**
   * Selects the widget and activates it.
   */
  void _select(_) {
    if (!this.muted) {
      Controller.Context.changeLocation(this.location);
    }
  }

  /**
   * Setup the labels for the widget.
   */
  void _setupLabels () {
    this.header.children = [Icon.Edit,
                            new SpanElement()..text = Label.MessageEdit,
                            new Nudge(NavShortcut).element];

    this.callerNameField.placeholder = Label.CallerName;
    this.callerCompanyField.placeholder = Label.Company;
    this.callerPhoneField.placeholder= Label.Phone;
    this.callerCellphoneField.placeholder = Label.CellPhone;
    this.callerLocalExtensionField.placeholder = Label.LocalExtension;
    this.messageBodyField.placeholder = Label.PlaceholderMessageCompose;

    /// Checkbox labes.
    this.element.querySelectorAll('label').forEach((LabelElement label) {
      final String labelFor = label.attributes['for'];
        if (labelFor == this.pleaseCall.id) {
          label.text = Label.PleaseCall;
        } else if (labelFor == this.callsBack.id) {
          label.text = Label.WillCallBack;
        } else if (labelFor == this.hasCalled.id) {
          label.text =  Label.HasCalled;
        } else if (labelFor == this.urgent.id) {
          label.text = Label.Urgent;
        } else if (labelFor == this.draft.id) {
          label.text = Label.Draft;
        }
    });
    }


  /**
   * Event handler responsible for selecting the current widget.
   */
  void _onLocationChanged(nav.Location location) {
    this.hasFocus = (location.widgetId == element.id);

    element.classes.toggle('focus', this.hasFocus);
    this.tabable = this.hasFocus;

    if (location.elementId != null) {
      var elem = element.querySelector('#${location.elementId}');
      if (elem != null) {
        elem.focus();
      }
    }
  }

  /**
   * Sets up the initial event listeners.
   */
  void _registerEventListeners() {
    /// Navigation nudge boiler plate code.
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    event.bus.on(event.locationChanged).listen(this._onLocationChanged);
    event.bus.on(event.selectedMessagesChanged ).listen(this._fetchAndRender);
    this.draft.onClick.listen((_) => this.resendButton.disabled = this.draft.checked);

    /**
     * Clicks inside the widget area marks up the widget at directly selects
     * any table entry it targets.
     */
    element.onClick.listen((Event event) {
      if (!this.inFocus)
        Controller.Context.changeLocation(this.location);
    });
    /// Button click handlers
    this.saveButton  .onClick.listen(this._saveHandler);
    this.resendButton.onClick.listen(this._sendHandler);
  }

  /**
   * Extracts a Message from the information stored in the widget
   */
  model.Message _harvestMessage() {

    // Update the cached message with the information from the
    // fields in the widget.
    this.activeMessage
        ..body = messageBodyField.value
        ..caller.name = callerNameField.value
        ..caller.company = callerCompanyField.value
        ..caller.phone= callerPhoneField.value
        ..caller.cellphone = callerCellphoneField.value
        ..caller.localExtension = callerLocalExtensionField.value
        ..flags.clear();

    pleaseCall.checked ? this.activeMessage.flags.add('pleaseCall') : null;
    callsBack.checked  ? this.activeMessage.flags.add('willCallBack') : null;
    hasCalled.checked  ? this.activeMessage.flags.add('hasCalled') : null;
    urgent.checked     ? this.activeMessage.flags.add('urgent') : null;

    draft.checked      ? this.activeMessage.flags.add('draft') : null;

    return this.activeMessage;
  }

  void _fetchAndRender (_) {
    if (model.Message.selectedMessages.length == 1) {
      Storage.Message.get(model.Message.selectedMessages.first).then(_renderMessage);
      this.loading = false;

    } else {
      this._clearInputFields();
      this.loading = true;
    }
  }


  /**
   * Renders a message
   */
  void _renderMessage (model.Message message) {
    this.activeMessage = message;

    this.messageBodyField.value = message.body;
    this.callerNameField.value      = message.caller.name;
    this.callerCompanyField.value      = message.caller.company;
    this.callerPhoneField.value  = message.caller.phone;
    this.callerCellphoneField.value = message.caller.cellphone;
    this.callerLocalExtensionField.value = message.caller.localExtension;

    this.pleaseCall.checked = message.hasFlag('pleaseCall');
    this.callsBack.checked = message.hasFlag('willCallBack');
    this.hasCalled.checked = message.hasFlag('hasCalled');
    this.urgent.checked = message.hasFlag('urgent');
    this.draft.checked = message.hasFlag('draft');

    this.resendButton.disabled = this.draft.checked;

    // Set the context. Currently unused as this information is stored in activeMessage.
    //this.contextContactIDField.value     = message.context.contactID.toString();
    //this.contextContactNameField.value   = message.context.contactName;
    //this.contextReceptionIDField.value   = message.context.receptionID.toString();
    //this.contextReceptionNameField.value = message.context.receptionName;

    // /Updates the recipient list.


    recipientsList.children.clear();
    message.recipients.forEach((ORModel.MessageRecipient recipient) {
      recipientsList.children.add(new LIElement()
                                  ..text = recipient.contactName
                                  ..classes.add('email-recipient-role-${recipient.role}'));
    });

    this.activeMessage = message;
  }

  /**
   * Click handler for save button. Saves the currently typed in message via the Message Service.
   */
  void _saveHandler(_) {
    this.loading = true;
    model.Message message = this._harvestMessage();
    message.saveTMP().then((_) {
      model.NotificationList.instance.add(new model.Notification(Label.MessageUpdated, type : model.NotificationType.Success));

      return Storage.Message.get(message.ID).then(this._renderMessage);
    }).catchError((error, stackTrace) {

      model.NotificationList.instance.add(new model.Notification(Label.MessageNotUpdated, type : model.NotificationType.Error));
      log.debug('Failed to complete save operation: ${error} : $stackTrace');
    })
    .whenComplete(() => this.loading = false);
  }

  /**
   * Click handler for send button. Sends the currently typed in message via the Message Service.
   */
  void _sendHandler(_) {
    this.loading = true;

    model.Message message = this._harvestMessage();

    message.sendTMP().then((_) {
      model.NotificationList.instance.add(new model.Notification(Label.MessageEnqueued, type : model.NotificationType.Success));
      this._clearInputFields();

      model.Message.selectedMessages.clear();
      event.bus.fire(event.selectedMessagesChanged, null);

      }).catchError((error, stackTrace) {
        model.NotificationList.instance.add(new model.Notification(Label.MessageNotEnqueued, type : model.NotificationType.Error));
        log.debug('Failed to complete enqueue operation: ${error} : $stackTrace');
      }).whenComplete(() => this.loading = false);;
  }
}
