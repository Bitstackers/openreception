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

  SendMessage(DivElement this.element) {
    /*
    String html = '''
      <div class="send-message-container">
        <input class="send-message-searchbox send-message-field" type="search" placeholder="${placeholderSearch}"/>
        <input class="send-message-search-result send-message-field" placeholder="${placeholderSearchResult}" readonly/>

        <input class="send-message-name send-message-field" placeholder="${placeholderName}"/>
        <input class="send-message-company send-message-field" placeholder="${placeholderCompany}"/>

        <input class="send-message-phone send-message-field" placeholder="${placeholderPhone}"/>
        <input class="send-message-cellphone send-message-field" placeholder="${placeholderCellphone}"/>
        <input class="send-message-localno send-message-field" placeholder="${placeholderLocalno}"/>

        <textarea style="resize: none" class="send-message-text send-message-field" placeholder="${placeholderText}"></textarea>

        <div class="send-message-checkbox-container send-message-pleasecall">
          <input checked?="{{pleaseCall}}" id="send-message-checkbox1" type="checkbox"/>
          <label class="send-message-checkbox-label" for="send-message-checkbox1"><span></span>Ring venligst</label>
        </div>
          <div class="send-message-checkbox-container send-message-callsback">
          <input checked?="{{callsBack}}" id="send-message-checkbox2" type="checkbox"/>
        <label class="send-message-checkbox-label" for="send-message-checkbox2"><span></span>Ringer selv tilbage</label>
        </div>
          <div class="send-message-checkbox-container send-message-hascalled">
          <input checked?="{{hasCalled}}" id="send-message-checkbox3" type="checkbox"/>
        <label class="send-message-checkbox-label" for="send-message-checkbox3"><span></span>Har ringet</label>
        </div>
        <div class="send-message-checkbox-container send-message-emergency">
          <input class="send-message-checkbox" checked="{{emergency}}" id="send-message-checkbox4" type="checkbox"/>
          <label class="send-message-checkbox-label" for="send-message-checkbox4"><span></span>Haster</label>
        </div>

        <div class="send-message-button-container">
          <button on-click="">${cancelButtonLabel}</button>
          <button on-click="">${saveButtonLabel}</button>
          <button on-click="">${sendButtonLabel}</button>
        </div>

        <div class="send-message-recipient-container">
          <box-with-header headerfontsize="0.8em" headerpadding="0px 5px 2px 5px">
            <span name="boxheader">
              {{recipientTitle}}
            </span>

            <div name="boxcontent" class="minibox">
              <ul>
                <li>Thomas</li>
                <li>Trine</li>
                <li>Steen</li>
              </ul>
              <!--<ul template iterate="value in environment.contact.calendarEventList" class="contact-info-zebraeven2">
                <template instantiate="if value.active">
                  <li class="contact-info-active2">
                    <calendar-event event="{{value}}"></calendar-event>
                  </li>
                </template>
                <template instantiate="if !value.active">
                  <li>
                    <calendar-event event="{{value}}"></calendar-event>
                  </li>
                </template>
              </ul>-->
            </div>
          </box-with-header>
        </div>
      </div>
    ''';
    */

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

    checkbox1 = body.querySelector('#send-message-checkbox1');
    checkbox2 = body.querySelector('#send-message-checkbox2');
    checkbox3 = body.querySelector('#send-message-checkbox3');
    checkbox4 = body.querySelector('#send-message-checkbox4');

    var cancelButton = body.querySelector('#sendmessagecancel')
        ..text = cancelButtonLabel
        ..onClick.listen(cancelClick);

    var draftButton = body.querySelector('#sendmessagedraft')
        ..text = saveButtonLabel
        ..onClick.listen(draftClick);

    var sendButton = body.querySelector('#sendmessagesend')
        ..text = sendButtonLabel
        ..onClick.listen(sendClick);

   registerEventListeners();
  }

  void registerEventListeners() {
    event.bus.on(event.contactChanged).listen((model.Contact contact) {
      sendmessagename.value = 'Test: ${contact.name}';
    });
  }

  void cancelClick(_) {
    log.debug('SendMessage Cancel Button pressed');
  }

  void draftClick(_) {
    log.debug('SendMessage Draft Button pressed');
  }

  void sendClick(_) {
    log.debug('SendMessage Send Button pressed');
  }
}
