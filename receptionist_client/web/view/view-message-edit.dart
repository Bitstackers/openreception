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
 * View for a message being edited. This widget listens for [selectedEditMessageChanged]
 * events and render the selected message.
 */
class MessageEdit {

  static const String className = '${libraryName}.Message';
  static const String NavShortcut = 'B'; 
  //static const String NavShortcut = 'B'; 

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
  
  /// Widget control buttons
  ButtonElement get saveButton   => this.element.querySelector('button.save');
  ButtonElement get resendButton => this.element.querySelector('button.resend');
  
  bool hasFocus = false;
  bool get muted     => this.context != Context.current;
  
  UListElement get recipientsList => this.element.querySelector('.message-recipient-list');

  List<Element>   get nudges         => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  List<Element> focusElements;

  model.Reception reception = model.nullReception;
  model.Contact contact = model.nullContact;
  List<model.Recipient> recipients = new List<model.Recipient>();

  /**
   * Update the disabled property.
   * 
   * Used for locking the input fields upon sending
   * a message, or when no contact is selected.
   */
  void set isDisabled(bool disabled) {
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
    
    const String context = '${className}._clear';
    
    this.element.querySelectorAll('input').forEach((InputElement element) {
      element.value = "";
      element.checked = false;
    });

    this.element.querySelectorAll('textarea').forEach((TextAreaElement element) {
      element.value = "";
    });

    log.debugContext('Message Cleared', context);
  }

  MessageEdit(Element this.element, Context this.context) {
    print (context.id);
    print (element.id);
    print (this.messageBodyField.id);
    
    this.location = new nav.Location(context.id, element.id, this.messageBodyField.id);
    
    this._setupLabels();
    ///Navigation shortcuts
    this.header.children.add(new Nudge(NavShortcut).element);
   
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);
    //focusElements = [callerNameField, callerCompanyField, callerPhoneField, callerCellphoneField, callerLocalExtensionField, messageBodyField, pleaseCall, callsBack, hasCalled, urgent, cancelButton, sendButton];

    //focusElements.forEach((e) => context.registerFocusElement(e));

    this._registerEventListeners();
  }

  void _select(_) {
    if (!this.muted) {
      Controller.Context.changeLocation(this.location);
    }
  }

  
  void _setupLabels () {
    this.header.text = MessageLabels.title;
    this.callerCellphoneField.placeholder = MessageLabels.callerCellphonePlaceholder; 
    this.callerNameField.placeholder = MessageLabels.callerNamePlaceholder;
    this.callerCompanyField.placeholder = MessageLabels.callerCompanyPlaceholder;
    this.callerPhoneField.placeholder= MessageLabels.callerPhonePlaceholder;
    this.callerLocalExtensionField.placeholder = MessageLabels.callerLocalNumberPlaceholder;
    this.messageBodyField.placeholder = MessageLabels.messagePlaceholder;
    
    /// Checkbox labes.
    this.element.querySelectorAll('label').forEach((LabelElement label) {
      final String labelFor = label.attributes['for'];
      
      if (labelFor == this.pleaseCall.id) {
        label.text = MessageLabels.pleaseCall;
      } else if (labelFor == this.callsBack.id) {
        label.text = MessageLabels.callsBack;
      } else if (labelFor == this.hasCalled.id) {
        label.text =  MessageLabels.hasCalled;
      } else if (labelFor == this.urgent.id) {
        label.text = MessageLabels.urgent;
      }
    });
    }
  
  /**
   * Re-renders the recipient list.
   */
  void _renderRecipientList() {
    // Updates the recipient list.
    recipientsList.children.clear();
    this.recipients.forEach((model.Recipient recipient) {
      recipientsList.children.add(new LIElement()
                                    ..text = recipient.contactName
                                    ..classes.add('email-recipient-role-${recipient.role}'));
    });
  }

  /**
   * Click handler for the entire message element. Sets the focus to the widget.
   */
  void _onMessageElementClick(_) {
    const String context = '${className}._onMessageElementClick';
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

  void _registerEventListeners() {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);
    
    element.onClick.listen(this._onMessageElementClick);
    event.bus.on(event.locationChanged).listen(this._onLocationChanged);

    event.bus.on(event.selectedEditMessageChanged ).listen(this._renderMessage);
    
    /*element.onClick.listen((MouseEvent e) {
      if ((e.target as Element).attributes.containsKey('tabindex')) {
        event.bus.fire(event.locationChanged, new nav.Location(context.id, element.id, (e.target as Element).id));
      }
    });*/
  }

  void _cancelClick(_) {
    this._clearInputFields();
  }

  void _draftClick(_) {
    const String context = '${className}.draftClick';

    log.fixmeContext("Not implemented!", context);
  }

  /**
   *
   */
  void _renderMessage (model.Message message) {
    this.callerNameField.value      = message.caller.name;
    this.callerCompanyField.value      = message.caller.company;
    this.callerPhoneField.value  = message.caller.phone;
    this.callerCellphoneField.value = message.caller.cellphone;
    //this.callerLocalExtensionField.value = message.caller.localExtension;
    this.messageBodyField.text = message.body;
    
    this.pleaseCall.checked = message.hasFlag('pleaseCall');
    this.callsBack.checked = message.hasFlag('willCallBack');
    this.hasCalled.checked = message.hasFlag('hasCalled');
    this.urgent.checked = message.hasFlag('urgent');

      /// Checkboxes
//      InputElement get pleaseCall => this.element.querySelector('input.message-tag.pleasecall');
//      InputElement get callsBack  => this.element.querySelector('input.message-tag.callsback');
 //     InputElement get hasCalled  => this.element.querySelector('input.message-tag.hascalled');
 //    InputElement get urgent     => this.element.querySelector('input.message-tag.urgent');
  }
  
  /**
   * Harvests and prepares the message from the input fields and
   * sends is via the Message Service.
   */
  void _sendHandler(_) {
    contact.contextMap().then((Map contextMap) {
      model.Message pendingMessage = new model.Message.fromMap({
        'message': messageBodyField.value,
        'phone': callerPhoneField.value,
        'caller': {
          'name': callerNameField.value,
          'company': callerCompanyField.value,
          'phone': callerPhoneField.value,
          'cellphone': callerCellphoneField.value,
          'localextension': callerLocalExtensionField.value
        },
        'context': contextMap,
        'flags': []
      });

      print (pendingMessage.toMap);

      pleaseCall.checked ? pendingMessage.addFlag('urgent') : null;
      callsBack.checked ? pendingMessage.addFlag('willCallBack') : null;
      hasCalled.checked ? pendingMessage.addFlag('called') : null;
      urgent.checked ? pendingMessage.addFlag('urgent') : null;


      for (model.Recipient recipient in this.recipients) {
        pendingMessage.addRecipient(recipient);
      }

      this.isDisabled = true;

      pendingMessage.send().then((_) {
        log.debug('Sent message');
        this._clearInputFields();
        this.isDisabled = false;
      }).catchError((error) {
        this.isDisabled = false;
        log.debug('----- Send Message Unlucky Result: ${error}');
      });
    });
  }
}
