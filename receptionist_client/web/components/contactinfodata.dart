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

part of components;

class ContactInfoData {
  UListElement  backupList;
  UListElement  calendarBody;
  model.Contact contact;
  DivElement    department;
  DivElement    element;
  UListElement  emailAddressList;
  UListElement  handlingList;
  DivElement    info;
  DivElement    position;
  DivElement    relations;
  DivElement    responsibility;
  OListElement  telephoneNumberList;
  UListElement  workHoursList;

  ContactInfoData(DivElement this.element) {

    workHoursList       = querySelector('#${id.CONTACT_WORK_HOURS_LIST}');
    handlingList        = querySelector('#${id.CONTACT_HANDLING_LIST}');
    position            = querySelector('#${id.CONTACT_PISITION}');
    responsibility      = querySelector('#${id.CONTACT_RESPONSIBILITY}');
    department          = querySelector('#${id.CONTACT_DEPARTMENT}');
    telephoneNumberList = querySelector('#${id.CONTACT_TELEPHONE_NUMBER_LIST}');
    relations           = querySelector('#${id.CONTACT_RELATIONS}');
    emailAddressList    = querySelector('#${id.CONTACT_EMAIL_ADDRESS_LIST}');
    info                = querySelector('#${id.CONTACT_ADDITIONAL_INFO}');
    backupList          = querySelector('#${id.CONTACT_BACKUP_LIST}');

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
      handlingList.children.add(new LIElement()
        ..text = item.value);
    }

    position.innerHtml = contact.position != null ? contact.position: '';
    responsibility.innerHtml = contact.responsibility != null ? contact.responsibility: '';
    department.innerHtml = contact.department  != null ? contact.department: '';

    telephoneNumberList.children.clear();
    for(var item in contact.phoneNumberList) {
      
      LIElement number = new LIElement()
        ..classes.add ("phone-number")
        ..classes.add (item.kind);
      print("Adding click handler");
      number.children.add(new ButtonElement()
          ..text = item.value
          ..onClick.listen((_) =>  
              event.bus.fire(event.originateCallRequest, new model.DiablePhoneNumber.from(item, contact))));
      
      telephoneNumberList.children.add(number);
      
      //TODO: Hide the phonenumber if it is private.
    }

    relations.innerHtml = contact.relations != null ? contact.relations: '';

    /* Add all contacts from the contacts distribution list.*/
    emailAddressList.children.clear();

    for(var item in contact.distributionList) {
        model.Contact.get(item.contactID, item.receptionID).then((model.Contact contact) {
          model.Reception.get(item.receptionID).then((model.Reception reception) { 
            if (reception != model.Reception.currentReception) {
              LIElement li = new LIElement()
                              ..text = '${contact.name} (${reception.name})'
                              ..classes.add(item.role);
                  emailAddressList.children.add(li);
            }
          });
        });
    }

    info.innerHtml = contact.info  != null ? contact.info: '';

    backupList.children.clear();
    for(var item in contact.emailAddressList) {
      backupList.children.add(new LIElement()
        ..text = item.value);
    }
  }
}