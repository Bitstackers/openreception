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

        DivElement  body;
        Box         box;
  final String      cancelButtonLabel = 'Annuller';
        Context     context;
        DivElement  element;
        SpanElement header;
  final String      saveButtonLabel   = 'Gem';
  final String      sendButtonLabel   = 'Send';
  final String      title             = 'Besked';

  InputElement sendmessagesearchbox;
  InputElement sendmessagesearchresult;
  InputElement sendmessagename;
  InputElement sendmessagecompany;
  InputElement sendmessagephone;
  InputElement sendmessagecellphone;
  InputElement sendmessagelocalno;
  TextAreaElement sendmessagetext;

  InputElement checkbox1;
  InputElement checkbox2;
  InputElement checkbox3;
  InputElement checkbox4;

  bool hasFocus = false;

  ButtonElement cancelButton;
  ButtonElement draftButton;
  ButtonElement sendButton;

  List<Element> focusElements;

  SendMessage(DivElement this.element, Context this.context) {
    body = querySelector('.send-message-container');

    header = new SpanElement()
      ..text = title;

    box = new Box.withHeader(element, header, body);

    sendmessagesearchbox    = body.querySelector('#sendmessagesearchbox');
    sendmessagesearchresult = body.querySelector('#sendmessagesearchresult');
    sendmessagename         = body.querySelector('#sendmessagename');
    sendmessagecompany      = body.querySelector('#sendmessagecompany');
    sendmessagephone        = body.querySelector('#sendmessagephone');
    sendmessagecellphone    = body.querySelector('#sendmessagecellphone');
    sendmessagelocalno      = body.querySelector('#sendmessagelocalno');
    sendmessagetext         = body.querySelector('#sendmessagetext');

//    checkbox1 = body.querySelector('#send-message-checkbox1');
//    checkbox2 = body.querySelector('#send-message-checkbox2');
//    checkbox3 = body.querySelector('#send-message-checkbox3');
//    checkbox4 = body.querySelector('#send-message-checkbox4');

    cancelButton = body.querySelector('#sendmessagecancel')
        ..text = cancelButtonLabel
        ..onClick.listen(cancelClick);

    draftButton = body.querySelector('#sendmessagedraft')
        ..text = saveButtonLabel
        ..onClick.listen(draftClick);

    sendButton = body.querySelector('#sendmessagesend')
        ..text = sendButtonLabel
        ..onClick.listen(sendClick);

   focusElements =
       [sendmessagesearchbox,
        sendmessagesearchresult,
        sendmessagename,
        sendmessagecompany,
        sendmessagephone,
        sendmessagecellphone,
        sendmessagelocalno,
        sendmessagetext,
//        checkbox1,
//        checkbox2,
//        checkbox3,
//        checkbox4,
        cancelButton,
        draftButton,
        sendButton];

   focusElements.forEach((e) => context.registerFocusElement(e));

   registerEventListeners();
  }

  void registerEventListeners() {
    element.onClick.listen((_) {
      if(!hasFocus) {
        setFocus(sendmessagetext.id);
      }
    });

    event.bus.on(event.contactChanged).listen((model.Contact contact) {
      //sendmessagename.value = 'Test: ${contact.name}';
    });

    event.bus.on(event.callChanged).listen((model.Call value){
      sendmessagephone.value = '${value.id}';
    });

    event.bus.on(event.focusChanged).listen((Focus value) {
      hasFocus = handleFocusChange(value, focusElements, element);
      });

    focusElements.forEach((e) => e.onFocus.listen((_) => setFocus(e.id)));
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
      Vi har taget imod en besked fra ${sendmessagename.value}
      Det er i forbindelse med virksomheden ${sendmessagecompany.value}
      Hans mobile nummer er ${sendmessagecellphone.value}
      og hvis du vil fange ham på hans fastnet nummer, skal du bare ringe til ${sendmessagephone.value}
      for ikke at glemme at han også oplyste sit lokalnummer ${sendmessagelocalno.value}
      Han ville bare gerne lige fortælle
      ${sendmessagetext.value}
      
      [${checkbox1.checked ? 'X': ' '}] Ring venligst 
      [${checkbox2.checked ? 'X': ' '}] Ringer selv tilbage
      [${checkbox3.checked ? 'X': ' '}] Har ringet
      [${checkbox4.checked ? 'X': ' '}] Haster

      Fortsat god dag ønskes du fra agent ${configuration.agentID}
    ''';

    protocol.sendMessage(completeMessage, ['8@1']);
  }
}
