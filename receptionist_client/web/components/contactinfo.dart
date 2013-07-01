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

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/model.dart' as model;

class ContactInfo extends WebComponent {
  String calendarTitle = 'Kalender';
  String placeholder   = 'søg...';
  String title         = 'Medarbejdere';

  @observable model.Contact contact = model.nullContact;

  void created() {
    _registerObservers();
  }

  void _registerObservers() {
    observe(() => environment.organization, (_) {
      contact = environment.organization.current.contactList.first;
    });
  }

  void select(Event event) {
    int id = int.parse((event.target as LIElement).id.split('_').last);
    contact = environment.organization.current.contactList.getContact(id);
  }
}
