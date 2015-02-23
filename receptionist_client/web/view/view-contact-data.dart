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

/**
 * View of the contact's data.
 */

part of view;

class ContactData {
  UListElement backupList;
  UListElement calendarBody;
  DivElement department;
  DivElement element;
  UListElement emailAddressList;
  UListElement handlingList;
  DivElement info;
  DivElement position;
  DivElement relations;
  DivElement responsibility;
  OListElement telephoneNumberList;
  UListElement get workHoursList => this.element.querySelector('#${Id.contactWorkHoursList}');
  List<Element> get nudges => this.element.querySelectorAll('.nudge');

  HeadingElement get workhoursHeader        => this.element.querySelector('.${CssClass.contactDataWorkhoursLabel}');
  HeadingElement get jobtitleHeader         => this.element.querySelector('.${CssClass.contactDataJobtitleLabel}');
  HeadingElement get handlingHeader         => this.element.querySelector('.${CssClass.contactDataHandlingLabel}');
  HeadingElement get responsibilityHeader   => this.element.querySelector('.${CssClass.contactDataResponsibilityLabel}');
  HeadingElement get departmentHeader       => this.element.querySelector('.${CssClass.contactDataDepartmentLabel}');
  HeadingElement get phoneHeader            => this.element.querySelector('.${CssClass.contactDataPhoneLabel}');
  HeadingElement get relationsHeader        => this.element.querySelector('.contact-info-relations-label');
  HeadingElement get emailsHeader           => this.element.querySelector('.contact-info-emails-label');
  HeadingElement get extraHeader            => this.element.querySelector('.contact-info-extra-label');
  HeadingElement get backupsHeader          => this.element.querySelector('.contact-info-backups-label');

  ContactData(DivElement this.element) {
    handlingList = querySelector('#${Id.contactDataHandlingList}');
    position = querySelector('#${Id.contactDataPosition}');
    responsibility = querySelector('#${Id.contactDataResponsibility}');
    department = querySelector('#${Id.contactDataDepartment}');
    telephoneNumberList = querySelector('#${Id.contactDataTelephoneNumberList}');
    relations = querySelector('#${Id.CONTACT_RELATIONS}');
    emailAddressList = querySelector('#${Id.CONTACT_EMAIL_ADDRESS_LIST}');
    info = querySelector('#${Id.CONTACT_ADDITIONAL_INFO}');
    backupList = querySelector('#${Id.CONTACT_BACKUP_LIST}');

    this._registerEventHandlers();

    this._setupLabels();
  }

  void _setupLabels() {
    this.workhoursHeader       .text = Label.ContactWorkHours;
    this.jobtitleHeader        .text = Label.ContactJobTitle;
    this.handlingHeader        .text = Label.ContactHandling;
    this.responsibilityHeader  .text = Label.ContactResponsibilities;
    this.departmentHeader      .text = Label.ContactDepartment;
    this.phoneHeader           .text = Label.ContactPhone;
    this.relationsHeader       .text = Label.ContactRelations;
    this.emailsHeader          .text = Label.ContactEmails;
    this.extraHeader           .text = Label.ContactExtraInfo;
    this.backupsHeader         .text = Label.ContactBackups;
  }

  void render(model.Contact contact) {
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

    event.bus.on(model.Contact.activeContactChanged).listen(render);

  }
}
