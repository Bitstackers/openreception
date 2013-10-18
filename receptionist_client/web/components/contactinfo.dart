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

import 'dart:html';

import 'package:polymer/polymer.dart';

import '../classes/common.dart';
import '../classes/environment.dart' as environment;
import '../classes/events.dart' as event;
import '../classes/logger.dart';
import '../classes/model.dart' as model;

@CustomTag('contact-info')
class ContactInfo extends PolymerElement with ApplyAuthorStyle {
              String calendarTitle            = 'Kalender';
  @observable model.Contact contact           = model.nullContact;
              model.Contact nullContact       = model.nullContact;
  @observable model.Organization organization = model.nullOrganization;
              String placeholder              = 'søg...';
              String title                    = 'Medarbejdere';

  void created() {
    super.created();
    registerEventListerns();
  }

  void registerEventListerns() {
    event.bus.on(event.contactChanged).listen((model.Contact value) => contact = value);
    event.bus.on(event.organizationChanged).listen((model.Organization value) => organization = value);
  }

  void select(Event _, var __, Node target) {
    int id = int.parse((target as LIElement).id.split('_').last);
    environment.contact = environment.organization.contactList.getContact(id);

    log.debug('ContactInfo.select updated environment.contact to ${environment.contact}');
  }

  String getClass(model.CalendarEvent event) => event.active ? 'company-events-active' : '';
  String getInfoClass(model.Contact value) => contact == value ? 'contact-info-active' : '';
}
