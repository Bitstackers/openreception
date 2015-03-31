/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

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

class Message {

  static final Logger log = new Logger('${libraryName}.Message');

  static const String DefaultNavShortcut = 'B';

  final Element      element;
  final Context      context;
        nav.Location location;

        Element         get header                    => this.element.querySelector('legend');
        InputElement    get callerNameField           => this.element.querySelector('input.name');
        InputElement    get callerCompanyField        => this.element.querySelector('input.company');
        InputElement    get callerPhoneField          => this.element.querySelector('input.phone');
        InputElement    get callerCellphoneField      => this.element.querySelector('input.cellphone');
        InputElement    get callerLocalExtensionField => this.element.querySelector('input.local-extension');
        TextAreaElement get messageBodyField          => this.element.querySelector('textarea.message-body');

  /// Checkboxes
        InputElement get pleaseCall => this.element.querySelector('input.message-tag.pleasecall');
        InputElement get callsBack  => this.element.querySelector('input.message-tag.callsback');
        InputElement get hasCalled  => this.element.querySelector('input.message-tag.hascalled');
        InputElement get urgent     => this.element.querySelector('input.message-tag.urgent');
        InputElement get draft      => this.element.querySelector('input.message-tag.draft');

  /// Widget control buttons
  ButtonElement get cancelButton => this.element.querySelector('button.cancel');
  ButtonElement get saveButton   => this.element.querySelector('button.save');
  ButtonElement get sendButton   => this.element.querySelector('button.send');

  bool hasFocus = false;
  bool get muted     => this.context != Context.current;
  bool get inFocus   => nav.Location.isActive(this.element);

  UListElement get recipientsList => this.element.querySelector('.${CssClass.messageRecipientList}');

  List<Element>   get nudges         => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  List<Element> focusElements;

  model.Contact contact = model.Contact.noContact;
  ORModel.MessageRecipientList recipients = new ORModel.MessageRecipientList.empty();

  /**
   * Update the disabled property.
   *
   * Used for locking the input fields upon sending
   * a message, or when no contact is selected.
   */
  void set disabled(bool disabled) {
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
    this.messageBodyField.classes.toggle(CssClass.loading, isLoading);
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
   * Clears out the content of the input fields.
   */
  void _clearInputFields() {

    this.element.querySelectorAll('input').forEach((InputElement element) {
      element.value = "";
      element.checked = false;
    });

    this.element.querySelectorAll('textarea').forEach((TextAreaElement element) {
      element.value = "";
    });

    recipientsList.children.clear();

    log.finest('Message Cleared', context);
  }

  Message(Element this.element, Context this.context, {String navShortcut : DefaultNavShortcut}) {
    this.location = new nav.Location(context.id, element.id, this.messageBodyField.id);

    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(navShortcut, this._select);

    element.onClick.listen((Event event) {
    if (!this.inFocus)
      if ((event.target as Element).id.isNotEmpty)
        Controller.Context.changeLocation(new nav.Location(context.id, element.id, (event.target as Element).id));
      else
        Controller.Context.changeLocation(this.location);
    });

    this.cancelButton
        ..text = Label.Cancel
        ..onClick.listen((_) => this._clearInputFields());

    this.saveButton
        ..text = Label.Save
        ..onClick.listen(this._saveHandler);

    this.sendButton
        ..text = Label.Send
        ..onClick.listen(this._sendHandler);

    this._renderContact(contact);
    this._setupLabels();
    this._registerEventListeners();
  }

  void _select(_) {
    if (!this.muted) {
      Controller.Context.changeLocation(this.location);
    }
  }


  void _setupLabels () {
    this.header.children =
        [Icon.Message,
         new SpanElement()..text =  Label.MessageCompose,
         new Nudge(DefaultNavShortcut).element];
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
   * Re-renders the recipient list.
   */
  void _renderRecipientList() {
    // Updates the recipient list.
    recipientsList.children.clear();
    this.recipients.forEach((ORModel.MessageRecipient recipient) {
      recipientsList.children.add(new LIElement()
                                    ..text = recipient.contactName
                                    // TODO (TL): Not a big fan of this.
                                    // Very hard to search for. Either use text to denominate kind of recipient
                                    // or refer to the styling class from a local map with recipient.role as key
                                    ..classes.add('email-recipient-role-${recipient.role}'));
    });
  }

  /**
   * Event handler responsible for selecting the current widget.
   */
  void _onLocationChanged(nav.Location location) {
    this.hasFocus = (location.widgetId == element.id);

    element.classes.toggle(CssClass.focus, this.hasFocus);
    this.tabable = this.hasFocus;

    if (location.elementId != null) {
      var elem = element.querySelector('#${location.elementId}');
      if (elem != null) {
        elem.focus();
      }
    }

  }

  /**
   * Event handler responsible for updating the recipient list (and UI) when a contact is changed.
   */
  void _renderContact(model.Contact contact) {
    this.contact = contact;

    this.recipients = new ORModel.MessageRecipientList.empty();
    if (this.contact != model.Contact.noContact) {
      this.disabled = false;
        contact.distributionList.forEach((ORModel.MessageRecipient recipient) {
          this.recipients.add(recipient);
        });

        this._renderRecipientList();
    } else {
      this.disabled = true;
      this._renderRecipientList();
    }
  }

  void _registerEventListeners() {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    event.bus.on(event.locationChanged).listen(this._onLocationChanged);

    model.Contact.onContactChange.listen(this._renderContact);

    event.bus.on(event.callChanged).listen((model.Call value) {
      if (value.callerID != null ) {
        callerPhoneField.value = '${value.callerID}';
      } else {
        callerPhoneField.value;
      }
    });

    this.draft.onClick.listen((_) => this.sendButton.disabled = this.draft.checked);

  }

  /**
   * Extracts a Message from the information stored in the widget
   */
  Future<model.Message> _harvestMessage() {
    return contact.contextMap().then((Map contextMap) {
      model.Message pendingMessage = new model.Message.fromMap({
        'message': messageBodyField.value,
        'phone': callerPhoneField.value,
        'caller': {
          'name': callerNameField.value,
          'company': callerCompanyField.value,
          'phone': callerPhoneField.value,
          'cellphone': callerCellphoneField.value,
          'localExtension': callerLocalExtensionField.value
        },
        'context': contextMap,
        'flags': [],
        'created_at' : 0
      });

      /// Check if tags should be added to the message and if so; add them.
      pleaseCall.checked ? pendingMessage.addFlag(model.MessageFlag.PleaseCall)   : null;
      callsBack.checked  ? pendingMessage.addFlag(model.MessageFlag.willCallBack) : null;
      hasCalled.checked  ? pendingMessage.addFlag(model.MessageFlag.Called)       : null;
      urgent.checked     ? pendingMessage.addFlag(model.MessageFlag.Urgent)       : null;

      /// For now, draft is merely a flag we tag the message with.
      draft.checked      ? pendingMessage.addFlag('draft') : null;

      for (ORModel.MessageRecipient recipient in this.recipients) {
        pendingMessage.recipients.add(recipient);
      }

      pendingMessage.sender = model.User.currentUser;

      return pendingMessage;
    });
  }

  /**
   * Click handler for send button. Sends the currently typed in message via the Message Service.
   */
  void _sendHandler(_) {
    this.loading  = true;

    this._harvestMessage().then ((model.Message message) {
      message.sendTMP().then((_) {
        model.NotificationList.instance.add(new model.Notification
            (Label.MessageSent, type : model.NotificationType.Success));
        this._clearInputFields();
      }).catchError(() {
        model.NotificationList.instance.add(new model.Notification
            (Label.MessageNotUpdated, type : model.NotificationType.Error));
      })
      .whenComplete(() => this.loading = false);
    });
  }

  /**
   * Click handler for save button. Saves the currently typed in message via the Message Service.
   */
  void _saveHandler(_) {
    this.disabled = true;

    this._harvestMessage().then ((model.Message message) {
      message.saveTMP().then((_) {
        model.NotificationList.instance.add(new model.Notification
            (Label.MessageSent, type : model.NotificationType.Success));
        this._clearInputFields();
      }).catchError((error, stackTrace) {
        model.NotificationList.instance.add(new model.Notification
            (Label.MessageNotUpdated, type : model.NotificationType.Error));
      }).whenComplete(() => this.disabled = false);
    });
  }
}
