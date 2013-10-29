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

class ContactInfoColumn {
  DivElement body;
  Box box;
  String              calendarTitle        = 'Kalender';
  model.Contact contact;
  DivElement element;

  UListElement workHoursList;
  UListElement handlingList;
  DivElement position;
  DivElement responsibility;
  DivElement department;
  UListElement telephoneNumberList;
  DivElement relations;
  UListElement emailAddressList;
  DivElement info;
  UListElement backupList;
  UListElement calendarBody;

  ContactInfoColumn(DivElement this.element) {
    SpanElement calendarHeader = new SpanElement()
      ..classes.add('boxheader')
      ..text = calendarTitle;

    calendarBody = new UListElement()
      ..classes.addAll(['contact-info-container', 'zebra']);

    DivElement calendarBox = querySelector('#contactinfo_calendar')
        //new DivElement()
      ..classes.add('contact-info-calendarbox');

    String html = '''
        <div class="contact-info-infobox">
          <table>
            <tr>
              <td>
                <h5>Arbejdstider</h5>
                <div>
                  <ul id="contactWorkHoursList"></ul>
                </div>
              </td>
              <td>
                <h5>Kald</h5>
                <div>
                  <ul id="contactHandlingList"></ul>
                </div>
              </td>
            </tr>
            <tr>
              <td>
                <h5>Stilling</h5>
                <div id="contactPosition"></div>
              </td>
              <td>
                <h5>Ansvar</h5>
                <div id="contactResponsibility"></div>
              </td>
            </tr>
            <tr>
              <td>
                <h5>Afdeling</h5>
                <div id="contactDepartment"></div>
              </td>
              <td>
                <h5>Telefon</h5>
                <div>
                  <ul id="contactTelephoneNumberList"></ul>
                </div>
              </td>
            </tr>
            <tr>
              <td>
                <h5>Relationer</h5>
                <div id="contactRelations"></div>
              </td>
              <td>
                <h5>Email</h5>
                <div>
                  <ul id="contactEmailAddressList"></ul>
                </div>
              </td>
            </tr>
            <tr>
              <td>
                <h5>Info</h5>
                <div id="contactInfo"></div>
              </td>
              <td>
                <h5>Backup</h5>
                <div>
                  <ul id="contactBackupList"></ul>
                </div>
              </td>
            </tr>
          </table>
        </div>
    ''';

    box = new Box.withHeader(calendarBox, calendarHeader, calendarBody);
    //TODO ???? HACK XXX FIXME THOMAS LØCKE.
    //It's because the calendarBox, do not have any size when box, calls resize in the constructor. The size of it, is in the class.
    //new Future(box._resize);
    //element.children.add(calendarBox);

    body = new DocumentFragment.html(html).querySelector('.contact-info-infobox');
    element.children.add(body);

    workHoursList       = body.querySelector('#contactWorkHoursList');
    handlingList        = body.querySelector('#contactHandlingList');
    position            = body.querySelector('#contactPosition');
    responsibility      = body.querySelector('#contactResponsibility');
    department          = body.querySelector('#contactDepartment');
    telephoneNumberList = body.querySelector('#contactTelephoneNumberList');
    relations           = body.querySelector('#contactRelations');
    emailAddressList    = body.querySelector('#contactEmailAddressList');
    info                = body.querySelector('#contactInfo');
    backupList          = body.querySelector('#contactBackupList');

    event.bus.on(event.contactChanged).listen((model.Contact value) {
      contact = value;
      render();
    });
  }

  void render() {
    workHoursList.children.clear();
    for(var item in contact.workHoursList) {
      workHoursList.children.add(new LIElement()
        ..text = item.value);
    }

    handlingList.children.clear();
    for(var item in contact.handlingList) {
      workHoursList.children.add(new LIElement()
        ..text = item.value);
    }

    position.innerHtml = contact.position;
    responsibility.innerHtml = contact.responsibility;
    department.innerHtml = contact.department;

    telephoneNumberList.children.clear();
    for(var item in contact.telephoneNumberList) {
      telephoneNumberList.children.add(new LIElement()
        ..text = item.value);
    }

    relations.innerHtml = contact.relations;

    emailAddressList.children.clear();
    for(var item in contact.emailAddressList) {
      emailAddressList.children.add(new LIElement()
        ..text = item.value);
    }

    info.innerHtml = contact.info;

    backupList.children.clear();
    for(var item in contact.emailAddressList) {
      backupList.children.add(new LIElement()
        ..text = item.value);
    }

    calendarBody.children.clear();
    for(var event in contact.calendarEventList) {
      String html = '''
        <li class="${event.active ? 'company-events-active': ''}">
          <table class="calendar-event-table">
            <tbody>
              <tr>
                <td class="calendar-event-content  ${event.active ? '' : 'calendar-event-notactive'}">
                  ${event}
                <td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td class="calendar-event-timestamp  ${event.active ? '' : 'calendar-event-notactive'}">
                  ${event.start} - ${event.stop}
                <td>
              </tr>
            </tfoot>
          </table>
        <li>
      ''';

      calendarBody.children.add(new DocumentFragment.html(html).children.first);
    }
  }
}