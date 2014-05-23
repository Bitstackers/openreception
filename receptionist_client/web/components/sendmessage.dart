/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of components;

class SendMessage {
  /* Unused Variables
  final String       placeholderCellphone    = 'Mobil';
  final String       placeholderCompany      = 'Firmanavn';
  final String       placeholderLocalno      = 'Lokalnummer';
  final String       placeholderName         = 'Navn';
  final String       placeholderPhone        = 'Telefon';
  final String       placeholderSearch       = 'Søg...';
  final String       placeholderSearchResult = 'Ingen data fundet';
  final String       placeholderText         = 'Besked';
  final String       recipientTitle          = 'Modtagere';
  String localno                 = '';
  String name                    = '';
  String phone                   = '';
  bool   pleaseCall              = false;
  bool   emergency               = false;
  bool   hasCalled               = false;
  String cellphone               = '';
  String company                 = '';
  bool   callsBack               = true;
  String search                  = '';
  String searchResult            = '';
  String text                    = '';
   */

  DivElement body;
  Box box;
  final String cancelButtonLabel = 'Annuller';
  Context context;
  DivElement element;
  SpanElement header;
  final String saveButtonLabel = 'Gem';
  final String sendButtonLabel = 'Send';
  final String title = 'Besked';
  bool checkbox1Checked = false,
      checkbox2Checked = false,
      checkbox3Checked = false,
      checkbox4Checked = false;

  InputElement sendmessagesearchbox;
  InputElement sendmessagesearchresult;
  InputElement calleeNameField;
  InputElement calleeCompanyField;
  InputElement calleePhoneField;
  InputElement calleeCellphoneField;
  InputElement calleeLocalExtensionField;
  TextAreaElement messageBodyField;

  DivElement checkbox1;
  DivElement checkbox2;
  DivElement checkbox3;
  DivElement checkbox4;

  bool hasFocus = false;

  ButtonElement cancelButton;
  ButtonElement draftButton;
  ButtonElement sendButton;

  UListElement recipientsList;

  List<Element> focusElements;

  model.Reception reception = model.nullReception;
  model.Contact contact = model.nullContact;
  List<model.Recipient> recipients = new List<model.Recipient>();

  SendMessage(DivElement this.element, Context this.context) {
    body = querySelector('.send-message-container');

    header = new SpanElement()..text = title;

    box = new Box.withHeader(element, header, body);

    sendmessagesearchbox      = body.querySelector('#${id.SENDMESSAGE_SEARCHBOX}');
    sendmessagesearchresult   = body.querySelector('#sendmessagesearchresult');
    calleeNameField           = body.querySelector('#sendmessagename');
    calleeCompanyField        = body.querySelector('#sendmessagecompany');
    calleePhoneField          = body.querySelector('#sendmessagephone');
    calleeCellphoneField      = body.querySelector('#sendmessagecellphone');
    calleeLocalExtensionField = body.querySelector('#sendmessagelocalno');
    messageBodyField          = body.querySelector('#sendmessagetext');

    checkbox1 = body.querySelector('#send-message-checkbox1');
    checkbox2 = body.querySelector('#send-message-checkbox2');
    checkbox3 = body.querySelector('#send-message-checkbox3');
    checkbox4 = body.querySelector('#send-message-checkbox4');

    cancelButton = body.querySelector('#sendmessagecancel')
        ..text = cancelButtonLabel
        ..onClick.listen(cancelClick);

    draftButton = body.querySelector('#sendmessagedraft')
        ..text = saveButtonLabel
        ..onClick.listen(draftClick);

    sendButton = body.querySelector('#sendmessagesend')
        ..text = sendButtonLabel
        ..onClick.listen(sendClick);

    recipientsList = querySelector('#send-message-recipient-list');

    focusElements = [sendmessagesearchbox, calleeNameField, calleeCompanyField, calleePhoneField, calleeCellphoneField, calleeLocalExtensionField, messageBodyField, checkbox1, checkbox2, checkbox3, checkbox4, cancelButton, draftButton, sendButton];

    focusElements.forEach((e) => context.registerFocusElement(e));

    registerEventListeners();
  }

  void render() {
    // Updates the recipient list.
    recipientsList.children.clear();
    this.recipients.forEach((model.Recipient recipient) { 
      recipientsList.children.add (new LIElement()..text = recipient.role+ ": " + recipient.contactName);
    });
  }
    

  void registerEventListeners() {
    //    element.onClick.listen((_) {
    //      if(!hasFocus) {
    //        setFocus(sendmessagetext.id);
    //      }
    //    });

   // event.bus.on(event.locationChanged).listen((nav.Location location) {
   //   bool active = location.widgetId == element.id;
   //   element.classes.toggle(FOCUS, active);
   //   if (location.elementId != null) {
   //     var elem = element.querySelector('#${location.elementId}');
   //     if (elem != null) {
   //       elem.focus();
   //     }
   //   }
   // });

    /**
     * Event handler responsible for updating the recipient list (and UI) when a contact is changed.
     */
    event.bus.on(event.contactChanged).listen((model.Contact contact) {
      this.contact = contact;

      this.recipients.clear();
      contact.dereferenceDistributionList()
        .then((List<model.Recipient> dereferencedDistributionList) { 
          // Put all the dereferenced recipients to the local list.
          dereferencedDistributionList.forEach((model.Recipient recipient) {
            this.recipients.add(recipient);
          });
          
          this.render();
      });
    });
    
    event.bus.on(event.receptionChanged).listen((model.Reception value) {
      reception = value;
    });

    event.bus.on(event.callChanged).listen((model.Call value) {
      calleePhoneField.value = '${value.callerId}';
    });


    /* Checkbox logic */
    checkbox1.onKeyUp.listen((KeyboardEvent event) {
      if (event.keyCode == Keys.SPACE) {
        toggle(1);
      }
    });

    checkbox2.onKeyUp.listen((KeyboardEvent event) {
      if (event.keyCode == Keys.SPACE) {
        toggle(2);
      }
    });

    checkbox3.onKeyUp.listen((KeyboardEvent event) {
      if (event.keyCode == Keys.SPACE) {
        toggle(3);
      }
    });

    checkbox4.onKeyUp.listen((KeyboardEvent event) {
      if (event.keyCode == Keys.SPACE) {
        toggle(4);
      }
    });

    checkbox1.parent.onClick.listen((_) => toggle(1));
    checkbox2.parent.onClick.listen((_) => toggle(2));
    checkbox3.parent.onClick.listen((_) => toggle(3));
    checkbox4.parent.onClick.listen((_) => toggle(4));

    element.onClick.listen((MouseEvent e) {
      if ((e.target as Element).attributes.containsKey('tabindex')) {
        event.bus.fire(event.locationChanged, new nav.Location(context.id, element.id, (e.target as Element).id));
      }
    });
  }

  void toggle(int number, {bool shouldBe}) {
    String checkedClass = 'send-message-checkbox-checked';
    switch (number) {
      case 1:
        if (shouldBe != null) {
          checkbox1Checked = shouldBe;
        } else {
          checkbox1Checked = !checkbox1Checked;
        }
        checkbox1.classes.toggle(checkedClass, checkbox1Checked);
        break;
      case 2:
        if (shouldBe != null) {
          checkbox2Checked = shouldBe;
        } else {
          checkbox2Checked = !checkbox2Checked;
        }
        checkbox2.classes.toggle(checkedClass, checkbox2Checked);
        break;
      case 3:
        if (shouldBe != null) {
          checkbox3Checked = shouldBe;
        } else {
          checkbox3Checked = !checkbox3Checked;
        }
        checkbox3.classes.toggle(checkedClass, checkbox3Checked);
        break;
      case 4:
        if (shouldBe != null) {
          checkbox4Checked = shouldBe;
        } else {
          checkbox4Checked = !checkbox4Checked;
        }
        checkbox4.classes.toggle(checkedClass, checkbox4Checked);
        break;
      default:
        log.error('sendmessage: toggle: The given number: ${number} is not accounted for');
    }
  }

  void cancelClick(_) {
    log.debug('SendMessage Cancel Button pressed');
  }

  void draftClick(_) {
    log.debug('SendMessage Draft Button pressed');
  }

  void sendClick(_) {
    log.debug('SendMessage Send Button pressed');
    String completeMessage = '''
      Goddag
      Vi har taget imod en besked fra ${calleeNameField.value}
      Det er i forbindelse med virksomheden ${calleeCompanyField.value}
      Hans mobile nummer er ${calleeCellphoneField.value}
      og hvis du vil fange ham på hans fastnet nummer, skal du bare ringe til ${calleePhoneField.value}
      for ikke at glemme at han også oplyste sit lokalnummer ${calleeLocalExtensionField.value}
      Han ville bare gerne lige fortælle
      ${messageBodyField.value}
      
      [${checkbox1Checked ? 'X': ' '}] Ring venligst 
      [${checkbox2Checked ? 'X': ' '}] Ringer selv tilbage
      [${checkbox3Checked ? 'X': ' '}] Har ringet
      [${checkbox4Checked ? 'X': ' '}] Haster

      Fortsat god dag ønskes du fra agent ${configuration.userName}
    ''';


    contact.contextMap().then((Map contextMap) {
      model.Message pendingMessage = new model.Message.fromMap({
        'taken_from'  : calleeNameField.value,
        'from_company': calleeCompanyField.value,
        'message'     : messageBodyField.value,
        'phone'       : calleePhoneField.value,
        'cellphone'   : calleeCellphoneField.value,
        'urgent'      : checkbox4Checked,
        'context'     : contextMap
      });

      for (model.Recipient recipient in this.recipients) {
        pendingMessage.addRecipient(recipient);
      }

      log.dataDump(completeMessage, "components.sendClick");
      pendingMessage.send().then((_) {
        log.debug('Sent message');
      }).catchError((error) {
        log.debug('----- Send Message Unlucky Result: ${error}');
      });
    });
  }
}
