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

/**
 * View of the contact's data.
 */

part of view;

class ContactInfoData {
  UListElement backupList;
  UListElement calendarBody;
  model.Contact contact = model.Contact.noContact;
  DivElement department;
  DivElement element;
  UListElement emailAddressList;
  UListElement handlingList;
  DivElement info;
  DivElement position;
  DivElement relations;
  DivElement responsibility;
  OListElement telephoneNumberList;
  UListElement get workHoursList => this.element.querySelector('#${id.CONTACT_WORK_HOURS_LIST}');
  List<Element> get nudges => this.element.querySelectorAll('.nudge');

  ContactInfoData(DivElement this.element) {
    handlingList = querySelector('#${id.CONTACT_HANDLING_LIST}');
    position = querySelector('#${id.CONTACT_PISITION}');
    responsibility = querySelector('#${id.CONTACT_RESPONSIBILITY}');
    department = querySelector('#${id.CONTACT_DEPARTMENT}');
    telephoneNumberList = querySelector('#${id.CONTACT_TELEPHONE_NUMBER_LIST}');
    relations = querySelector('#${id.CONTACT_RELATIONS}');
    emailAddressList = querySelector('#${id.CONTACT_EMAIL_ADDRESS_LIST}');
    info = querySelector('#${id.CONTACT_ADDITIONAL_INFO}');
    backupList = querySelector('#${id.CONTACT_BACKUP_LIST}');

    this._registerEventHandlers();
  }

  void render() {
    if (contact.isNull()) {
      return;
    }

    workHoursList.children = contact.workhours.map((String hourDesc) => new LIElement()..text = hourDesc).toList();

    if (workHoursList.children.isEmpty) workHoursList.children = [new LIElement()..text = Label.UnkownWorkHours];

    handlingList .children = contact.handling .map((String hourDesc) => new LIElement()..text = hourDesc).toList();

    position.innerHtml = contact.position != null ? contact.position : '';
    responsibility.innerHtml = contact.responsibility != null ? contact.responsibility : '';
    department.innerHtml = contact.department != null ? contact.department : '';

    telephoneNumberList.children.clear();

    int index = 1;
    for (var item in contact.phones) {

      LIElement number = new LIElement()
          ..classes.add("phone-number")
          ..classes.add(item['kind']);

      if (index < 9) {
        number.children.add(new Nudge(index.toString()).element);
      }
      index++;

      //TODO: Check if the phone number is confidential, and add the appropriate LI class.
      number.children.add(new ButtonElement()
          ..text = item['value']
          ..classes = ['pure-button', 'phonenumber']
          ..onClick.listen((_) => Controller.Extension.change (new model.Extension (item['value']))));

      telephoneNumberList.children.add(number);

      //TODO: Hide the phonenumber if it is private.
    }

    relations.innerHtml = contact.relations != null ? contact.relations : '';

    /* Add all contacts from the contacts distribution list.*/
    emailAddressList.children.clear();
    contact.distributionList.forEach((ORModel.MessageRecipient recipient) {
      LIElement li = new LIElement()
                   ..text = '${recipient.contactName} (${recipient.receptionName})'
                   ..classes.add(recipient.role);
        emailAddressList.children.add(li);
    });


    info.innerHtml = contact.info != null ? contact.info : '';
    backupList.children = contact.emailaddresses.map((String hourDesc) => new LIElement()..text = hourDesc).toList();
  }

  void hideNudges(bool hidden) {
    nudges.forEach((Element element) {
      element.hidden = hidden;
    });
  }

  _registerEventHandlers() {
    event.bus.on(event.keyNav).listen((bool isPressed) {
      this.hideNudges(!isPressed);
    });

    event.bus.on(event.CallSelectedContact).listen((int index) {
      if (telephoneNumberList.children.length < index) {
        return;
      }

      telephoneNumberList.children [index-1].querySelector('button').click();
    });

    event.bus.on(event.contactChanged).listen((model.Contact contact) {
      contact = contact;
      render();
    });

  }
}
